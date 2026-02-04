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
                XmarkButton(action: {
                    dismiss()
                })
            }
            .padding(16)

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

    private func limit(for product: ProductDetailContract.Product) -> Int {
        viewModel.isSelectionAllowedWhenShopClosed ? 10 : product.availableQuantity
    }

    private var canConfirm: Bool {
        viewModel.shopStatus == .order || viewModel.isSelectionAllowedWhenShopClosed
    }

    private func makeContentView(product: ProductDetailContract.Product) -> some View {
        ScrollView {
            makeProductView(product: product)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.bottom, canConfirm ? 96 : 0)
        }
        .safeAreaInset(edge: .bottom) {
            if canConfirm {
                floatingBottomSection
            }
        }
    }

    // MARK: - Floating Bottom Button

    private var floatingBottomSection: some View {
        VStack(spacing: 0) {
            Button("screen.product_detail.buttons.confirm".localized) {
                viewModel.confirm()
                dismiss()
            }
            .buttonStyle(BrandPrimaryButtonStyle())
            .padding()
        }
    }

    private func makeProductView(product: ProductDetailContract.Product) -> some View {
        VStack(spacing: .zero) {
            Image(uiImage: product.image ?? UIImage.productPlaceholder)
                .resizable()
                .scaledToFit()
                .frame(height: 240)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: .black.opacity(0.1), radius: 2, y: 1)

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
            .padding(.top, 24)

            VStack(spacing: 24) {
                DescriptionView(text: product.description)
                    .frame(maxWidth: .infinity)

                if viewModel.shopStatus == .unavailable {
                    InfoView(text: "screen.product_detail.shop_unavailable".localized)
                        .frame(maxWidth: .infinity)
                }

                if canConfirm {
                    StepperView(
                        quantity: $viewModel.quantity,
                        limit: limit(for: product),
                        collapseWhenEmpty: false
                    )
                    .frame(width: 140)

                    if limit(for: product) > 0, viewModel.quantity == limit(for: product) {
                        StockTextLabel(text: "screen.shop.product.limit_reached".localized)
                    }
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

