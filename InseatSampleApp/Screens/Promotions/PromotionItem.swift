import Foundation
import Inseat

struct PromotionItem {
    let id: Int
    let name: String
    let triggerType: TriggerType
    let discountType: DiscountType

    struct Money {
        let amount: Decimal
        let currency: String
    }

    enum TriggerType {
        case productPurchase
        case spendLimit

        var displayName: String {
            switch self {
            case .productPurchase:
                return "Product Purchase"

            case .spendLimit:
                return "Spend Limit"
            }
        }
    }

    enum DiscountType {
        case percentage(Decimal)
        case amount(Money)
        case fixedPrice(Money)
        case coupon(Int)

        var displayName: String {
            switch self {
            case .percentage(let decimal):
                return "Percentage discount - \(decimal)% OFF"

            case .amount(let discount):
                return "Amount discount - \(discount.amount) \(discount.currency)"

            case .fixedPrice(let newPrice):
                return "Fixed price - \(newPrice.amount) \(newPrice.currency)"

            case .coupon(let couponId):
                return "Printed Coupon - \(couponId)"
            }
        }
    }
}
