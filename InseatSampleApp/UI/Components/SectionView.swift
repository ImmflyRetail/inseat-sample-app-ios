import SwiftUI

struct SectionView<Content: View>: View {

    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .frame(height: 44)

            content
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.backgroundLight)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 16)
    }
}
