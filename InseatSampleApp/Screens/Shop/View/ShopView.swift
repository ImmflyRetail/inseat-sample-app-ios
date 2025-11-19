import SwiftUI

struct ShopView<ViewModel: ShopViewModelInput>: View {

    @EnvironmentObject var router: ShopRouter

    @ObservedObject var viewModel: ViewModel

    @State private var selectedPage: Int? = 0

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    private var shopSections: [ShopContract.Section] {
        var sections = [ShopContract.Section]()

        if let firstCategory = viewModel.categories.first {
            let section = ShopContract.Section(
                type: .products(category: firstCategory),
                index: 0
            )
            sections.append(section)
            sections.append(ShopContract.Section(type: .promotions, index: 1))

            viewModel.categories.dropFirst().forEach { category in
                let section = ShopContract.Section(
                    type: .products(category: category),
                    index: sections.count
                )
                sections.append(section)
            }

        } else {
            sections.append(ShopContract.Section(type: .promotions, index: 0))
        }

        return sections
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationBar(
            title: "screen.shop.title".localized,
            leading: BackButton { router.navigateBack() },
            trailing: makeTrailingNavigationButtons(),
            subheader: makeOrderCountHeaderView()
        ) {
            VStack(spacing: .zero) {
                SegmentedView(
                    segments: shopSections.map { $0.title },
                    selectedIndex: $selectedPage
                )

                TabView(selection: $selectedPage) {
                    ForEach(shopSections) { section in
                        Group {
                            switch section.type {
                            case .products(let category):
                                makeShopListView(
                                    products: viewModel.products.filter { $0.categoryId == category.id }
                                )

                            case .promotions:
                                makePromotionsListView()
                            }
                        }
                        .tag(section.index)
                    }
                }
                .tabViewStyle(.page)

                ShopStatusView(shopStatus: viewModel.shopStatus)
            }
            .background(Color.backgroundGray)
        }
        .toolbar(.hidden)
        .onAppear(perform: viewModel.onAppear)
        .navigationDestination(for: ShopRouter.ShopDestination.self) { destination in
            switch destination {
            case .cart:
                CartView(viewModel: CartViewModel())

            case .orders:
                OrdersView(viewModel: OrdersViewModel())
            }
        }
        .navigationDestination(for: ShopRouter.PromotionDestination.self) { destination in
            switch destination {
            case .promotionBuilder(let promotion):
                PromotionBuilderView(
                    viewModel: PromotionBuilderViewModel(
                        promotion: promotion,
                        coordinator: router
                    )
                )
            }
        }
    }

    private func makeTrailingNavigationButtons() -> some View {
        HStack(spacing: 16) {
            Button(action: {
                // TODO:
            }, label: {
                Image("Search")
            })

            Button(action: {
                router.navigate(to: .cart)
            }, label: {
                Image("Cart")
            })
        }
    }

    private func makeOrderCountHeaderView() -> ShopHeaderView? {
        if viewModel.ordersCount > 0 {
            return ShopHeaderView(ordersCount: viewModel.ordersCount) {
                router.navigate(to: .orders)
            }
        }
        return nil
    }

    private func makeShopListView(products: [ShopContract.Product]) -> some View {
        VStack(spacing: .zero) {
            ScrollView {
                if viewModel.shopStatus == .unavailable {
                    InfoView(text: "screen.shop.unavailable".localized)
                        .padding(.all, 16)
                }

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(products, id: \.id) { product in
                        ProductItemView(
                            product: product,
                            shopStatus: viewModel.shopStatus,
                            isSelectionAllowedWhenShopClosed: viewModel.isSelectionAllowedWhenShopClosed,
                            totalQuantity: .constant(product.availableQuantity),
                            cartQuantity: Binding(
                                get: {
                                    viewModel.selectedProducts[product.id] ?? 0
                                },
                                set: { quantity in
                                    viewModel.selectedProducts[product.id] = quantity > 0 ? quantity : nil
                                }
                            )
                        )
                        .padding(.vertical, 16)
                    }
                }
                .padding(.horizontal, 8)
            }
            .refreshable {
                await viewModel.refresh()
            }
            .listRowInsets(.init(top: 24, leading: 16, bottom: 24, trailing: 16))
        }
    }

    private func makePromotionsListView() -> some View {
        PromotionListView(viewModel: PromotionListViewModel())
    }
}

private struct ProductItemView: View {

    let product: ShopContract.Product
    let shopStatus: ShopContract.ShopStatus
    let isSelectionAllowedWhenShopClosed: Bool

    @Binding var totalQuantity: Int
    @Binding var cartQuantity: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .center, spacing: .zero) {
                Image(uiImage: product.image ?? UIImage.productPlaceholder)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                if shopStatus == .open {
                    Stepper(
                        String(cartQuantity),
                        value: $cartQuantity,
                        in: 0...totalQuantity
                    )
                } else if isSelectionAllowedWhenShopClosed {
                    Stepper(
                        String(cartQuantity),
                        value: $cartQuantity,
                        in: 0...999
                    )
                }
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(2)

                if shopStatus == .open {
                    Text("screen.shop.stock_left".localized(totalQuantity))
                        .font(.system(size: 14, weight: .medium))
                }

                Text(product.price.formatted())
                    .font(.system(size: 12, weight: .regular))
            }
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    ShopView(viewModel: ShopViewModelMock())
}

private final class ShopViewModelMock: ShopViewModelInput {
    var shopStatus: ShopContract.ShopStatus = .open

    var products: [ShopContract.Product] = [
        ShopContract.Product(id: 1, image: nil, categoryId: 2, name: "Pepsi", availableQuantity: 1, price: .init(amount: 3, currency: .eur)),
        ShopContract.Product(id: 2, image: nil, categoryId: 1, name: "Sandwich", availableQuantity: 1, price: .init(amount: 3, currency: .eur)),
        ShopContract.Product(id: 3, image: nil, categoryId: 2, name: "Sprite", availableQuantity: 1, price: .init(amount: 3, currency: .eur)),
        ShopContract.Product(id: 4, image: nil, categoryId: 2, name: "Fanta", availableQuantity: 1, price: .init(amount: 3, currency: .eur))
    ]

    var selectedProducts: [ShopContract.Product.ID: Int] = [:]

    var categories: [Category] = [
        Category(id: 1, name: "Sandwiches"),
        Category(id: 2, name: "Cold Drinks")
    ]
    var selectedCategory: Category?

    var ordersCount = 1

    var isSelectionAllowedWhenShopClosed = false

    func onAppear() { }

    func refresh() async { }

    init() {  }
}
