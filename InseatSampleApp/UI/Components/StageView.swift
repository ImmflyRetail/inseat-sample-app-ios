import SwiftUI

struct Stage {
    let title: String
}

struct StageView: View {

    let stages: [Stage]
    let currentIndex: Int?

    var body: some View {
        HStack {
            ForEach(Array(stages.enumerated()), id: \.element.title) { pair in
                StageItemView(
                    stage: pair.element,
                    isFulfilled: pair.offset <= (currentIndex ?? -1)
                )
            }
        }
    }

    private struct StageItemView: View {

        let stage: Stage
        let isFulfilled: Bool

        var body: some View {
            VStack(spacing: 8) {
                Rectangle()
                    .foregroundStyle(isFulfilled ? Color.primaryRed : Color.complementaryLight)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                    .frame(height: 4)

                Text(stage.title)
                    .font(Font.appFont(size: 14, weight: .regular))
                    .foregroundStyle(Color.foregroundDark)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    StageView(
        stages: [
            Stage(title: "Placed"),
            Stage(title: "In preparation"),
            Stage(title: "Delivered")
        ],
        currentIndex: 0
    )

    StageView(
        stages: [
            Stage(title: "Placed"),
            Stage(title: "In preparation"),
            Stage(title: "Delivered")
        ],
        currentIndex: 1
    )

    StageView(
        stages: [
            Stage(title: "Placed"),
            Stage(title: "In preparation"),
            Stage(title: "Delivered")
        ],
        currentIndex: 2
    )
}
