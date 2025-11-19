import Combine

protocol CartViewModelInput: ObservableObject {
    var products: [CartContract.Product] { get }

    var selectedProducts: [CartContract.Product.ID: Int] { get set }
    var appliedPromotions: [CartContract.AppliedPromotion] { get }

    var totalSaving: Price? { get }
    var subtotalPrice: Price { get }
    var totalPrice: Price { get }

    var isOrdersEnabled: Bool { get }

    func onAppear()
}
