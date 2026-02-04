import SwiftUI

struct BrandPrimaryButtonStyle: ButtonStyle {

    private struct Modifier: ViewModifier {
        private let cornerRadius: CGFloat = 8

        @Environment(\.isEnabled) var isEnabled

        let isPressed: Bool

        var font: Font {
            return Font.appFont(size: 16, weight: .semibold)
        }

        var height: CGFloat {
            return 48
        }

        var foregroundColor: Color {
            return Color.white
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
                .shadow(color: .black.opacity(0.2), radius: 2, x: 2, y: 1)
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
