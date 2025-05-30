import UIKit

struct CheckoutProductItem: Codable, Hashable {
    typealias ID = Int

    let id: ID
    let name: String
    let quantity: Int
    /// Price per single item.
    let unitPrice: Price
}
