import SwiftUI

struct InfoView: View {
    let text: String

    var body: some View {
        HStack(spacing: .zero) {
            Text(text)
                .foregroundStyle(Color.infoText)
                .font(Font.appFont(size: 16, weight: .regular))
                .padding(16)

            Spacer(minLength: 0)
        }
        .background(Color.backgroundNegative)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
