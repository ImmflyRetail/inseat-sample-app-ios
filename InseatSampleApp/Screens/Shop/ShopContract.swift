import UIKit

enum ShopContract {

    struct Product: Identifiable, Equatable {
        typealias ID = Int

        let id: ID
        let image: UIImage?
        let categoryId: Int
        let name: String
        let description: String
        let availableQuantity: Int
        let price: Price
    }

    enum ShopStatus {
        case unavailable
        case browse
        case order
        case closed

        var displayName: String {
            switch self {
            case .unavailable: return "Closed"
            case .browse: return "Open to browse"
            case .order: return "Open"
            case .closed: return "Closed"
            }
        }
    }

    struct Section: Identifiable, Equatable {

        enum SectionType: Equatable {
            case products(category: Category)
            case promotions
        }

        let type: SectionType
        let index: Int

        var id: String {
            switch type {
            case .products(let category):
                return String(category.id)
            case .promotions:
                return "promotions"
            }
        }

        var title: String {
            switch type {
            case .products(let category):
                return category.name
            case .promotions:
                return "Promotions"
            }
        }
    }
}
