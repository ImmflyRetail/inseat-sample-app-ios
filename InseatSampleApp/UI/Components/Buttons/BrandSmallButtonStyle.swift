import SwiftUI

struct BrandSmallButtonStyle: ButtonStyle {

    private struct Modifier: ViewModifier {

        @Environment(\.isEnabled) var isEnabled

        let isPressed: Bool

        var font: Font {
            return Font.appFont(size: 14, weight: .semibold)
        }

        var foregroundColor: Color {
            return Color.primaryRed
        }

        func body(content: Content) -> some View {
            content
                .frame(minWidth: 0, maxWidth: .infinity)
                .font(font)
                .foregroundColor(foregroundColor)
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        ModifiedContent(
            content: configuration.label,
            modifier: Modifier(
                isPressed: configuration.isPressed
            )
        )
    }
}
