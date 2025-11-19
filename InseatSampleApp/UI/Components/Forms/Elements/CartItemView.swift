import SwiftUI

struct CartItemView: View {

    struct Item {
        let id: Product.ID
        let name: String
        let quantity: Int
        let unitPrice: Price
    }

    let item: Item

    var body: some View {
        HStack(spacing: 8) {
            Text("product.multiplier".localized(item.quantity))
                .font(Font.appFont(size: 14, weight: .semibold))
                .foregroundStyle(Color.foregroundDark)
                .frame(minWidth: 22, alignment: .leading)

            Text(item.name)
                .font(Font.appFont(size: 14, weight: .regular))
                .foregroundStyle(Color.foregroundDark)

            Spacer()

            Text(item.unitPrice.formatted())
                .font(Font.appFont(size: 14, weight: .semibold))
                .foregroundStyle(Color.foregroundDark)
        }
    }
}

// MARK: - Preview

#Preview {
    CartItemView(
        item: .init(id: 1, name: "Pepsi", quantity: 1, unitPrice: .init(amount: 3, currency: .eur))
    )
}
