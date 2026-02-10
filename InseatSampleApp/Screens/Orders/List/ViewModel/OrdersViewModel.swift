import Combine
import Inseat

@MainActor
protocol OrdersViewModelInput: ObservableObject {
    var orders: [Order] { get }

    var isCancelAlertPresented: Bool { get set }
    var cancelCandidateOrderId: Order.ID? { get }

    func onAppear()

    // Cancel flow
    func requestCancel(orderId: Order.ID)
    func confirmCancel()
    func dismissCancel()
}

@MainActor
final class OrdersViewModel: OrdersViewModelInput {

    @Published private(set) var orders: [Order] = []

    @Published var isCancelAlertPresented: Bool = false
    @Published private(set) var cancelCandidateOrderId: Order.ID? = nil

    // Observer is cancelled after this reference is removed from memory.
    private var ordersObserver: Observer?

    init() {}

    func onAppear() {
        addObservers()
    }

    private func addObservers() {
        do {
            guard ordersObserver == nil else { return }

            ordersObserver = try InseatAPI.shared.observeOrders { [weak self] orders in
                guard let self else { return }

                let mapped = orders
                    .map { OrderMapper.map(order: $0) }
                    .sorted(by: { $0.createdAt > $1.createdAt })

                self.orders = mapped
            }
        } catch {
            Logger.log("Error while registering observer for orders: \(error)", level: .error)
        }
    }

    // MARK: - Cancel flow

    func requestCancel(orderId: Order.ID) {
        cancelCandidateOrderId = orderId
        isCancelAlertPresented = true
    }

    func dismissCancel() {
        isCancelAlertPresented = false
        cancelCandidateOrderId = nil
    }

    func confirmCancel() {
        guard let id = cancelCandidateOrderId else {
            dismissCancel()
            return
        }

        dismissCancel()

        Task {
            do {
                try await InseatAPI.shared.cancelOrder(id: id)
            } catch {
                Logger.log("Error while cancelling order: \(error)", level: .error)
            }
        }
    }
}
