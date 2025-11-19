import Foundation
import Inseat

protocol CartManaging {
    var selectedCurrency: Currency { get }
    var currentCart: Cart { get }

    func updateCart(items: [Cart.Item]) async
    func resetCart()

    func subtotal(in cart: Cart) -> Price
    func savings(in cart: Cart) -> Price?
    func total(in cart: Cart) -> Price
}

final class CartManager: CartManaging {

    static let shared: CartManaging = CartManager()

    private init() { }

    let selectedCurrency: Currency = .eur

    private(set) var currentCart: Cart = .empty(in: .eur)

    func updateCart(items: [Cart.Item]) async {
        let cartItems = items.map {
            Inseat.CartItem(
                id: $0.id,
                masterId: $0.masterId,
                name: $0.name,
                quantity: $0.quantity,
                prices: [Inseat.Money(amount: $0.unitPrice, currency: selectedCurrency.code)]
            )
        }
        let appliedPromotions: [Inseat.AppliedPromotion]
        do {
            appliedPromotions = try await InseatAPI
                .shared
                .applyPromotions(
                    to: cartItems,
                    currency: selectedCurrency.code
                )
                .appliedPromotions
        } catch {
            Logger.log("Failed to apply promotions: \(error)", level: .error)
            appliedPromotions = []
        }

        let subtotal = items.map { $0.unitPrice * Decimal($0.quantity) }.sum()
        let savings = savings(for: appliedPromotions)
        let total = subtotal - savings

        await MainActor.run {
            currentCart = Cart(
                items: items,
                appliedPromotions: appliedPromotions,
                currency: selectedCurrency,
                totalPrice: total
            )
        }
    }

    func resetCart() {
        currentCart = .empty(in: selectedCurrency)
    }

    func subtotal(in cart: Cart) -> Price {
        let totalSavingAmount = savings(in: cart)?.amount ?? .zero
        return Price(amount: cart.totalPrice + totalSavingAmount, currency: cart.currency)
    }

    func savings(in cart: Cart) -> Price? {
        let amount = savings(for: cart.appliedPromotions)
        return amount > .zero ? Price(amount: amount, currency: cart.currency) : nil
    }

    func total(in cart: Cart) -> Price {
        return Price(amount: cart.totalPrice, currency: cart.currency)
    }

    private func savings(for appliedPromotions: [AppliedPromotion]) -> Decimal {
        return appliedPromotions
            .compactMap { $0.totalSaving?.amount }
            .reduce(into: Decimal.zero) { $0 += $1 }
    }
}
