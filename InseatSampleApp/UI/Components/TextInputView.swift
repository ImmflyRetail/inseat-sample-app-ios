import SwiftUI

struct TextInputView: View {
    let label: String
    let placeholder: String
    @Binding var value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .regular))

            TextField(placeholder, text: $value)
                .font(.system(size: 14, weight: .regular))
                .textFieldStyle(.roundedBorder)
                .padding(.bottom, 8)
        }
    }
}
