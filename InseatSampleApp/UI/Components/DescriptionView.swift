import SwiftUI

struct DescriptionView: View {
    let text: String

    var body: some View {
        HStack(spacing: .zero) {
            Text(text)
                .foregroundStyle(Color.foregroundLight)
                .font(Font.appFont(size: 16, weight: .regular))
                .padding(16)

            Spacer(minLength: 0)
        }
        .background(Color.backgroundGray2)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
