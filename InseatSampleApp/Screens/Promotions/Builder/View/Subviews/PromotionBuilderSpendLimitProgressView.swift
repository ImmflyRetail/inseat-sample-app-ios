import SwiftUI

struct PromotionBuilderSpendLimitProgressView: View {

    let currentSpending: Price
    let remainingSpending: Price
    let spendLimit: Price

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ProgressView(
                value: min(currentSpending.amount.doubleValue, spendLimit.amount.doubleValue),
                total: spendLimit.amount.doubleValue
            )
            .tint(Color.primaryRed)
            .background(Color.complementary)

            HStack(spacing: 4) {
                if remainingSpending.isZero {
                    Text("screen.promotion_builder.benetif_unlocked".localized)
                        .font(Font.appFont(size: 14, weight: .regular))
                        .foregroundStyle(Color.foregroundDark)

                    Image("Check")
                        .resizable()
                        .frame(width: 14, height: 14)

                } else {
                    Text(remainingSpending.formatted())
                        .font(Font.appFont(size: 14, weight: .semibold))
                        .foregroundStyle(Color.foregroundDark)

                    Text("screen.promotion_builder.left_to_unlock_benefit".localized)
                        .font(Font.appFont(size: 14, weight: .regular))
                        .foregroundStyle(Color.foregroundDark)
                }

                Spacer()

                Text(spendLimit.formatted())
                    .font(Font.appFont(size: 14, weight: .regular))
                    .foregroundStyle(Color.foregroundDark)
            }
        }
        .padding(.all, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.backgroundGray2)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    PromotionBuilderSpendLimitProgressView(
        currentSpending: Price(amount: 0, currency: .eur),
        remainingSpending: Price(amount: 20, currency: .eur),
        spendLimit: Price(amount: 20, currency: .eur)
    )
    PromotionBuilderSpendLimitProgressView(
        currentSpending: Price(amount: 5, currency: .eur),
        remainingSpending: Price(amount: 15, currency: .eur),
        spendLimit: Price(amount: 20, currency: .eur)
    )
    PromotionBuilderSpendLimitProgressView(
        currentSpending: Price(amount: 20, currency: .eur),
        remainingSpending: Price(amount: 0, currency: .eur),
        spendLimit: Price(amount: 20, currency: .eur)
    )
}
