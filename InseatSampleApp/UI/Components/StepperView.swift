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
        HStack(spacing: 5) {
            if quantity > 0 || !collapseWhenEmpty {
                makeRemoveButton().padding(.leading, 3)

                Spacer(minLength: 0)

                Text(String(quantity))
                    .font(Font.appFont(size: 15, weight: .semibold))
                    .foregroundStyle(.primaryForeground)
                    .frame(minWidth: 28)
                    .monospaced()
            }

            Spacer(minLength: 0)

            makeAddButton().padding(.trailing, 3)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .frame(height: 24)
        .padding(.vertical, 8)
        .when(quantity > 0 || !collapseWhenEmpty, transform: { view in
            view
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        })
    }

    private func makeRemoveButton() -> some View {
        Button(action: {
            quantity = max(0, quantity - 1)
        }, label: {
            Image(systemName: quantity <= 1 ? "trash": "minus")
                .opacity(quantity == 0 ? 0.2 : 1)
                .foregroundStyle(.primaryForeground)
                .frame(width: 32, height: 32)
                .circularButtonStyle()
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
            Image(systemName: "plus")
                .foregroundStyle(.primaryForeground)
                .frame(width: 32, height: 32)
                .circularButtonStyle()
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
