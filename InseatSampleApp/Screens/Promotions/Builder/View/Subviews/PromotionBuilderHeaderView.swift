import SwiftUI

struct PromotionBuilderHeaderView: View {

    let promotionInfo: PromotionBuilderContract.PromotionInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(promotionInfo.name)
                .font(Font.appFont(size: 16, weight: .semibold))
                .foregroundStyle(Color.foregroundDark)

            switch promotionInfo.discountType {
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

            Text(promotionInfo.description)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .font(Font.appFont(size: 16, weight: .regular))
                .foregroundStyle(Color.foregroundLight)
        }
        .padding(.all, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundGray2)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    PromotionBuilderHeaderView(
        promotionInfo: .init(
            name: "Energy combo",
            description: "Ideal energy-booster combo to get at any time of the day.",
            discountType: .percentage(10)
        )
    )
    PromotionBuilderHeaderView(
        promotionInfo: .init(
            name: "The healthy combo",
            description: "Our wholesome meal options are what you need.",
            discountType: .amount(Price(amount: 2, currency: .eur))
        )
    )
    PromotionBuilderHeaderView(
        promotionInfo: .init(
            name: "Sandwich + drink combo",
            description: "Buy a Sandwich and a Premium Beer and get a You+ Peanut/You+ Chocolate for Free",
            discountType: .fixedPrice(Price(amount: 5, currency: .eur))
        )
    )
    PromotionBuilderHeaderView(
        promotionInfo: .init(
            name: "Sandwich & drink combo",
            description: "Get this combo and earn a voucher with extra discounts to use on your next purchase on this flight.",
            discountType: .coupon
        )
    )
}
