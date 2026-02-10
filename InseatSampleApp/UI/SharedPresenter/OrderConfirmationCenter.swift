import SwiftUI

@MainActor
final class OrderConfirmationCenter: ObservableObject {

    static let shared = OrderConfirmationCenter()

    @Published var isPresented: Bool = false

    private init() {}

    func present() {
        isPresented = true
    }

    func dismiss() {
        isPresented = false
    }
}
