import SwiftUI

final class CartRouter: ObservableObject {

    enum Destination: Codable, Hashable {
        case checkout(items: [CheckoutProductItem])
    }

    @Published var navPath = NavigationPath()

    func navigate(to destination: Destination) {
        navPath.append(destination)
    }

    func navigateBack() {
        navPath.removeLast()
    }

    func navigateToRoot() {
        navPath.removeLast(navPath.count)
    }
}
