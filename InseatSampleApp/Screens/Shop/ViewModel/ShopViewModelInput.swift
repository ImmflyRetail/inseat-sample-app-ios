import Combine

protocol ShopViewModelInput: ObservableObject {
    var shopStatus: ShopContract.ShopStatus { get }
    var selectedProducts: [ShopContract.Product.ID: Int] { get set }

    var categories: [Category] { get }
    var ordersCount: Int { get }
    var isSelectionAllowedWhenShopClosed: Bool { get }

    func onAppear()
    func refresh() async
    func products(for category: Category) -> [ShopContract.Product]
}
