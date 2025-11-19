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

                    if let price = price {
                        Text(price.formatted())
                            .font(Font.appFont(size: 12, weight: .regular))
                            .foregroundStyle(Color.foregroundDark)
                    }
                }
                Spacer()
            }
            .opacity(isEnabled ? 1.0 : 0.3)

            Spacer()

            Image(uiImage: image ?? UIImage.productPlaceholder)
                .frame(width: 122, height: 106)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                        StepperView(
                            quantity: $quantity,
                            limit: quantityLimit
                        )
                        .padding(.all, 8)
                    }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 106)
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
