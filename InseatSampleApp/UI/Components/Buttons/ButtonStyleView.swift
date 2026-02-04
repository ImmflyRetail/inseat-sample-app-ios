import SwiftUI

extension View {
    func circularButtonStyle() -> some View {
        self
            .background {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Circle()
                            .stroke(.primaryForeground.opacity(0.5), lineWidth: 1)
                    }
                    .shadow(color: .primaryForeground.opacity(0.5), radius: 1, y: 1)
            }
    }
}

extension View {
    func bottomShadow() -> some View {
        self.overlay(alignment: .bottom) {
            Rectangle()
                .fill(.primary.opacity(0.15))
                .frame(height: 1)
                .shadow(color: .primary.opacity(0.25), radius: 4, y: 2)
        }
    }
}
