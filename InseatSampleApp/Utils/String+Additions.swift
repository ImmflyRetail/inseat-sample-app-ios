extension String {

    var localized: String {
        String(localized: String.LocalizationValue(self), table: "Localizable")
    }

    func localized(_ arguments: any CVarArg...) -> String {
        String(format: self.localized, arguments)
    }
}

extension String {

    /// 1–2 digits + exactly 1 letter (e.g. 1A, 12B)
    var isValidSeat: Bool {
        let regex = #"^[0-9]{1,2}[A-Z]{1}$"#
        return range(of: regex, options: .regularExpression) != nil
    }

    func sanitizedSeatInput() -> String {
        let uppercased = uppercased()

        let digits = uppercased.filter(\.isNumber).prefix(2)
        let letters = uppercased.filter(\.isLetter).prefix(1)

        return String(digits + letters)
    }
}
