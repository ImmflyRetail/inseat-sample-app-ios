import SwiftUI
import Inseat

final class ShopRouter: ObservableObject, NavigationCoordinator {

    enum MenuDestination: Codable, Hashable {
        case shop
    }

    enum ShopDestination: Codable, Hashable {
        case cart
        case orders
    }

    enum CartDestination: Codable, Hashable {
        case checkout
    }

    enum OrderDestination: Codable, Hashable {
        case orderStatus(order: Order)
    }

    enum PromotionDestination: Codable, Hashable {
        case promotionBuilder(promotion: Inseat.Promotion)
    }

    @Published var navPath = NavigationPath()

    func navigate(to destination: MenuDestination) {
        navPath.append(destination)
    }

    func navigate(to destination: ShopDestination) {
        navPath.append(destination)
    }

    func navigate(to destination: CartDestination) {
        navPath.append(destination)
    }

    func navigate(to destination: OrderDestination) {
        navPath.append(destination)
    }

    func navigate(to destination: PromotionDestination) {
        navPath.append(destination)
    }

    func navigateBack() {
        navPath.removeLast()
    }

    func navigateToShop() {
        navPath.removeLast(navPath.count - 1)
    }

    func navigateToRoot() {
        navPath.removeLast(navPath.count)
    }
}
