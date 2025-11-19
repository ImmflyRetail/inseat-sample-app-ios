import Combine
import Inseat

protocol OrderStatusViewModelInput: ObservableObject {
    var order: Order { get }

    func onAppear()
    func cancelOrder()
}

final class OrderStatusViewModel: OrderStatusViewModelInput {

    @Published private(set) var order: Order

    // Observer is cancelled after this reference is removed from memory.
    private var ordersObserver: Observer?

    init(order: Order) {
        self.order = order
    }

    func onAppear() {
        addObservers()
    }

    private func addObservers() {
        do {
            guard ordersObserver == nil else {
                return
            }
            let orderId = order.id
            ordersObserver = try InseatAPI.shared.observeOrders { [weak self] orders in
                let order = orders.first { $0.id == orderId }.map { OrderMapper.map(order: $0) }
                if let order = order {
                    self?.order = order
                }
            }
        } catch {
            Logger.log("Error while registering observer for orders: \(error)", level: .error)
        }
    }

    func cancelOrder() {
        Task {
            try await InseatAPI.shared.cancelOrder(id: order.id)
        }
    }
}
