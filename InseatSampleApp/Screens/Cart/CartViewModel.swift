import Combine
import Inseat

protocol CartViewModelInput: ObservableObject {
    var products: [CartProductItem] { get }
    var selectedProducts: [CartProductItem.ID: Int] { get set }
    var totalPrice: Price { get }
    var isOrdersEnabled: Bool { get }

    func onAppear()
    func checkout() -> [CheckoutProductItem]
}

final class CartViewModel: CartViewModelInput {

    @Published var products: [CartProductItem] = []

    @Published var selectedProducts: [CartProductItem.ID: Int] = [:] {
        didSet {
            cartManager.updateCart(products: selectedProducts)
            updateSelectedProducts()
        }
    }

    @Published var totalPrice: Price = Price(amount: .zero, currencyCode: "EUR")

    @Published var isOrdersEnabled = false

    private let cartManager: CartManaging

    private var shopObserver: Inseat.Observer?

    init(cartManager: CartManaging = CartManager.shared) {
        self.cartManager = cartManager
    }

    private func updateSelectedProducts() {
        products = cartManager.allProducts
            .filter { selectedProducts[$0.id] != nil }
            .map { CartProductItem(id: $0.id, image: $0.image, name: $0.name, availableQuantity: $0.availableQuantity, price: $0.price) }
        
        totalPrice = cartManager.totalPrice
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

    func checkout() -> [CheckoutProductItem] {
        return cartManager.allProducts
            .compactMap {
                guard let quantity = selectedProducts[$0.id] else {
                    return nil
                }
                return CheckoutProductItem(id: $0.id, name: $0.name, quantity: quantity, unitPrice: $0.price)
            }
    }
}
