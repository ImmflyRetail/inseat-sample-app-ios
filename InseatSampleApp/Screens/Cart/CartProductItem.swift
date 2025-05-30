import UIKit

struct CartProductItem {
    typealias ID = Int

    let id: ID
    let image: UIImage?
    let name: String
    let availableQuantity: Int
    let price: Price
}
