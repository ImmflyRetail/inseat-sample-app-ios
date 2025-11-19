import UIKit

struct Product {
    typealias ID = Int
    
    let id: Int
    let masterId: Int
    let categoryId: Int
    let image: UIImage?
    let name: String
    let description: String
    let availableQuantity: Int
    let price: Price
}
