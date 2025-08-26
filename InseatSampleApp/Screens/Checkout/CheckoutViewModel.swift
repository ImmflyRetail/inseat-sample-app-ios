import Foundation
import Combine
import Inseat

protocol CheckoutViewModelInput: ObservableObject {
    var cartItems: [CheckoutProductItem] { get }
    var totalPrice: Price { get }

    var seatNumber: String { get set }

    func onAppear()
    func makeOrder()
}

final class CheckoutViewModel: CheckoutViewModelInput {

    let cartItems: [CheckoutProductItem]

    let totalPrice: Price

    @Published var seatNumber: String = ""

    private let router: CartRouter

    private let cartManager: CartManaging

    init(
        router: CartRouter,
        cartItems: [CheckoutProductItem],
        cartManager: CartManaging = CartManager.shared,
        cartCalculator: CartCalculating = CartCalculator()
    ) {
        self.router = router
        self.cartItems = cartItems
        self.totalPrice = cartCalculator.totalPrice(for: cartItems)
        self.cartManager = cartManager
    }

    func onAppear() { }

    func makeOrder() {
        let cart = Cart(
            items: cartItems,
            totalPrice: totalPrice,
            seatNumber: seatNumber
        )

        Task {
            guard let shiftId = try await InseatAPI.shared.fetchShop()?.shiftId else {
                return
            }
            let order = Inseat.Order(
                id: UUID().uuidString,
                shiftId: shiftId,
                seatNumber: cart.seatNumber,
                status: .placed,
                items: cart.items.map {
                    Inseat.Order.Item(
                        id: $0.id,
                        name: $0.name,
                        quantity: $0.quantity,
                        price: Inseat.Order.Price(amount: $0.unitPrice.amount)
                    )
                },
                orderCurrency: cart.totalPrice.currencyCode,
                totalPrice: .init(amount: cart.totalPrice.amount),
                createdAt: Date(),
                updatedAt: Date()
            )
            try await InseatAPI.shared.createOrder(order)

            cartManager.resetCart()

            await MainActor.run {
                router.navigateToRoot()
            }
        }
    }
}
