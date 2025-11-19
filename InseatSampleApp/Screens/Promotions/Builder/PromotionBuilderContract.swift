import UIKit

enum PromotionBuilderContract {

    struct PromotionInfo {
        let name: String
        let description: String
        let discountType: DiscountType

        enum DiscountType {
            case percentage(Decimal)
            case amount(Price)
            case fixedPrice(Price)
            case coupon
        }
    }

    struct RequiredIndividualProduct {
        let product: Product
        let quantity: Int
    }

    struct RequiredCategory {
        let categoryId: Int
        let products: [Product]
        let qualifier: Qualifier

        enum Qualifier {
            case quantity(Int)
            case spendLimit(Price)
        }

        var quantity: Int? {
            switch qualifier {
            case .quantity(let quantity):
                return quantity
                
            case .spendLimit:
                return nil
            }
        }
    }
}
