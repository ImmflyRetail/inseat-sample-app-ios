import Inseat

enum ProductMapper {

    static func map(product: Inseat.Product, selectedCurrency: Currency) -> Product? {
        guard let priceInSelectedCurrency = product.prices.first(where: { $0.currency == selectedCurrency.code }) else {
            return nil
        }
        var availableQuantity = product.quantity

        if availableQuantity == 0, AppSettings.isOrdersEnabledWhenShopClosed {
            availableQuantity = 999
        }

        return Product(
            id: product.id,
            masterId: product.masterId,
            categoryId: product.categoryId,
            image: product.image,
            name: product.name,
            description: product.description,
            availableQuantity: availableQuantity,
            price: Price(amount: priceInSelectedCurrency.amount, currency: selectedCurrency)
        )
    }
}
