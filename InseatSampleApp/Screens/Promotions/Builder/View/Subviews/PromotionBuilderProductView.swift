import SwiftUI
import UIKit

struct PromotionBuilderProductView: View {

    let name: String
    let description: String
    let price: Price?
    let image: UIImage?
    let quantityLimit: Int

    @Binding var quantity: Int

    @Environment(\.isEnabled) var isEnabled

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            productTitle
                .opacity(isEnabled ? 1.0 : 0.3)

            Spacer()

            productImage
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 126)
    }

    private var productTitle: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(name)
                    .font(Font.appFont(size: 14, weight: .semibold))
                    .foregroundStyle(Color.foregroundDark)

                Text(description)
                    .font(Font.appFont(size: 12, weight: .regular))
                    .foregroundStyle(Color.foregroundLight)
                    .lineLimit(price != nil ? 3 : 4)
                    .lineSpacing(4)

                if let price {
                    Text(price.formatted())
                        .font(Font.appFont(size: 12, weight: .regular))
                        .foregroundStyle(Color.foregroundDark)
                }
            }
            Spacer()
        }
    }

    private var productImage: some View {
        Image(uiImage: image ?? UIImage.productPlaceholder)
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 120)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(alignment: .bottomTrailing) {
                stepperOverlay
            }
            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
    }

    @ViewBuilder
    private var stepperOverlay: some View {
        if quantityLimit > 0 {
            StepperView(
                quantity: $quantity,
                limit: quantityLimit
            )
            .padding(2)
        } else {
            EmptyView()
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        PromotionBuilderProductView(
            name: "Hot dog",
            description: "Classic sausage in bun. Topping are on the side.",
            price: Price(amount: 4, currency: .eur),
            image: nil,
            quantityLimit: 2,
            quantity: .constant(0)
        )
        PromotionBuilderProductView(
            name: "Grilled cheese",
            description: "Cheese, pastrami, caramelised onions.",
            price: Price(amount: 4, currency: .eur),
            image: nil,
            quantityLimit: 2,
            quantity: .constant(1)
        )
    }
    .padding(.horizontal, 16)
    .background(Color.backgroundGray)
}
