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
                self?.orders = orders
                    .map { OrderMapper.map(order: $0) }
                    .sorted(by: { $0.createdAt > $1.createdAt })
            }

        } catch {
            Logger.log("Error while registering observer for orders: \(error)", level: .error)
        }
    }

    func delete(orderId: Order.ID) {
        Task {
            try await InseatAPI.shared.cancelOrder(id: orderId)
        }
    }
}
