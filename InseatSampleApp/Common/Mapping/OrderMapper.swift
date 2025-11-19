import Foundation
import Inseat

enum OrderMapper {

    static func map(order: Inseat.Order) -> Order {
        let totalSavingAmount = order.appliedPromotions
            .compactMap { appliedPromotion -> Decimal? in
                switch appliedPromotion.benefitType {
                case .coupon:
                    return nil

                case .discount(let saving):
                    return saving.amount

                @unknown default:
                    return nil
                }
            }
            .sum()

        return Order(
            id: order.id,
            seatNumber: order.seatNumber,
            items: order.items.map {
                .init(
                    id: $0.id,
                    name: $0.name,
                    quantity: $0.quantity,
                    unitPrice: .init(amount: $0.price.amount, currency: Currency.currency(code: order.orderCurrency))
                )
            },
            subtotalPrice: .init(amount: order.totalPrice.amount + totalSavingAmount, currency: Currency.currency(code: order.orderCurrency)),
            totalSavings: totalSavingAmount > .zero ? .init(amount: totalSavingAmount, currency: Currency.currency(code: order.orderCurrency)) : nil,
            totalPrice: .init(amount: order.totalPrice.amount, currency: Currency.currency(code: order.orderCurrency)),
            status: {
                switch order.status {
                case .placed:
                    return .placed
                case .received:
                    return .received
                case .preparing:
                    return .preparing
                case .cancelledByCrew:
                    return .cancelledByCrew
                case .cancelledByPassenger:
                    return .cancelledByPassenger
                case .cancelledByTimeout:
                    return .cancelledByTimeout
                case .completed:
                    return .completed
                case .refunded:
                    return .refunded
                @unknown default:
                    return .placed
                }
            }(),
            createdAt: order.createdAt
        )
    }
}
