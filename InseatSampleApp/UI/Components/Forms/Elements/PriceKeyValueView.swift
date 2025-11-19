import SwiftUI

struct PriceKeyValueView: View {

    enum Style {
        case normal
        case large
    }

    let title: String
    let price: Price
    let style: Style

    init(title: String, price: Price, style: Style = .normal) {
        self.title = title
        self.price = price
        self.style = style
    }

    var body: some View {
        HStack {
            Text(title)
                .font(Font.appFont(size: style == .large ? 18 : 14, weight: .semibold))
                .foregroundStyle(Color.foregroundDark)

            Spacer()

            Text(price.formatted())
                .font(Font.appFont(size: style == .large ? 18 : 14, weight: .semibold))
                .foregroundStyle(price.amount >= .zero ? Color.foregroundDark : Color.basePositive)
        }
    }
}
