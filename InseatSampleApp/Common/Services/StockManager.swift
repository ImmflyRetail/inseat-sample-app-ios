protocol StockManaging {
    var allProducts: [Product] { get }

    func setAvailableProducts(products: [Product])
    func product(id: Product.ID) -> Product?
}

final class StockManager: StockManaging {

    static let shared: StockManaging = StockManager()

    private init() { }

    private(set) var allProducts: [Product] = []

    private var allProductsMap: [Product.ID: Product] = [:]

    func setAvailableProducts(products: [Product]) {
        allProducts = products
        allProductsMap = products.reduce(into: [Product.ID: Product]()) { $0[$1.id] = $1 }
    }

    func product(id: Product.ID) -> Product? {
        return allProductsMap[id]
    }
}
