import SwiftUI

struct TextInputView: View {
    let label: String
    let placeholder: String
    @Binding var value: String
    let isValid: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(Font.appFont(size: 14, weight: .regular))
                .foregroundStyle(Color.foregroundDark)

            HStack(alignment: .center) {
                TextField(placeholder, text: $value)
                    .font(Font.appFont(size: 14, weight: .regular))
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled(true)
                    .keyboardType(.asciiCapable)
                    .disableAutocorrection(true)
                    .onChange(of: value) { newValue in
                           value = newValue.sanitizedSeatInput()
                       }

                if isValid {
                    Image("Check")
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(lineWidth: 2)
                    .foregroundStyle(Color.complementaryLight)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    SectionView {
        TextInputView(
            label: "What's your seat number?",
            placeholder: "i.e. 1A",
            value: .constant("1A"),
            isValid: true
        )
    }

    SectionView {
        TextInputView(
            label: "What's your seat number?",
            placeholder: "i.e. 1A",
            value: .constant(""),
            isValid: false
        )
    }
}
