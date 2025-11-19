import Combine
import Inseat

final class CartViewModel: CartViewModelInput {

    @Published var products: [CartContract.Product] = []

    @Published var selectedProducts: [CartContract.Product.ID: Int] = [:] {
        didSet {
            updateSelectedProducts()
        }
    }

    @Published var appliedPromotions: [CartContract.AppliedPromotion] = []

    @Published var totalSaving: Price?
    @Published var subtotalPrice: Price = .zero(in: .eur)
    @Published var totalPrice: Price = .zero(in: .eur)

    @Published var isOrdersEnabled = false

    var currentCart: Cart {
        return cartManager.currentCart
    }

    private let cartManager: CartManaging
    private let stockManager: StockManaging

    private var shopObserver: Inseat.Observer?

    init(
        cartManager: CartManaging = CartManager.shared,
        stockManager: StockManaging = StockManager.shared
    ) {
        self.cartManager = cartManager
        self.stockManager = stockManager
    }

    private func updateSelectedProducts() {
        products = stockManager.allProducts
            .filter { selectedProducts[$0.id] != nil }
            .map {
                CartContract.Product(
                    id: $0.id,
                    masterId: $0.masterId,
                    image: $0.image,
                    name: $0.name,
                    availableQuantity: $0.availableQuantity,
                    price: $0.price
                )
            }

        let cartItems = products.map {
            Cart.Item(
                id: $0.id,
                masterId: $0.masterId,
                name: $0.name,
                quantity: selectedProducts[$0.id] ?? 0,
                unitPrice: $0.price.amount
            )
        }
        Task {
            await cartManager.updateCart(items: cartItems)

            await MainActor.run {
                self.appliedPromotions = cartManager.currentCart.appliedPromotions.map {
                    CartContract.AppliedPromotion(
                        id: $0.promotion.id,
                        name: $0.promotion.name
                    )
                }
                self.totalSaving = cartManager.savings(in: currentCart)
                self.subtotalPrice = cartManager.subtotal(in: currentCart)
                self.totalPrice = cartManager.total(in: currentCart)
            }
        }
    }

    func onAppear() {
        selectedProducts = cartManager.currentCart.items.reduce(into: [:]) { $0[$1.id] = $1.quantity }
        updateSelectedProducts()

        do {
            shopObserver = try InseatAPI.shared.observeShop { [weak self] shop in
                self?.isOrdersEnabled = shop?.status == .open || shop?.status == .order || AppSettings.isOrdersEnabledWhenShopClosed
            }
        } catch {
            Logger.log("Error while registering observer for shop: \(error)", level: .error)
        }
    }
}
