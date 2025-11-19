enum CheckoutContract {

    struct DisplayData {
        let cartItems: [Item]
        let subtotalPrice: Price
        let totalSaving: Price?
        let appliedPromotions: [AppliedPromotion]
        let totalPrice: Price

        struct AppliedPromotion {
            let id: Int
            let name: String
        }

        struct Item {
            let id: Int
            let masterId: Int
            let name: String
            let quantity: Int
            /// Price per single item.
            let unitPrice: Price
        }
    }
}
