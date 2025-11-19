import Combine
import Inseat

protocol OrderManaging {
    var orders: CurrentValueSubject<[Order], Never> { get }

    func observeOrders()
    func order(with id: Order.ID) -> Order?
}

final class OrderManager: OrderManaging {

    static let shared: OrderManaging = OrderManager()

    let orders = CurrentValueSubject<[Order], Never>([])

    private var ordersObserver: Inseat.Observer?

    private init() { }

    func observeOrders() {
        guard ordersObserver == nil else {
            return
        }
        do {
            ordersObserver = try InseatAPI.shared.observeOrders { [weak self] orders in
                self?.orders.value = orders.map { OrderMapper.map(order: $0) }
            }
        } catch {
            Logger.log("Error while registering observer for orders: \(error)", level: .error)
        }
    }

    func order(with id: Order.ID) -> Order? {
        return orders.value.first { $0.id == id }
    }
}
