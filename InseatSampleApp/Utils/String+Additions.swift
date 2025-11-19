extension String {

    var localized: String {
        String(localized: String.LocalizationValue(self), table: "Localizable")
    }

    func localized(_ arguments: any CVarArg...) -> String {
        String(format: self.localized, arguments)
    }
}
