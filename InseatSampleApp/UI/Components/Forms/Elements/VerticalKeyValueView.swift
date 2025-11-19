import SwiftUI

struct VerticalKeyValueView: View {

    let key: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(key)
                .font(Font.appFont(size: 14, weight: .regular))
                .foregroundStyle(Color.foregroundLight)

            Text(value)
                .font(Font.appFont(size: 14, weight: .semibold))
                .foregroundStyle(Color.foregroundDark)
        }
    }
}
