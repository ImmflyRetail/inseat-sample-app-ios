import Foundation

struct Price: Codable, Hashable {
    let amount: Decimal
    let currencyCode: String

    func formatted() -> String {
        return "\(currencyCode) \(amount)"
    }
}
