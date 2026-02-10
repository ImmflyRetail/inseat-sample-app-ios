import SwiftUI

enum ShopSheet: Identifiable {
    case product(ShopContract.Product)
    case orderConfirmation

    var id: String {
        switch self {
        case .product(let product):
            return "product_\(product.id)"
        case .orderConfirmation:
            return "order_confirmation"
        }
    }
}
