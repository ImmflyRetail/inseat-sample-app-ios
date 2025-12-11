import SwiftUI

struct StockTextLabel: View {

    let text: String

    var body: some View {
        Text(text)
            .font(Font.appFont(size: 10, weight: .regular))
            .foregroundStyle(Color.baseNegative)
            .padding(.vertical, 2)
            .padding(.horizontal, 8)
            .background(Color.backgroundGray)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
