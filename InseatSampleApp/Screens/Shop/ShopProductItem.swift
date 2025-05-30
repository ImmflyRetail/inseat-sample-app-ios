import UIKit

struct ShopProductItem {
    typealias ID = Int

    let id: ID
    let image: UIImage?
    let categoryId: Int
    let name: String
    let availableQuantity: Int
    let price: Price
}
