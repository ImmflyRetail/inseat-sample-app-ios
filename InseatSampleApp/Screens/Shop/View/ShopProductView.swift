import SwiftUI

struct ShopProductView: View {

    let product: ShopContract.Product
    let shopStatus: ShopContract.ShopStatus
    let isSelectionAllowedWhenShopClosed: Bool

    @Binding var totalQuantity: Int
    @Binding var cartQuantity: Int

    private var limit: Int {
        isSelectionAllowedWhenShopClosed ? 10 : totalQuantity
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                Image(uiImage: product.image ?? UIImage.productPlaceholder)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .when(shopStatus == .order || isSelectionAllowedWhenShopClosed) { container in
                container
                    .overlay(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                        VStack(spacing: 8) {
                            if limit > 0, cartQuantity == limit {
                                StockTextLabel(text: "screen.shop.product.limit_reached".localized)
                            }

                            ZStack {
                                StepperView(
                                    quantity: $cartQuantity,
                                    limit: limit
                                )

                                if totalQuantity == 0 {
                                    StockTextLabel(text: "screen.shop.product.out_of_stock".localized)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.all, 8)
                    }
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(Font.appFont(size: 14, weight: .semibold))
                    .lineLimit(2)

                Text(product.price.formatted())
                    .font(Font.appFont(size: 12, weight: .regular))
            }
        }
    }
}
