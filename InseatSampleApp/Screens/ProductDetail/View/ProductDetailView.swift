import SwiftUI

struct ProductDetailView<ViewModel: ProductDetailViewModelInput>: View {

    @ObservedObject var viewModel: ViewModel

    @Environment(\.dismiss) private var dismiss

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: .zero) {
            HStack(spacing: .zero) {
                Spacer()

                Button(action: {
                    dismiss()
                }, label: {
                    Image("Cancel")
                })
                .padding(.all, 16)
            }
            .background(Color.clear)

            if let product = viewModel.product {
                makeContentView(product: product)
            } else {
                Text("screen.product_detail.product_unavailable".localized)
                    .foregroundStyle(Color.foregroundDark)
                    .font(Font.appFont(size: 18, weight: .regular))
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.backgroundGray)
        .toolbar(.hidden)
        .onAppear(perform: viewModel.onAppear)
    }

    private func limit(for product: ProductDetailContract.Product) ->  Int {
        viewModel.isSelectionAllowedWhenShopClosed ? 10 : product.availableQuantity
    }

    private func makeContentView(product: ProductDetailContract.Product) -> some View {
        VStack(spacing: .zero) {
            ScrollView {
                makeProductView(product: product)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
            }

            if viewModel.shopStatus == .order || viewModel.isSelectionAllowedWhenShopClosed {
                Button("screen.product_detail.buttons.confirm".localized) {
                    viewModel.confirm()
                    dismiss()
                }
                .buttonStyle(BrandPrimaryButtonStyle())
                .padding(.all, 16)
            }
        }
    }

    private func makeProductView(product: ProductDetailContract.Product) -> some View {
        VStack(spacing: .zero) {
            Image(uiImage: product.image ?? UIImage.productPlaceholder)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 240)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.bottom, 24)

            HStack(spacing: .zero) {
                VStack(alignment: .leading, spacing: .zero) {
                    Text(product.name)
                        .foregroundStyle(Color.foregroundDark)
                        .font(Font.appFont(size: 22, weight: .semibold))

                    Text(product.price.formatted())
                        .foregroundStyle(Color.foregroundDark)
                        .font(Font.appFont(size: 18, weight: .regular))
                }
                Spacer()
            }

            VStack(spacing: 24) {
                DescriptionView(text: product.description)
                    .frame(maxWidth: .infinity)

                if viewModel.shopStatus == .unavailable {
                    InfoView(text: "screen.product_detail.shop_unavailable".localized)
                        .frame(maxWidth: .infinity)
                }

                if viewModel.shopStatus == .order || viewModel.isSelectionAllowedWhenShopClosed {
                    StepperView(
                        quantity: $viewModel.quantity,
                        limit: limit(for: product),
                        collapseWhenEmpty: false
                    )
                    .frame(width: 140)
                }
            }
            .padding(.vertical, 24)
        }
    }
}

#Preview {
    ProductDetailView(viewModel: ProductDetailViewModelMock())
}

private final class ProductDetailViewModelMock: ProductDetailViewModelInput {

    let product: ProductDetailContract.Product? = ProductDetailContract.Product(
        id: 1,
        image: UIImage(named: "Product_HotDog"),
        name: "Hot dog",
        description: "Grilled sausage served in the slit of a partially sliced bun.",
        availableQuantity: 5,
        price: Price(amount: 5, currency: .eur)
    )

    @Published var shopStatus: ProductDetailContract.ShopStatus = .order
    @Published var quantity = 1

    let quantityLimit = 5
    let isSelectionAllowedWhenShopClosed = false

    func onAppear() { }

    func confirm() { }
}
