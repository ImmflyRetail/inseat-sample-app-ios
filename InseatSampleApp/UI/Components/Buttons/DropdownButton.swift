import SwiftUI

struct DropdownButton: View {

    enum Style {
        case dropdown(expandedTitle: String, collapsedTitle: String)
        case detail(title: String)

        fileprivate func title(isExpanded: Bool) -> String {
            switch self {
            case .dropdown(let expandedTitle, let collapsedTitle):
                return isExpanded ? expandedTitle : collapsedTitle

            case .detail(let title):
                return title
            }
        }

        fileprivate func arrowIcon(isExpanded: Bool) -> String {
            switch self {
            case .dropdown:
                return isExpanded ? "chevron.up" : "chevron.down"

            case .detail:
                return "chevron.right"
            }
        }
    }

    let style: Style
    @Binding var isExpanded: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action, label: {
            HStack(spacing: 4) {
                Text(style.title(isExpanded: isExpanded))
                    .font(Font.appFont(size: 14, weight: .regular))
                    .foregroundStyle(Color.primaryRed)
                    .underline(true)

                Image(systemName: style.arrowIcon(isExpanded: isExpanded))
                    .renderingMode(.template)
                    .foregroundStyle(Color.primaryRed)
            }
        })
        .frame(height: 40)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    DropdownButton(
        style: .dropdown(
            expandedTitle: "View order details",
            collapsedTitle: "Hide order details"
        ),
        isExpanded: .constant(false),
        action: { }
    )
    DropdownButton(
        style: .dropdown(
            expandedTitle: "View order details",
            collapsedTitle: "Hide order details"
        ),
        isExpanded: .constant(true),
        action: { }
    )
    DropdownButton(
        style: .detail(title: "View order status"),
        isExpanded: .constant(true),
        action: { }
    )
}
