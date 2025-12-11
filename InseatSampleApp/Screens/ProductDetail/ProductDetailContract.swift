import UIKit

enum ProductDetailContract {

    struct Product {
        let id: Int
        let image: UIImage?
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
    }
}
