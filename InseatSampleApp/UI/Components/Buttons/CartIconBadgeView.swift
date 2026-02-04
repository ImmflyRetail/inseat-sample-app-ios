import SwiftUI

struct CartIconBadgeView: View {

    let count: Int

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "cart")
                .imageScale(.large)

            if count > 0 {
                Text("\(count)")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.white)
                    .frame(width: 18, height: 18)
                    .background(Color.primaryRed)
                    .clipShape(Circle())
                    .offset(x: 8, y: -8)
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}
