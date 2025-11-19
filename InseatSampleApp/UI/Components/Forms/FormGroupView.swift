import SwiftUI

struct FormGroupView<Content: View>: View {

    let title: String
    let fontSize: CGFloat
    let content: Content

    init(title: String, fontSize: CGFloat = 18, @ViewBuilder content: () -> Content) {
        self.title = title
        self.fontSize = fontSize
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(Font.appFont(size: fontSize, weight: .semibold))
                .foregroundStyle(Color.foregroundDark)

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
