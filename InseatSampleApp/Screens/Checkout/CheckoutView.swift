import SwiftUI

struct CheckoutView<ViewModel: CheckoutViewModelInput>: View {

    @ObservedObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            ScrollView {
                VStack(spacing: 24) {
                    SectionView(title: "Summary") {
                        VStack(spacing: 24) {
                            VStack(spacing: 16) {
                                ForEach(viewModel.cartItems, id: \.id) { cartItem in
                                    ProductItemView(cartItem: cartItem)
                                }
                            }

                            Divider()

                            TotalPriceView(totalPrice: viewModel.totalPrice)
                                .padding(.bottom, 8)
                        }
                    }

                    SectionView(title: "Enter your details") {
                        VStack(spacing: 16) {
                            TextInputView(
                                label: "What's your seat number?",
                                placeholder: "4B",
                                value: $viewModel.seatNumber
                            )
                        }
                    }

                    InfoView(text: "You’ll pay your order to a crew member when they deliver it to you.")
                        .padding(.horizontal, 16)
                }
                .padding(.top, 24)
            }
            .background(Color.backgroundGray)

            Button("Order now", action: viewModel.makeOrder)
                .buttonStyle(BrandButtonStyle())
                .disabled(viewModel.seatNumber.isEmpty)
                .padding(.all, 16)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Checkout")
        .onAppear(perform: viewModel.onAppear)
    }

    // MARK: - Subviews

    private struct ProductItemView: View {

        let cartItem: CheckoutProductItem

        var body: some View {
            HStack(spacing: 12) {
                Text("\(cartItem.quantity)x")
                    .font(.system(size: 14, weight: .semibold))

                Text(cartItem.name)
                    .font(.system(size: 14, weight: .regular))

                Spacer()

                Text("\(cartItem.unitPrice.formatted())")
                    .font(.system(size: 14, weight: .semibold))
            }
        }
    }

    private struct TotalPriceView: View {

        let totalPrice: Price

        var body: some View {
            HStack {
                Text("Total")
                    .font(.system(size: 18, weight: .semibold))

                Spacer()

                Text("\(totalPrice.formatted())")
                    .font(.system(size: 18, weight: .semibold))
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CheckoutView(viewModel: CheckoutViewModelMock())
}

private final class CheckoutViewModelMock: CheckoutViewModelInput {

    let cartItems: [CheckoutProductItem] = [
        CheckoutProductItem(id: 1, name: "Coca-Cola", quantity: 1, unitPrice: .init(amount: 2, currencyCode: "EUR")),
        CheckoutProductItem(id: 1, name: "Fanta", quantity: 2, unitPrice: .init(amount: 2, currencyCode: "EUR"))
    ]

    let totalPrice: Price = .init(amount: 6, currencyCode: "EUR")

    @Published var seatNumber: String = ""

    func onAppear() { }

    func makeOrder() { }

    init() {  }
}
