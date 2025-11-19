import Foundation

extension Decimal {

    func rounded(places: Int = 2, rounding: RoundingMode = .bankers) -> Decimal {
        let handler = NSDecimalNumberHandler(
            roundingMode: rounding,
            scale: Int16(places),
            raiseOnExactness: false,
            raiseOnOverflow: false,
            raiseOnUnderflow: false,
            raiseOnDivideByZero: false
        )
        return (self as NSDecimalNumber).rounding(accordingToBehavior: handler) as Decimal
    }

    var doubleValue: Double {
        return (self as NSDecimalNumber).doubleValue
    }
}

extension Array where Element: AdditiveArithmetic {

    func sum() -> Element {
        return reduce(into: .zero) { $0 += $1 }
    }
}
