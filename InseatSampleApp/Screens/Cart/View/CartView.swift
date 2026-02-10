import SwiftUI

struct CartView<ViewModel: CartViewModelInput>: View {

    @EnvironmentObject var router: ShopRouter

    @ObservedObject var viewModel: ViewModel

    @State var isSavingsExpanded = false

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationBar(
            title: "screen.cart.title".localized,
            leading: BackButton { router.navigateBack() }
        ) {
            Group {
                if viewModel.selectedProducts.isEmpty {
                    makeEmptyStateView()
                } else {
                    makeNonEmptyStateView()
                }
            }
            .background(Color.backgroundGray)
        }
        .toolbar(.hidden)
        .onAppear(perform: viewModel.onAppear)
        .navigationDestination(for: ShopRouter.CartDestination.self) { destination in
            switch destination {
            case .checkout:
                CheckoutView(
                    viewModel: CheckoutViewModel(coordinator: router)
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !viewModel.selectedProducts.isEmpty {
                floatingBottomSection
            }
        }
    }

    private func makeEmptyStateView() -> some View {
        ZStack {
            Text("screen.cart.empty".localized)
                .font(Font.appFont(size: 22, weight: .semibold))
                .foregroundStyle(Color.foregroundDark)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func makeNonEmptyStateView() -> some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 0)

                makeProductListGroup()
                Divider()
                makeTotalsGroup()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 96)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Floating bottom button

    private var floatingBottomSection: some View {
        VStack(spacing: 0) {
            Button("screen.cart.buttons.checkout".localized) {
                router.navigate(to: .checkout)
            }
            .buttonStyle(BrandPrimaryButtonStyle())
            .disabled(!viewModel.isOrdersEnabled)
            .padding(16)
        }
    }

    // MARK: - Sections

    private func makeProductListGroup() -> some View {
        FormGroupView(title: "screen.cart.summary".localized, fontSize: 22) {
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.products, id: \.id) { product in
                    ProductItemView(
                        product: product,
                        quantity: Binding(
                            get: { viewModel.selectedProducts[product.id] ?? 0 },
                            set: { quantity in
                                viewModel.selectedProducts[product.id] = quantity > 0 ? quantity : nil
                            }
                        )
                    )
                }
            }
        }
    }

    private func makeTotalsGroup() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            PriceKeyValueView(
                title: "screen.cart.summary.subtotal".localized,
                price: viewModel.subtotalPrice
            )

            if let savings = viewModel.totalSaving {
                ExpandablePriceKeyValueView(
                    title: "screen.cart.summary.savings".localized,
                    price: savings.negative,
                    style: .normal,
                    isExpanded: $isSavingsExpanded,
                    expandableContent: {
                        VStack(spacing: 8) {
                            ForEach(viewModel.appliedPromotions, id: \.id) { promotion in
                                Text(promotion.name)
                                    .font(Font.appFont(size: 12, weight: .regular))
                                    .foregroundStyle(Color.foregroundLight)
                            }
                        }
                    },
                    expandAction: {
                        withAnimation(.bouncy) {
                            isSavingsExpanded.toggle()
                        }
                    }
                )
            }

            PriceKeyValueView(
                title: "screen.cart.summary.total".localized,
                price: viewModel.totalPrice,
                style: .large
            )
        }
    }

    // MARK: - Product row

    private struct ProductItemView: View {

        let product: CartContract.Product
        @Binding var quantity: Int

        private var limit: Int { product.availableQuantity }

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(uiImage: product.image ?? UIImage.productPlaceholder)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)

                    VStack(alignment: .leading) {
                        HStack(alignment: .top, spacing: 8) {
                            Text(product.name)
                                .lineLimit(2)
                                .font(Font.appFont(size: 14, weight: .semibold))
                                .foregroundStyle(Color.foregroundDark)

                            Spacer()

                            Text(product.price.formatted())
                                .font(Font.appFont(size: 14, weight: .regular))
                                .foregroundStyle(Color.foregroundDark)
                        }

                        HStack(spacing: 4) {
                            StepperView(
                                quantity: $quantity,
                                limit: limit
                            )
                            .fixedSize()

                            if limit > 0, quantity == limit {
                                StockTextLabel(text: "screen.shop.product.limit_reached".localized)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CartView(viewModel: CartViewModelMock())
}

private final class CartViewModelMock: CartViewModelInput {

    var shopStatus: String = "OPEN"

    var products: [CartContract.Product] = [
        CartContract.Product(id: 1, masterId: 11, image: nil, name: "Pepsi", availableQuantity: 10, price: .init(amount: 3, currency: .eur)),
        CartContract.Product(id: 2, masterId: 22, image: nil, name: "Sandwich", availableQuantity: 10, price: .init(amount: 3, currency: .eur)),
        CartContract.Product(id: 3, masterId: 33, image: nil, name: "Sprite", availableQuantity: 10, price: .init(amount: 3, currency: .eur)),
        CartContract.Product(id: 4, masterId: 44, image: nil, name: "Fanta", availableQuantity: 10, price: .init(amount: 3, currency: .eur))
    ]

    var selectedProducts: [CartContract.Product.ID: Int] = [:]

    var appliedPromotions: [CartContract.AppliedPromotion] = []

    var totalSaving: Price?
    var subtotalPrice: Price = Price(amount: .zero, currency: .eur)
    var totalPrice: Price = Price(amount: .zero, currency: .eur)

    var isOrdersEnabled = true

    func onAppear() { }

    init() {  }
}

