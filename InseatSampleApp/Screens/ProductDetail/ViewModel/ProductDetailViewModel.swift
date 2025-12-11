import Combine
import SwiftUI
import Inseat

protocol ProductDetailViewModelInput: ObservableObject {
    var product: ProductDetailContract.Product? { get }
    var shopStatus: ProductDetailContract.ShopStatus { get }
    var quantity: Int { get set }
    var isSelectionAllowedWhenShopClosed: Bool { get }

    func onAppear()
    func confirm()
}

final class ProductDetailViewModel: ProductDetailViewModelInput {

    @Published var product: ProductDetailContract.Product?
    @Published var shopStatus: ProductDetailContract.ShopStatus = .unavailable
    @Published var quantity = 0

    var isSelectionAllowedWhenShopClosed: Bool {
        return AppSettings.isOrdersEnabledWhenShopClosed
    }

    private let cartManager: CartManaging
    @Binding private var quantityBinding: Int

    // Observer is cancelled after this reference is removed from memory.
    private var shopObserver: Observer?
    private var productsObserver: Observer?

    init(
        product: ProductDetailContract.Product,
        shopStatus: ProductDetailContract.ShopStatus,
        quantity: Binding<Int>,
        cartManager: CartManaging = CartManager.shared
    ) {
        self.product = product
        self.shopStatus = shopStatus
        self.quantity = quantity.wrappedValue
        self._quantityBinding = quantity
        self.cartManager = cartManager
    }

    func onAppear() {
        addObservers()
    }

    func confirm() {
        quantityBinding = quantity
    }

    // MARK: - Observers

    private func addObservers() {
        do {
            guard productsObserver == nil else {
                return
            }
            shopObserver = try InseatAPI.shared.observeShop { [weak self] shop in
                self?.handleShop(shop)
            }
            productsObserver = try InseatAPI.shared.observeProducts { [weak self] products in
                self?.handleProducts(products)
            }
        } catch {
            Logger.log("Error while registering observers: '\(error)'", level: .error)
        }
    }

    // MARK: - Handle Incoming Data

    private func handleShop(_ shop: Inseat.Shop?) {
        guard let shop = shop else {
            shopStatus = .unavailable
            return
        }
        switch shop.status {
        case .open:
            shopStatus = .browse

        case .order:
            shopStatus = .order

        case .closed:
            shopStatus = .closed

        @unknown default:
            shopStatus = .unavailable
        }
    }

    private func handleProducts(_ products: [Inseat.Product]) {
        let now = Date()
        let updatedProduct = products
            .filter { ($0.startDate...$0.endDate).contains(now) && $0.id == self.product?.id }
            .compactMap {
                ProductMapper.map(product: $0, selectedCurrency: cartManager.selectedCurrency)
            }
            .first

        guard let updatedProduct = updatedProduct else {
            self.product = nil
            return
        }
        self.product = ProductDetailContract.Product(
            id: updatedProduct.id,
            image: updatedProduct.image,
            name: updatedProduct.name,
            description: updatedProduct.description,
            availableQuantity: updatedProduct.availableQuantity,
            price: updatedProduct.price
        )
    }
}
