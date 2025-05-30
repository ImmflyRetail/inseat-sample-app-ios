import SwiftUI

struct CartView<ViewModel: CartViewModelInput>: View {

    @ObservedObject var router = CartRouter()

    @ObservedObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack(path: $router.navPath) {
            Group {
                if viewModel.selectedProducts.isEmpty {
                    ZStack {
                        Text("Empty cart")
                            .font(.system(size: 18, weight: .regular))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: .zero) {
                        Text("Summary")
                            .font(.system(size: 22, weight: .semibold))
                            .frame(height: 44)
                            .padding(.horizontal, 16)

                        ScrollView {
                            LazyVGrid(columns: [GridItem(.flexible())], spacing: 8) {
                                ForEach(viewModel.products, id: \.id) { product in
                                    ProductItemView(
                                        product: product,
                                        quantity: Binding(
                                            get: {
                                                viewModel.selectedProducts[product.id] ?? 0
                                            },
                                            set: { quantity in
                                                viewModel.selectedProducts[product.id] = quantity > 0 ? quantity : nil
                                            }
                                        )
                                    )
                                }
                            }

                            Divider()

                            HStack {
                                Text("Total")
                                    .font(.system(size: 18, weight: .semibold))

                                Spacer()

                                Text("\(viewModel.totalPrice.formatted())")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .frame(height: 44)
                        }
                        .padding(.horizontal, 16)
                        .listRowInsets(EdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 16))

                        Button("Checkout") {
                            router.navigate(to: .checkout(items: viewModel.checkout()))
                        }
                        .buttonStyle(BrandButtonStyle())
                        .disabled(!viewModel.isOrdersEnabled)
                        .padding(.all, 16)
                    }
                }
            }
            .background(Color.backgroundGray)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Shopping cart")
            .onAppear(perform: viewModel.onAppear)
            .navigationDestination(for: CartRouter.Destination.self) { destination in
                switch destination {
                case .checkout(let items):
                    return CheckoutView(
                        viewModel: CheckoutViewModel(
                            router: router,
                            cartItems: items
                        )
                    )
                }
            }
        }
    }
}

private struct ProductItemView: View {

    let product: CartProductItem

    @Binding var quantity: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(uiImage: product.image ?? UIImage(named: "ImagePlaceholder")!)
                    .frame(width: 120, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.name)
                            .font(.system(size: 14, weight: .semibold))

                        Stepper(
                            value: $quantity,
                            in: 0...product.availableQuantity,
                            label: {
                                Text("\(quantity)")
                                    .padding(.trailing, 8)
                            }
                        )
                        .padding(.horizontal, 8)
                        .fixedSize()
                    }

                    Spacer()

                    Text("\(product.price.currencyCode) \(product.price.amount)")
                        .font(.system(size: 14, weight: .regular))
                }
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    CartView(viewModel: CartViewModelMock())
}

private final class CartViewModelMock: CartViewModelInput {
    var shopStatus: String = "OPEN"

    var products: [CartProductItem] = [
        CartProductItem(id: 1, image: nil, name: "Pepsi", availableQuantity: 10, price: .init(amount: 3, currencyCode: "EUR")),
        CartProductItem(id: 2, image: nil, name: "Sandwich", availableQuantity: 10, price: .init(amount: 3, currencyCode: "EUR")),
        CartProductItem(id: 3, image: nil, name: "Sprite", availableQuantity: 10, price: .init(amount: 3, currencyCode: "EUR")),
        CartProductItem(id: 4, image: nil, name: "Fanta", availableQuantity: 10, price: .init(amount: 3, currencyCode: "EUR"))
    ]

    var selectedProducts: [CartProductItem.ID: Int] = [:]

    var totalPrice: Price = Price(amount: .zero, currencyCode: "EUR")

    var isOrdersEnabled = true

    func onAppear() { }

    func checkout() -> [CheckoutProductItem] { [] }

    init() {  }
}
