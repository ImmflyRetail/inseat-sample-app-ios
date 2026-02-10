import SwiftUI

struct OrderConfirmationSheet: View {
    
    let image: Image?
    
    let title: String
    let message: String

    let keepTitle: String
    let cancelTitle: String
    
    let horizontalAlignment: HorizontalAlignment

    let onKeep: () -> Void
    let onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: horizontalAlignment, spacing: 10) {
            
            if let image {
                image
                    .resizable()
                    .foregroundStyle(Color.basePositive)
                    .frame(width: 34, height: 34)
                    .padding(.top)
            }

            VStack(alignment: horizontalAlignment, spacing: 10) {
                Text(title)
                    .font(Font.appFont(size: 22, weight: .semibold))
                    .foregroundStyle(Color.foregroundDark)
                    .padding(.top, image == nil ? 20 : 16)
                
                Text(message)
                    .font(Font.appFont(size: 14, weight: .regular))
                    .foregroundStyle(Color.foregroundLight)
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal)
            
            HStack(spacing: 12) {
                Button {
                    dismiss()
                    onKeep()
                } label: {
                    Text(keepTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BrandSecondaryButtonStyle())

                Button {
                    dismiss()
                    onCancel()
                } label: {
                    Text(cancelTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(BrandPrimaryButtonStyle())
            }
            .padding(.top)
            .padding(.horizontal)
        }
        .presentationDetents([.height(image == nil ? 200 : 250)])
        .presentationDragIndicator(.visible)
    }
}
