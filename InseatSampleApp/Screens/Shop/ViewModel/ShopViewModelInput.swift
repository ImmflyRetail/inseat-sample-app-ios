import Combine

protocol ShopViewModelInput: ObservableObject {
    var shopStatus: ShopContract.ShopStatus { get }
    var products: [ShopContract.Product] { get }
    var selectedProducts: [ShopContract.Product.ID: Int] { get set }

    var categories: [Category] { get }
    var selectedCategory: Category? { get set }
    var ordersCount: Int { get }
    var isSelectionAllowedWhenShopClosed: Bool { get }

    func onAppear()
    func refresh() async
}
