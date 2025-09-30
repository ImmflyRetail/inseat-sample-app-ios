import Inseat

struct Cart {
    let items: [CheckoutProductItem]
    let appliedPromotions: [AppliedPromotion]
    let totalPrice: Price
}
