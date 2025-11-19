import Foundation
import Combine
import Inseat

final class ShopViewModel: ShopViewModelInput {

    @Published var shopStatus: ShopContract.ShopStatus = .closed

    @Published var products: [ShopContract.Product] = []

    @Published var selectedProducts: [ShopContract.Product.ID: Int] = [:] {
        didSet {
            var cartItems = [Cart.Item]()
            for (productId, quantity) in selectedProducts {
                guard let product = stockManager.product(id: productId) else {
                    continue
                }
                let cartItem = Cart.Item(
                    id: productId,
                    masterId: product.masterId,
                    name: product.name,
                    quantity: quantity,
                    unitPrice: product.price.amount
                )
                cartItems.append(cartItem)
            }
            Task {
                await cartManager.updateCart(items: cartItems)
            }
        }
    }

    @Published var categories: [Category] = []

    @Published var selectedCategory: Category?

    @Published var ordersCount: Int = 0

    var isSelectionAllowedWhenShopClosed: Bool {
        return AppSettings.isOrdersEnabledWhenShopClosed
    }

    private var allProducts: [ShopContract.Product] = []

    private let cartManager: CartManaging
    private let stockManager: StockManaging
    private let orderManager: OrderManaging

    // Observer is cancelled after this reference is removed from memory.
    private var shopObserver: Observer?
    private var productsObserver: Observer?

    private var cancellables: Set<AnyCancellable> = []

    init(
        cartManager: CartManaging = CartManager.shared,
        stockManager: StockManaging = StockManager.shared,
        orderManager: OrderManaging = OrderManager.shared
    ) {
        self.cartManager = cartManager
        self.stockManager = stockManager
        self.orderManager = orderManager
        bind()
    }

    private func bind() {
        $selectedCategory
            .sink { [weak self] category in
                guard let self = self else {
                    return
                }
                self.products = self.allProducts.filter {
                    if let id = category?.id {
                        return $0.categoryId == id
                    }
                    return true
                }
            }
            .store(in: &cancellables)

        orderManager
            .orders
            .map { $0.count }
            .sink { [weak self] count in
                self?.ordersCount = count
            }
            .store(in: &cancellables)

        // It's included only for testing purposes to test fetching methods separately.
        AppSettings
            .automaticDataRefreshEnabled
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] automaticDataRefreshEnabled in
                if automaticDataRefreshEnabled {
                    self?.addObservers()
                } else {
                    self?.removeObservers()
                }
            }
            .store(in: &cancellables)
    }

    func onAppear() {
        addObservers()
        updateProductsFromCart()
    }

    func refresh() async {
        do {
            async let shopQuery = try InseatAPI.shared.fetchShop()
            async let productsQuery = try InseatAPI.shared.fetchProducts()
            async let categoriesQuery = try await InseatAPI.shared.fetchCategories()

            let (shop, products, categories) = try await (shopQuery, productsQuery, categoriesQuery)

            await MainActor.run {
                handleShop(shop)
                handleProducts(products)
                handleCategories(categories)
            }
        } catch {
            Logger.log("Error while refreshing: \(error)", level: .error)
        }
    }

    private func updateProductsFromCart() {
        selectedProducts = cartManager.currentCart.items.reduce(into: [:]) { $0[$1.id] = $1.quantity }
    }

    private func addObservers() {
        do {
            guard productsObserver == nil else {
                return
            }
            orderManager.observeOrders()
            shopObserver = try InseatAPI.shared.observeShop { [weak self] shop in
                self?.handleShop(shop)
            }
            productsObserver = try InseatAPI.shared.observeProducts { [weak self] products in
                self?.handleProducts(products)
            }
            Task {
                let categories = try await InseatAPI.shared.fetchCategories()
                await MainActor.run {
                    self.handleCategories(categories)
                }
            }

        } catch {
            Logger.log("Error while registering observers: '\(error)'", level: .error)
        }
    }

    private func removeObservers() {
        shopObserver = nil
        productsObserver = nil
    }

    private func handleShop(_ shop: Inseat.Shop?) {
        guard let shop = shop else {
            shopStatus = .unavailable
            return
        }
        switch shop.status {
        case .open:
            shopStatus = .open

        case .order:
            shopStatus = .open

        case .closed:
            shopStatus = .closed

        @unknown default:
            break
        }
    }

    private func handleProducts(_ products: [Inseat.Product]) {
        let now = Date()
        let products = products
            .sorted(by: { $0.name < $1.name })
            .filter { ($0.startDate...$0.endDate).contains(now) }
            .compactMap {
                ProductMapper.map(product: $0, selectedCurrency: cartManager.selectedCurrency)
            }

        stockManager.setAvailableProducts(products: products)

        self.allProducts = products.map {
            ShopContract.Product(
                id: $0.id,
                image: $0.image,
                categoryId: $0.categoryId,
                name: $0.name,
                availableQuantity: $0.availableQuantity,
                price: $0.price
            )
        }
        self.products = self.allProducts.filter {
            if let id = selectedCategory?.id {
                return $0.categoryId == id
            }
            return true
        }
    }

    private func handleCategories(_ categories: [Inseat.Category]) {
        self.categories = categories
            .flatMap { $0.subcategories.isEmpty ? [$0] : $0.subcategories }
            .sorted(by: { ($0.sortOrder ?? 0) < ($1.sortOrder ?? 0) })
            .map { Category(id: $0.categoryId, name: $0.name) }
    }
}
