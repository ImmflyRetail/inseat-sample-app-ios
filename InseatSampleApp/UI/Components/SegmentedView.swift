import SwiftUI

struct SegmentedView: View {

    let segments: [String]
    @Binding var selectedIndex: Int?
    @Namespace var name

    init(segments: [String], selectedIndex: Binding<Int?>) {
        self.segments = segments
        self._selectedIndex = selectedIndex
    }

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(Array(segments.enumerated()), id: \.self.element) { pair in
                    Button {
                        withAnimation(.bouncy(extraBounce: 0)) {
                            selectedIndex = pair.offset
                        }
                    } label: {
                        ZStack {
                            SegmentElement(
                                title: pair.element,
                                isSelected: selectedIndex == pair.offset
                            )
                            .padding(.horizontal, 16)

                            VStack(spacing: .zero) {
                                Spacer()

                                ZStack {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(height: 4)
                                    if selectedIndex == pair.offset {
                                        Rectangle()
                                            .fill(Color.primaryRed)
                                            .frame(height: 4)
                                            .matchedGeometryEffect(id: "Tab", in: name)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        .frame(height: 56)
        .background(Color.complementaryLight)
    }

    private struct SegmentElement: View {

        let title: String
        let isSelected: Bool

        var body: some View {
            Text(title)
                .font(Font.appFont(size: 16, weight: .regular))
                .foregroundStyle(Color.foregroundDark)
        }
    }
}

#Preview {
    SegmentedView(
        segments: [
            "Sandwiches",
            "Refreshers",
            "Snacks",
            "Coffee",
            "Cold Drinks",
            "Alcohole"
        ],
        selectedIndex: .constant(0)
    )
}
