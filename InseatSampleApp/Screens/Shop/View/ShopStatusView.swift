import SwiftUI

struct ShopStatusView: View {

    let shopStatus: ShopContract.ShopStatus

    var foregroundColor: Color {
        switch shopStatus {
        case .unavailable, .closed, .browse:
            return Color.baseNegative
        case .order:
            return Color.basePositive
        }
    }

    var backgroundColor: Color {
        switch shopStatus {
        case .unavailable, .closed:
            return Color.backgroundNegative
        case .browse:
            return Color.backgroundWarning
        case .order:
            return Color.backgroundPositive
        }
    }

    var body: some View {
        Text(makeAttributedText())
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .font(Font.appFont(size: 14, weight: .regular))
            .background(backgroundColor)
    }

    private func makeAttributedText() -> AttributedString {
        var text1 = AttributedString("screen.shop.shop_status".localized + " ")

        text1.font = Font.appFont(size: 14, weight: .regular)
        text1.foregroundColor = foregroundColor

        var text2 = AttributedString(shopStatus.displayName)
        text2.font = Font.appFont(size: 14, weight: .semibold)
        text2.foregroundColor = foregroundColor

        return text1 + text2
    }
}
