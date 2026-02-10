import Combine

@MainActor
protocol CheckoutViewModelInput: ObservableObject {
    var displayData: CheckoutContract.DisplayData { get }
    var seatNumber: String { get set }
    var isSeatNumberValid: Bool { get }

    func onAppear()
    func makeOrder()
}
