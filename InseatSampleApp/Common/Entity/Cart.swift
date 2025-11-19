import Foundation
import Inseat

struct Cart {
    let items: [Item]
    let appliedPromotions: [Inseat.AppliedPromotion]
    let currency: Currency
    let totalPrice: Decimal

    struct Item {
        typealias ID = Int

        let id: ID
        let masterId: ID
        let name: String
        let quantity: Int
        /// Price per single item.
        let unitPrice: Decimal
    }

    static func empty(in currency: Currency) -> Cart {
        Cart(items: [], appliedPromotions: [], currency: currency, totalPrice: .zero)
    }
}
