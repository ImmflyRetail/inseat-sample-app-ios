import SwiftUI

struct BrandButtonStyle: ButtonStyle {

    private struct Modifier: ViewModifier {
        private let cornerRadius: CGFloat = 4

        @Environment(\.isEnabled) var isEnabled

        let isPressed: Bool

        var font: Font {
            return Font.system(size: 16, weight: .semibold)
        }

        var height: CGFloat {
            return 48
        }

        var foregroundColor: Color {
            return Color.foregroundLight
        }

        var backgroundColor: Color {
            if isEnabled {
                return Color.primaryRed
            } else {
                return Color.primaryRedDisabled
            }
        }

        func body(content: Content) -> some View {
            content
                .frame(minWidth: 0, maxWidth: .infinity)
                .font(font)
                .frame(height: height)
                .foregroundColor(foregroundColor)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
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
