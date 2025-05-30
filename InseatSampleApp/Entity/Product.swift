import UIKit

struct Product {
    typealias ID = Int
    
    let id: Int
    let image: UIImage?
    let name: String
    let availableQuantity: Int
    let price: Price
}
