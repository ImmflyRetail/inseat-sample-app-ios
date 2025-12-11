import SwiftUI

struct ShopView<ViewModel: ShopViewModelInput>: View {

    @EnvironmentObject var router: ShopRouter

    @ObservedObject var viewModel: ViewModel

    @State private var selectedPage: Int? = 0
    @State private var selectedProduct: ShopContract.Product?

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
        GridItem(.flexible(), alignment: .top),
        GridItem(.flexible(), alignment: .top)
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
                                    products: viewModel.products(for: category)
                                )

                            case .promotions:
                                makePromotionsListView()
                            }
                        }
                        .tag(section.index)
                    }
                }
                .tabViewStyle(.page)

                if viewModel.shopStatus != .order {
                    ShopStatusView(shopStatus: viewModel.shopStatus)
                }
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
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(
                viewModel: ProductDetailViewModel(
                    product: {
                        ProductDetailContract.Product(
                            id: product.id,
                            image: product.image,
                            name: product.name,
                            description: product.description,
                            availableQuantity: product.availableQuantity,
                            price: product.price
                        )
                    }(),
                    shopStatus: {
                        switch viewModel.shopStatus {
                        case .unavailable:
                            return .unavailable
                        case .browse:
                            return .browse
                        case .order:
                            return .order
                        case .closed:
                            return .closed
                        }
                    }(),
                    quantity: makeQuantityBinding(for: product)
                )
            )
        }
    }

    private func makeTrailingNavigationButtons() -> some View {
        HStack(spacing: 16) {
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

    private func makeQuantityBinding(for product: ShopContract.Product) -> Binding<Int> {
        Binding(
            get: {
                viewModel.selectedProducts[product.id] ?? 0
            },
            set: { quantity in
                viewModel.selectedProducts[product.id] = quantity > 0 ? quantity : nil
            }
        )
    }

    private func makeShopListView(products: [ShopContract.Product]) -> some View {
        VStack(spacing: .zero) {
            ScrollView {
                Spacer(minLength: 24)

                if viewModel.shopStatus == .unavailable {
                    InfoView(text: "screen.shop.unavailable".localized)
                }

                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(products) { product in
                        ShopProductView(
                            product: product,
                            shopStatus: viewModel.shopStatus,
                            isSelectionAllowedWhenShopClosed: viewModel.isSelectionAllowedWhenShopClosed,
                            totalQuantity: .constant(product.availableQuantity),
                            cartQuantity: makeQuantityBinding(for: product)
                        )
                        .onTapGesture {
                            selectedProduct = product
                        }
                    }
                }

                Spacer(minLength: 24)
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal, 16)
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    private func makePromotionsListView() -> some View {
        PromotionListView(viewModel: PromotionListViewModel())
    }
}

#Preview {
    ShopView(viewModel: ShopViewModelMock())
}

private final class ShopViewModelMock: ShopViewModelInput {
    var shopStatus: ShopContract.ShopStatus = .order

    var products: [ShopContract.Product] = [
        ShopContract.Product(id: 1, image: nil, categoryId: 2, name: "Pepsi", description: "", availableQuantity: 1, price: .init(amount: 3, currency: .eur)),
        ShopContract.Product(id: 2, image: nil, categoryId: 1, name: "Sandwich", description: "", availableQuantity: 1, price: .init(amount: 3, currency: .eur)),
        ShopContract.Product(id: 3, image: nil, categoryId: 2, name: "Sprite", description: "", availableQuantity: 0, price: .init(amount: 3, currency: .eur)),
        ShopContract.Product(id: 4, image: nil, categoryId: 2, name: "Fanta", description: "", availableQuantity: 1, price: .init(amount: 3, currency: .eur))
    ]

    var selectedProducts: [ShopContract.Product.ID: Int] = [4: 1]

    var categories: [Category] = [
        Category(id: 1, name: "Sandwiches"),
        Category(id: 2, name: "Cold Drinks")
    ]

    var ordersCount = 1

    var isSelectionAllowedWhenShopClosed = false

    func onAppear() { }

    func refresh() async { }

    func products(for category: Category) -> [ShopContract.Product] {
        return products
    }

    init() {  }
}
