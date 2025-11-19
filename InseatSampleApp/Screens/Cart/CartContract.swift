import UIKit

enum CartContract {

    struct Product {
        typealias ID = Int

        let id: ID
        let masterId: ID
        let image: UIImage?
        let name: String
        let availableQuantity: Int
        let price: Price
    }

    struct AppliedPromotion {
        let id: Int
        let name: String
    }
}
