import SwiftUI

struct StepperView: View {

    @Binding var quantity: Int
    let limit: Int?
    let collapseWhenEmpty: Bool

    init(quantity: Binding<Int>, limit: Int?, collapseWhenEmpty: Bool = true) {
        self._quantity = quantity
        self.limit = limit
        self.collapseWhenEmpty = collapseWhenEmpty
    }

    var isLimitReached: Bool {
        quantity == limit
    }

    var body: some View {
        HStack(spacing: quantity > 0 ? 8 : 0) {
            if quantity > 0 || !collapseWhenEmpty {
                makeRemoveButton()
                    .padding(.leading, 3)

                Spacer()

                Text(String(quantity))
                    .font(Font.appFont(size: 14, weight: .semibold))
                    .foregroundStyle(Color.foregroundDark)
                    .frame(minWidth: 28)
            }

            Spacer()

            makeAddButton()
                .padding(.trailing, 3)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .frame(height: 24)
        .when(quantity > 0 || !collapseWhenEmpty, transform: { view in
            view
                .background(Color.complementary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        })
    }

    private func makeRemoveButton() -> some View {
        Button(action: {
            quantity = max(0, quantity - 1)
        }, label: {
            Image(quantity > 1 ? "Remove" : "Trash")
                .padding(.all, 3)
                .opacity(quantity == 0 ? 0.4 : 1)
        })
        .disabled(quantity == 0)
    }

    private func makeAddButton() -> some View {
        Button(action: {
            if let limit = limit {
                if quantity + 1 <= limit {
                    quantity += 1
                }
            } else {
                quantity += 1
            }
        }, label: {
            Image("Add")
                .padding(.all, 3)
                .background(Color.complementary)
                .opacity(isLimitReached ? 0.4 : 1)
                .clipShape(Circle())
        })
        .disabled(isLimitReached)
    }
}

#Preview {
    VStack(spacing: 0) {
        StepperView(
            quantity: .constant(0),
            limit: nil
        )
        .padding(.all, 8)

        Divider()

        StepperView(
            quantity: .constant(0),
            limit: nil,
            collapseWhenEmpty: false
        )
        .padding(.all, 8)

        Divider()

        StepperView(
            quantity: .constant(1),
            limit: nil
        )
        .padding(.all, 8)

        StepperView(
            quantity: .constant(1),
            limit: nil
        )
        .fixedSize()
        .padding(.all, 8)

        Divider()

        StepperView(
            quantity: .constant(2),
            limit: 2
        )
        .padding(.all, 8)

        StepperView(
            quantity: .constant(2),
            limit: 2
        )
        .fixedSize()
        .padding(.all, 8)
    }
}
