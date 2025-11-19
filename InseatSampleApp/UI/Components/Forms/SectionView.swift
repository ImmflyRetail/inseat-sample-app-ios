import SwiftUI

struct SectionView<Content: View>: View {

    let padding: EdgeInsets
    let background: Color
    let content: Content

    init(
        padding: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        background: Color = Color.backgroundLight,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.background = background
        self.content = content()
    }

    var body: some View {
        content
            .padding(.top, padding.top)
            .padding(.bottom, padding.bottom)
            .padding(.leading, padding.leading)
            .padding(.trailing, padding.trailing)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
