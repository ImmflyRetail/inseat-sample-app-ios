import Foundation
import UIKit

enum PromotionListContract {

    struct ListItem {
        let id: Int
        let name: String
        let description: String
        let image: UIImage?
        let discountType: DiscountType

        enum DiscountType {
            case percentage(Decimal)
            case amount(Price)
            case fixedPrice(Price)
            case coupon
        }
    }
}
