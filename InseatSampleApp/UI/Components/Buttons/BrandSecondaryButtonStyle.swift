import SwiftUI

struct BrandSecondaryButtonStyle: ButtonStyle {

    private struct Modifier: ViewModifier {
        private let cornerRadius: CGFloat = 8

        @Environment(\.isEnabled) var isEnabled
        let isPressed: Bool

        var font: Font {
            Font.appFont(size: 16, weight: .semibold)
        }

        var height: CGFloat {
            48
        }

        var foregroundColor: Color {
            Color.primaryRed
        }

        var backgroundColor: Color {
            if isEnabled {
                return Color.white
            } else {
                return Color.primaryRedDisabled
            }
        }

        var borderColor: Color {
            Color.primaryRed
        }

        func body(content: Content) -> some View {
            content
                .frame(minWidth: 0, maxWidth: .infinity)
                .font(font)
                .frame(height: height)
                .foregroundColor(foregroundColor)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .shadow(
                    color: .black.opacity(isPressed ? 0.1 : 0.2),
                    radius: 2,
                    x: 2,
                    y: 1
                )
                .opacity(isPressed ? 0.95 : 1)
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(
                Modifier(isPressed: configuration.isPressed)
            )
    }
}
