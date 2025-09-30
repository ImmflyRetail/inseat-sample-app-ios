import UIKit

struct CartProductItem {
    typealias ID = Int

    let id: ID
    let masterId: ID
    let image: UIImage?
    let name: String
    let availableQuantity: Int
    let price: Price
}

struct CartAppliedPromotion {
    let id: Int
    let name: String
    let saving: Price?
}
