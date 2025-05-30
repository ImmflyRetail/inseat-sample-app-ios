import Foundation

protocol CartManaging {
    var totalPrice: Price { get }
    var selectedProducts: [Product.ID: Int] { get }
    var allProducts: [Product] { get }

    func setAvailableProducts(products: [Product])
    func updateCart(products: [Product.ID: Int])
    func resetCart()
}

final class CartManager: CartManaging {

    static let shared = CartManager()

    private(set) var totalPrice: Price = Price(amount: .zero, currencyCode: "EUR")

    private(set) var selectedProducts: [CartProductItem.ID: Int] = [:] {
        didSet {
            updateTotal()
        }
    }

    private(set) var allProducts: [Product] = []

    private var allProductsMap: [Product.ID: Product] = [:]

    private init() { }

    func setAvailableProducts(products: [Product]) {
        allProducts = products
        allProductsMap = products.reduce(into: [Product.ID: Product]()) { $0[$1.id] = $1 }
    }

    func updateCart(products: [CartProductItem.ID: Int]) {
        selectedProducts = products
    }

    private func updateTotal() {
        let amount = selectedProducts.reduce(into: Decimal.zero) {
            let price = (allProductsMap[$1.key]?.price.amount ?? .zero) * Decimal($1.value)
            $0 += price
        }
        totalPrice = Price(amount: amount, currencyCode: "EUR")
    }

    func resetCart() {
        selectedProducts = [:]
    }
}
