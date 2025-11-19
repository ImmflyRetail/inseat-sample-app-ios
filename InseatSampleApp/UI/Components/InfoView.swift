import SwiftUI

struct InfoView: View {
    let text: String

    var body: some View {
        Text(text)
            .foregroundStyle(Color.infoText)
            .font(Font.appFont(size: 16, weight: .regular))
            .padding(16)
            .background(Color.backgroundInfo)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
