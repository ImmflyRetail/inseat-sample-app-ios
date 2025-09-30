import Combine
import Inseat

protocol CartViewModelInput: ObservableObject {
    var products: [CartProductItem] { get }
    var selectedProducts: [CartProductItem.ID: Int] { get set }
    var appliedPromotions: [CartAppliedPromotion] { get }
    var totalSaving: Price? { get }
    var subtotalPrice: Price { get }
    var totalPrice: Price { get }
    var currentCart: Cart { get }
    var isOrdersEnabled: Bool { get }

    func onAppear()
}

final class CartViewModel: CartViewModelInput {

    @Published var products: [CartProductItem] = []

    @Published var selectedProducts: [CartProductItem.ID: Int] = [:] {
        didSet {
            cartManager.updateCart(products: selectedProducts)
            updateSelectedProducts()
        }
    }

    @Published var appliedPromotions: [CartAppliedPromotion] = []
    private var rawAppliedPromotions: [AppliedPromotion] = []

    @Published var totalSaving: Price?

    @Published var subtotalPrice: Price = Price(amount: .zero, currencyCode: "EUR")
    @Published var totalPrice: Price = Price(amount: .zero, currencyCode: "EUR")

    @Published var isOrdersEnabled = false

    var currentCart: Cart {
        let cartItems: [CheckoutProductItem] = cartManager.allProducts
            .compactMap {
                guard let quantity = selectedProducts[$0.id] else {
                    return nil
                }
                return CheckoutProductItem(id: $0.id, name: $0.name, quantity: quantity, unitPrice: $0.price)
            }

        return Cart(items: cartItems, appliedPromotions: rawAppliedPromotions, totalPrice: totalPrice)
    }

    private let cartManager: CartManaging

    private var shopObserver: Inseat.Observer?

    init(cartManager: CartManaging = CartManager.shared) {
        self.cartManager = cartManager
    }

    private func updateSelectedProducts() {
        products = cartManager.allProducts
            .filter { selectedProducts[$0.id] != nil }
            .map { CartProductItem(id: $0.id, masterId: $0.masterId, image: $0.image, name: $0.name, availableQuantity: $0.availableQuantity, price: $0.price) }

        let cartItems = products.map {
            Inseat.CartItem(
                id: $0.id,
                masterId: $0.masterId,
                name: $0.name,
                quantity: selectedProducts[$0.id] ?? 0,
                prices: [Inseat.Money(amount: $0.price.amount, currency: $0.price.currencyCode)]
            )
        }
        Task {
            let promotionResult = try await InseatAPI.shared.applyPromotions(
                to: cartItems,
                currency: "EUR"
            )
            await MainActor.run {
                self.rawAppliedPromotions = promotionResult.appliedPromotions
                self.appliedPromotions = promotionResult.appliedPromotions.map {
                    CartAppliedPromotion(
                        id: $0.promotion.id,
                        name: $0.promotion.name,
                        saving: $0.totalSaving.map {
                            Price(amount: $0.amount, currencyCode: $0.currency)
                        }
                        ?? Price(amount: .zero, currencyCode: "EUR")
                    )
                }
                let totalSavingAmount = promotionResult.appliedPromotions.compactMap { $0.totalSaving }.map { $0.amount }.reduce(.zero, +)

                self.totalSaving = totalSavingAmount > .zero ? Price(amount: totalSavingAmount, currencyCode: cartManager.totalPrice.currencyCode) : nil

                self.subtotalPrice = cartManager.totalPrice
                self.totalPrice = Price(amount: cartManager.totalPrice.amount - totalSavingAmount, currencyCode: cartManager.totalPrice.currencyCode)
            }
        }
    }

    func onAppear() {
        selectedProducts = cartManager.selectedProducts
        updateSelectedProducts()

        do {
            shopObserver = try InseatAPI.shared.observeShop { [weak self] shop in
                self?.isOrdersEnabled = shop?.status == .open || shop?.status == .order
            }
        } catch {
            print("[DEBUG] Error while registering observer for shop: \(error)")
        }
    }
}
