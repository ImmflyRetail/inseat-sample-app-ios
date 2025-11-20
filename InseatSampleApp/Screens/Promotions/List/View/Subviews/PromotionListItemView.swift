import SwiftUI

struct PromotionListItemView: View {

    let promotion: PromotionListContract.ListItem
    let selectionHandler: () -> Void

    init(promotion: PromotionListContract.ListItem, selectionHandler: @escaping () -> Void = {}) {
        self.promotion = promotion
        self.selectionHandler = selectionHandler
    }

    var body: some View {
        ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
            HStack(alignment: .top, spacing: .zero) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(promotion.name)
                        .font(Font.appFont(size: 16, weight: .semibold))
                        .foregroundStyle(Color.foregroundDark)
                        .lineLimit(1)

                    Text(promotion.description)
                        .multilineTextAlignment(.leading)
                        .font(Font.appFont(size: 14, weight: .regular))
                        .foregroundStyle(Color.foregroundLight)
                        .lineLimit(2)
                        .lineSpacing(6)

                    switch promotion.discountType {
                    case .percentage(let percentage):
                        Text("promotion.discount_type.percentage".localized(percentage.formatted(.number)))
                            .font(Font.appFont(size: 18, weight: .semibold))
                            .foregroundStyle(Color.basePositive)

                    case .amount(let discount):
                        Text("promotion.discount_type.amount".localized(discount.formatted()))
                            .font(Font.appFont(size: 18, weight: .semibold))
                            .foregroundStyle(Color.basePositive)

                    case .fixedPrice(let price):
                        Text(price.formatted())
                            .font(Font.appFont(size: 18, weight: .semibold))
                            .foregroundStyle(Color.foregroundDark)

                    case .coupon:
                        Text("promotion.discount_type.voucher".localized)
                            .font(Font.appFont(size: 18, weight: .semibold))
                            .foregroundStyle(Color.basePositive)
                    }
                }

                if let image = promotion.image {
                    Spacer(minLength: 8)

                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 122, height: 114)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 24)

            Button {
                selectionHandler()
            } label: {
                Image("Add")
                    .padding(.all, 3)
                    .background(Color.complementaryLight)
                    .clipShape(Circle())
            }
            .frame(width: 40, height: 40)
        }
        .frame(height: 160)
        .background(Color.backgroundLight)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    VStack(spacing: 8) {
        PromotionListItemView(
            promotion: .init(
                id: 1,
                name: "Energy combo",
                description: "Ideal energy-booster combo to get at any time of the day.",
                image: UIImage(named: "Promotion_EnergyCombo"),
                discountType: .percentage(10)
            )
        )
        PromotionListItemView(
            promotion: .init(
                id: 1,
                name: "The healthy combo",
                description: "Our wholesome meal options are what you need.",
                image: UIImage(named: "Promotion_SandwichCombo"),
                discountType: .amount(Price(amount: 2, currency: .eur))
            )
        )
        PromotionListItemView(
            promotion: .init(
                id: 1,
                name: "Sandwich & drink combo",
                description: "Choose your favourite sandwich and pair it with a refreshing drink.",
                image: UIImage(named: "Promotion_SandwichCombo"),
                discountType: .fixedPrice(Price(amount: 5, currency: .eur))
            )
        )
        PromotionListItemView(
            promotion: .init(
                id: 1,
                name: "Sandwich & drink combo",
                description: "Get this combo and earn a voucher with extra discounts to use on your next purchase on this flight.",
                image: UIImage(named: "Promotion_SandwichCombo"),
                discountType: .coupon
            )
        )
        PromotionListItemView(
            promotion: .init(
                id: 1,
                name: "Sandwich & drink combo",
                description: "Get this combo and earn a voucher with extra discounts to use on your next purchase on this flight.",
                image: nil,
                discountType: .coupon
            )
        )
    }
    .padding(.vertical, 16)
    .background(Color.gray)
}
