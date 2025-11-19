import Foundation
import Combine
import Inseat

final class CheckoutViewModel: CheckoutViewModelInput {

    var displayData: CheckoutContract.DisplayData {
        CheckoutContract.DisplayData(
            cartItems: cart.items.map {
                CheckoutContract.DisplayData.Item(
                    id: $0.id,
                    masterId: $0.masterId,
                    name: $0.name,
                    quantity: $0.quantity,
                    unitPrice: Price(amount: $0.unitPrice, currency: cart.currency)
                )
            },
            subtotalPrice: cartManager.subtotal(in: cart),
            totalSaving: cartManager.savings(in: cart),
            appliedPromotions: cart.appliedPromotions.map {
                CheckoutContract.DisplayData.AppliedPromotion(
                    id: $0.promotion.id,
                    name: $0.promotion.name
                )
            },
            totalPrice: cartManager.total(in: cart)
        )
    }

    @Published var seatNumber: String = ""
    @Published var isSeatNumberValid: Bool = false

    private let cart: Cart

    private let cartManager: CartManaging

    private let coordinator: NavigationCoordinator

    private var cancellables: Set<AnyCancellable> = []

    init(
        cartManager: CartManaging = CartManager.shared,
        coordinator: NavigationCoordinator
    ) {
        self.cart = cartManager.currentCart
        self.cartManager = cartManager
        self.coordinator = coordinator

        bind()
    }

    private func bind() {
        $seatNumber
            .map { seatNumber in
                let regex = /^([1-9]+[A-Z])$/
                return (try? regex.wholeMatch(in: seatNumber)) != nil
            }
            .removeDuplicates()
            .sink { [weak self] isValid in
                self?.isSeatNumberValid = isValid
            }
            .store(in: &cancellables)
    }

    func onAppear() {
    }

    func makeOrder() {
        Task {
            guard let shiftId = try await InseatAPI.shared.fetchShop()?.shiftId else {
                return
            }
            do {
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
                            price: Inseat.Order.Price(amount: $0.unitPrice)
                        )
                    },
                    appliedPromotions: cart.appliedPromotions,
                    orderCurrency: cart.currency.code,
                    totalPrice: .init(amount: cart.totalPrice),
                    createdAt: Date(),
                    updatedAt: Date()
                )
                try await InseatAPI.shared.createOrder(order)

                await MainActor.run {
                    cartManager.resetCart()
                    coordinator.navigateToShop()
                }

            } catch {
                Logger.log("Error while creating order: '\(error)'", level: .error)
            }
        }
    }
}
