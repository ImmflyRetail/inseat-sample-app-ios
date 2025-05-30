import Foundation

protocol CartCalculating {
    func totalPrice(for items: [CheckoutProductItem]) -> Price
}

struct CartCalculator: CartCalculating {

    func totalPrice(for items: [CheckoutProductItem]) -> Price {
        let amount = items.reduce(into: Decimal.zero) {
            $0 += Decimal($1.quantity) * $1.unitPrice.amount
        }
        return Price(amount: amount, currencyCode: "EUR")
    }
}
