import SwiftUI

struct ShopHeaderView: View {

    let ordersCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action, label: {
            HStack(spacing: 8) {
                Text("screen.shop.my_orders".localized(ordersCount))
                    .font(Font.appFont(size: 14, weight: .regular))
                    .foregroundStyle(Color.primaryRed)

                Image(systemName: "chevron.right")
                    .renderingMode(.template)
                    .foregroundStyle(Color.primaryRed)
            }
        })
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .background(Color.backgroundGray)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .background(Color.backgroundLight)
    }
}
