import SwiftUI

struct StockTextLabel: View {

    let text: String

    var body: some View {
        Text(text)
            .font(Font.appFont(size: 14, weight: .regular))
            .foregroundStyle(.primaryForeground)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .primaryRed, radius: 1, y: 1)
    }
}
