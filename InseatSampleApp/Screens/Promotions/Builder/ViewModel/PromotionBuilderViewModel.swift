import Foundation
import Combine
import Inseat

final class PromotionBuilderViewModel: PromotionBuilderViewModelInput {

    let promotionInfo: PromotionBuilderContract.PromotionInfo

    @Published var requiredIndividualProducts: [PromotionBuilderContract.RequiredIndividualProduct] = []
    @Published var requiredCategories: [PromotionBuilderContract.RequiredCategory] = []

    @Published var individualProductSelection: [Product.ID: Int] = [:]
    @Published var categoryProductSelection: [Int: [Product.ID: Int]] = [:]

    @Published var currentSpending: Price
    @Published var remainingSpending: Price?
    @Published var requiredTotalSpending: Price?

    @Published var isPromotionRequirementsSatisfied = false

    var displayProductPrices: Bool {
        switch promotion.discountType {
        case .fixedPrice:
            return false

        case .percentage, .amount, .coupon:
            return true


        @unknown default:
            return true
        }
    }

    private let promotion: Inseat.Promotion
    private let coordinator: NavigationCoordinator
    private let cartManager: CartManaging

    private var allAvailableProducts: [Product] = []
    private var cartItems: [Inseat.CartItem] = []

    private var observers: [Inseat.Observer] = []
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Init

    init(promotion: Inseat.Promotion, coordinator: NavigationCoordinator, cartManager: CartManaging = CartManager.shared) {
        self.promotion = promotion
        self.coordinator = coordinator
        self.cartManager = cartManager

        self.promotionInfo = PromotionBuilderContract.PromotionInfo(
            name: promotion.name,
            description: promotion.description,
            discountType: {
                switch promotion.discountType {
                case .percentage(let percentage):
                    return .percentage(percentage)

                case .amount(let discounts):
                    let amount = discounts.first(where: { $0.currency == cartManager.selectedCurrency.code })?.amount ?? .zero
                    return .amount(.init(amount: amount, currency: cartManager.selectedCurrency))

                case .fixedPrice(let fixedPrice):
                    let amount = fixedPrice.first(where: { $0.currency == cartManager.selectedCurrency.code })?.amount ?? .zero
                    return .fixedPrice(.init(amount: amount, currency: cartManager.selectedCurrency))

                case .coupon:
                    return .coupon

                @unknown default:
                    return .percentage(.zero)
                }
            }()
        )
        self.currentSpending = Price(amount: .zero, currency: cartManager.selectedCurrency)
        self.bind()
    }
    
    func onAppear() {
        Task {
            await preparePromotionBuilder()
        }
    }

    private func bind() {
        Publishers.CombineLatest($individualProductSelection, $categoryProductSelection)
            .map { individualProductSelection, categoryProductSelection in
                var result = individualProductSelection
                for (_, categorySelection) in categoryProductSelection {
                    result.merge(categorySelection, uniquingKeysWith: { $0 + $1 })
                }
                return result
            }
            .sink { [weak self] selectedProducts in
                guard let self = self else {
                    return
                }
                let cartItems = selectedProducts.compactMap { (productId, quantity) -> CartItem? in
                    guard let product = self.allAvailableProducts.first(where: { $0.masterId == productId }) else {
                        return nil
                    }
                    return CartItem(
                        id: product.id,
                        masterId: product.masterId,
                        name: product.name,
                        quantity: quantity,
                        prices: [
                            Money(amount: product.price.amount, currency: product.price.currency.code)
                        ]
                    )
                }
                Task {
                    let result = try await InseatAPI.shared.applyPromotion(
                        promotion: self.promotion,
                        to: cartItems,
                        currency: self.cartManager.selectedCurrency.code
                    )

                    await MainActor.run {
                        self.currentSpending = cartItems
                            .compactMap { cartItem in
                                guard let product = self.allAvailableProducts.first(where: { $0.masterId == cartItem.masterId }) else {
                                    return nil
                                }
                                return product.price.multiplied(by: cartItem.quantity)
                            }
                            .sum()
                        ?? Price(amount: .zero, currency: self.cartManager.selectedCurrency)

                        if let requiredTotalSpending = self.requiredTotalSpending {
                            self.remainingSpending = Price(
                                amount: max(Decimal.zero, requiredTotalSpending.amount - self.currentSpending.amount),
                                currency: self.cartManager.selectedCurrency
                            )
                        }

                        self.cartItems = cartItems
                        // This can be implemented either:
                        // - by trying to apply promotion (what we do here)
                        // - or by iterating over all required products and categories and checking 'isSafisfied(_:)'.
                        self.isPromotionRequirementsSatisfied = !result.appliedPromotions.isEmpty
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func preparePromotionBuilder() async {
        Task {
            let allPromotionCategories = try await InseatAPI.shared.fetchPromotionCategories()

            await MainActor.run {
                do {
                    observers = [
                        try InseatAPI.shared.observeProducts { [weak self] products in
                            self?.updatePromotionBuilder(allProducts: products, allPromotionCategories: allPromotionCategories)
                        }
                    ]
                } catch {
                    Logger.log("Failed to register observers: \(error)", level: .error)
                }
            }
        }
    }

    private func updatePromotionBuilder(
        allProducts: [Inseat.Product],
        allPromotionCategories: [Inseat.PromotionCategory]
    ) {
        let allProductsMap: [Product.ID: Inseat.Product] = allProducts.reduce(into: [:]) { $0[$1.masterId] = $1 }

        var allAvailableProducts: [Product] = []
        let requiredCategories: [PromotionBuilderContract.RequiredCategory]
        let requiredIndividualProducts: [PromotionBuilderContract.RequiredIndividualProduct]
        let requiredTotalPrice: Price?

        switch promotion.triggerType {
        case .productPurchase(let trigger):
            requiredIndividualProducts = trigger.items.compactMap { item -> PromotionBuilderContract.RequiredIndividualProduct? in
                guard
                    let rawProduct = allProductsMap[item.masterId],
                    let product = ProductMapper.map(product: rawProduct, selectedCurrency: cartManager.selectedCurrency)
                else {
                    return nil
                }
                allAvailableProducts.append(product)

                return PromotionBuilderContract.RequiredIndividualProduct(product: product, quantity: item.quantity)
            }

            requiredCategories = trigger.categories.compactMap { category -> PromotionBuilderContract.RequiredCategory? in
                guard let promotionCategory = allPromotionCategories.first(where: { $0.categoryId == category.categoryId }) else {
                    return nil
                }
                let promotionCategoryProducts = promotionCategory
                    .items
                    .compactMap { allProductsMap[$0] }
                    .compactMap { product in
                        ProductMapper.map(product: product, selectedCurrency: cartManager.selectedCurrency)
                    }

                guard !promotionCategoryProducts.isEmpty else {
                    Logger.log("Empty list of available products for promotion: id=\(promotion.id); name:'\(promotion.name)'", level: .info)
                    return nil
                }

                allAvailableProducts.append(contentsOf: promotionCategoryProducts)

                return PromotionBuilderContract.RequiredCategory(
                    categoryId: promotionCategory.categoryId,
                    products: promotionCategoryProducts,
                    qualifier: .quantity(category.quantity)
                )
            }
            // It's not needed for product purchase promotions.
            requiredTotalPrice = nil

        case .spendLimit(let trigger):
            guard
                let promotionCategory = allPromotionCategories.first(where: { $0.categoryId == trigger.categoryId }),
                let minimumSpendLimit = trigger.limits.first(where: { $0.currency == cartManager.selectedCurrency.code })
            else {
                return
            }
            let promotionCategoryProducts = promotionCategory
                .items
                .compactMap { allProductsMap[$0] }
                .compactMap { product in
                    ProductMapper.map(product: product, selectedCurrency: cartManager.selectedCurrency)
                }

            allAvailableProducts.append(contentsOf: promotionCategoryProducts)

            requiredIndividualProducts = []

            let requiredSpendLimit = Price(amount: minimumSpendLimit.amount, currency: cartManager.selectedCurrency)
            requiredCategories = [
                PromotionBuilderContract.RequiredCategory(
                    categoryId: trigger.categoryId,
                    products: promotionCategoryProducts,
                    qualifier: .spendLimit(requiredSpendLimit)
                )
            ]
            requiredTotalPrice = requiredSpendLimit

        @unknown default:
            // should never happen.
            return
        }

        self.allAvailableProducts = allAvailableProducts
        self.requiredIndividualProducts = requiredIndividualProducts
        self.requiredCategories = requiredCategories
        self.requiredTotalSpending = requiredTotalPrice
        if let requiredTotalPrice = requiredTotalPrice {
            self.remainingSpending = Price(
                amount: max(Decimal.zero, requiredTotalPrice.amount - self.currentSpending.amount),
                currency: self.cartManager.selectedCurrency
            )
        }
    }

    func remainingQuantity(for individualProduct: PromotionBuilderContract.RequiredIndividualProduct) -> Int {
        let requiredQuantity = individualProduct.quantity
        let totalSelectedQuantiry = individualProductSelection[individualProduct.product.masterId] ?? 0
        return max(0, requiredQuantity - totalSelectedQuantiry)
    }

    func remainingQuantity(for category: PromotionBuilderContract.RequiredCategory) -> Int {
        switch category.qualifier {
        case .quantity(let requiredQuantity):
            let totalSelectedQuantity = category.products
                .compactMap { categoryProductSelection[category.categoryId]?[$0.masterId] }
                .sum()

            return max(0, requiredQuantity - totalSelectedQuantity)

        case .spendLimit:
            // Allow to select as many products as exist in the inventory for SpendLimit-based promotions.
            return 999
        }
    }

    func addToCart() {
        Task {
            await cartManager.updateCart(items: cartItems.compactMap {
                guard let unitPrice = $0.prices.first(where: { $0.currency == cartManager.selectedCurrency.code }) else {
                    return nil
                }
                return Cart.Item(id: $0.id, masterId: $0.masterId, name: $0.name, quantity: $0.quantity, unitPrice: unitPrice.amount)
            })

            await MainActor.run {
                coordinator.navigateToShop()
            }
        }
    }
}
