import Combine
import Inseat

protocol OrdersViewModelInput: ObservableObject {
    var orders: [Order] { get }

    func onAppear()
    func delete(orderId: Order.ID)
}

final class OrdersViewModel: OrdersViewModelInput {

    @Published private(set) var orders: [Order] = []

    // Observer is cancelled after this reference is removed from memory.
    private var ordersObserver: Observer?

    init() { }

    func onAppear() {
        addObservers()
    }

    private func addObservers() {
        do {
            guard ordersObserver == nil else {
                return
            }
            ordersObserver = try InseatAPI.shared.observeOrders { [weak self] orders in
                self?.orders = orders.map { order in
                    Order(
                        id: order.id,
                        seatNumber: order.seatNumber,
                        items: order.items.map {
                            .init(
                                id: $0.id,
                                name: $0.name,
                                quantity: $0.quantity,
                                unitPrice: .init(amount: $0.price.amount, currencyCode: order.orderCurrency)
                            )
                        },
                        totalPrice: .init(amount: order.totalPrice.amount, currencyCode: order.orderCurrency),
                        status: {
                            switch order.status {
                            case .placed:
                                return .placed
                            case .received:
                                return .received
                            case .preparing:
                                return .preparing
                            case .cancelledByCrew:
                                return .cancelledByCrew
                            case .cancelledByPassenger:
                                return .cancelledByPassenger
                            case .cancelledByTimeout:
                                return .cancelledByTimeout
                            case .completed:
                                return .completed
                            @unknown default:
                                return .placed
                            }
                        }(),
                        createdAt: order.createdAt
                    )
                }
            }

        } catch {
            print("[OBSERVE ORDERS] error: '\(error)'")
        }
    }

    func delete(orderId: Order.ID) {
        Task {
            try await InseatAPI.shared.cancelOrder(id: orderId)
        }
    }
}
