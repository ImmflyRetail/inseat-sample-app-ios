import SwiftUI

struct ShopStatusView: View {

    let shopStatus: ShopContract.ShopStatus

    var body: some View {
        Text("screen.shop.shop_status".localized(shopStatus.displayName))
            .foregroundStyle(shopStatus == .open ? Color.basePositive : Color.baseNegative)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .font(Font.system(size: 14))
            .background(shopStatus == .open ? Color.backgroundPositive : Color.backgroundNegative)
    }
}
