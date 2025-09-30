import Foundation
import Combine
import Inseat

protocol CheckoutViewModelInput: ObservableObject {
    var cartItems: [CheckoutProductItem] { get }
    var totalSaving: Price? { get }
    var totalPrice: Price { get }

    var seatNumber: String { get set }

    func onAppear()
    func makeOrder()
}

final class CheckoutViewModel: CheckoutViewModelInput {

    var cartItems: [CheckoutProductItem] {
        cart.items
    }

    var totalSaving: Price? {
        let amount = cart
            .appliedPromotions
            .compactMap { $0.totalSaving?.amount }
            .reduce(into: Decimal.zero) { $0 += $1 }

        if amount > .zero {
            return Price(amount: amount, currencyCode: totalPrice.currencyCode)
        }
        return nil
    }

    var totalPrice: Price {
        cart.totalPrice
    }

    @Published var seatNumber: String = ""

    private let cart: Cart

    private let router: CartRouter

    private let cartManager: CartManaging

    init(
        cart: Cart,
        router: CartRouter,
        cartManager: CartManaging = CartManager.shared
    ) {
        self.cart = cart
        self.router = router
        self.cartManager = cartManager
    }

    func onAppear() { }

    func makeOrder() {
        Task {
            guard let shiftId = try await InseatAPI.shared.fetchShop()?.shiftId else {
                return
            }
            let order = Inseat.Order(
                id: UUID().uuidString,
                shiftId: shiftId,
                seatNumber: seatNumber,
                status: .placed,
                items: cart.items.map {
                    Inseat.Order.Item(
                        id: $0.id,
                        name: $0.name,
                        quantity: $0.quantity,
                        price: Inseat.Order.Price(amount: $0.unitPrice.amount)
                    )
                },
                appliedPromotions: cart.appliedPromotions,
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
