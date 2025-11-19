import SwiftUI

struct ExpandablePriceKeyValueView<Content: View>: View {

    enum Style {
        case normal
        case large
    }

    let title: String
    let price: Price
    let style: Style
    @Binding var isExpanded: Bool
    @ViewBuilder var expandableContent: () -> Content
    let expandAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(title)
                    .font(Font.appFont(size: style == .large ? 18 : 14, weight: .semibold))
                    .foregroundStyle(Color.foregroundDark)

                Button(
                    action: expandAction,
                    label: {
                        Image(systemName: arrowIcon(isExpanded: isExpanded))
                            .renderingMode(.template)
                            .foregroundStyle(Color.primaryRed)
                    }
                )

                Spacer()

                Text(price.formatted())
                    .font(Font.appFont(size: style == .large ? 18 : 14, weight: .semibold))
                    .foregroundStyle(price.amount >= .zero ? Color.foregroundDark : Color.basePositive)
            }

            if isExpanded {
                expandableContent()
            }
        }
    }

    private func arrowIcon(isExpanded: Bool) -> String {
        isExpanded ? "chevron.up" : "chevron.down"
    }
}
