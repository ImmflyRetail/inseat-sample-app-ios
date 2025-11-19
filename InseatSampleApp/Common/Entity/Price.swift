import Foundation

struct Price: Codable, Hashable {
    let amount: Decimal
    let currency: Currency

    func formatted() -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.currencyCode = currency.code
        formatter.currencySymbol = currency.symbol
        formatter.minimumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.numberStyle = .currency

        let number = amount.rounded() as NSDecimalNumber
        return formatter.string(from: number) ?? ""
    }

    var isZero: Bool {
        return amount.isZero
    }

    var negative: Price {
        return Price(amount: -amount, currency: currency)
    }

    func multiplied(by multiplier: Int) -> Price {
        return Price(amount: amount * Decimal(multiplier), currency: currency)
    }

    static func zero(in currency: Currency) -> Price {
        return Price(amount: .zero, currency: currency)
    }
}

extension Array where Element == Price {

    func sum() -> Price? {
        guard let first = first, allSatisfy({ $0.currency == first.currency }) else {
            return nil
        }
        let totalAmount = map { $0.amount }.sum()
        return Price(amount: totalAmount, currency: first.currency)
    }
}
