import SwiftUI

final class PromotionsRouter: ObservableObject {

    enum Destination: Codable, Hashable {
        case promotionBuilder
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
