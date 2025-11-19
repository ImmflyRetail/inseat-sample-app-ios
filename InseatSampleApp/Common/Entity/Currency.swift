struct Currency: Codable, Hashable {

    let code: String
    let symbol: String

    init(code: String, symbol: String) {
        self.code = code
        self.symbol = symbol
    }

    static let eur = Currency(code: "EUR", symbol: "€")

    static func currency(code: String) -> Currency {
        guard let result = [Currency.eur].first(where: { $0.code == code }) else {
            fatalError("Unsupported currency")
        }
        return result
    }
}
