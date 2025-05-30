import SwiftUI

struct InfoView: View {
    let text: String

    var body: some View {
        Text(text)
            .foregroundStyle(Color.infoText)
            .font(.system(size: 16, weight: .regular))
            .padding(16)
            .background(Color.infoBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
