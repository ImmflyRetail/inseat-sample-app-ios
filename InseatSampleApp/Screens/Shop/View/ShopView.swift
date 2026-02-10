import SwiftUI

struct ShopView<ViewModel: ShopViewModelInput>: View {

    @EnvironmentObject var router: ShopRouter

    @ObservedObject var viewModel: ViewModel

    @State private var selectedPage: Int? = 0
    
    @State private var activeSheet: ShopSheet?
    
    @EnvironmentObject private var confirmationCenter: OrderConfirmationCenter
   
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    private let columns = [
        GridItem(.flexible(), alignment: .top),
        GridItem(.flexible(), alignment: .top)
    ]
    
    private var cartItemCount: Int {
        viewModel.selectedProducts.values.reduce(0, +)
    }

    private var shopSections: [ShopContract.Section] {
        var sections = [ShopContract.Section]()

        if let firstCategory = viewModel.categories.first {
            sections.append(.init(type: .products(category: firstCategory), index: 0))
            sections.append(.init(type: .promotions, index: 1))

            viewModel.categories.dropFirst().forEach { category in
                sections.append(.init(type: .products(category: category), index: sections.count))
            }
        } else {
            sections.append(.init(type: .promotions, index: 0))
        }

        return sections
    }

    var body: some View {
        NavigationBar(
            title: "screen.shop.title".localized,
            leading: BackButton { router.navigateBack() },
            trailing: makeTrailingNavigationButtons(),
            subheader: makeOrderCountHeaderView()
        ) {
            ZStack(alignment: .bottom) {
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
                                    makeShopListView(products: viewModel.products(for: category))

                                case .promotions:
                                    makePromotionsListView()
                                }
                            }
                            .tag(section.index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .ignoresSafeArea(.container, edges: .bottom)
                }
                .background(Color.backgroundGray)

                bottomOverlay
            }
        }
        .toolbar(.hidden)
        .onAppear(perform: viewModel.onAppear)
        .onChange(of: confirmationCenter.isPresented) { isPresented in
            if isPresented {
                activeSheet = .orderConfirmation
            }
        }
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
        .sheet(item: $activeSheet) { sheet in
            switch sheet {

            case .product(let product):
                ProductDetailView(
                    viewModel: ProductDetailViewModel(
                        product: .init(
                            id: product.id,
                            image: product.image,
                            name: product.name,
                            description: product.description,
                            availableQuantity: product.availableQuantity,
                            price: product.price
                        ),
                        shopStatus: {
                            switch viewModel.shopStatus {
                            case .unavailable: return .unavailable
                            case .browse: return .browse
                            case .order: return .order
                            case .closed: return .closed
                            }
                        }(),
                        quantity: makeQuantityBinding(for: product)
                    )
                )

            case .orderConfirmation:
                OrderConfirmationSheet(
                    image: Image(systemName: "checkmark.circle.fill"),
                    title: "screen.checkout.confirmation.title".localized,
                    message: "screen.checkout.confirmation.message".localized,
                    keepTitle: "screen.checkout.confirmation.keep_shopping".localized,
                    cancelTitle: "screen.checkout.confirmation.view_order_status".localized,
                    horizontalAlignment: .center,
                    onKeep: {
                        confirmationCenter.dismiss()
                        activeSheet = nil
                        withAnimation(.bouncy(extraBounce: 0)) {
                            router.navigateToShop()
                        }
                    },
                    onCancel: {
                        confirmationCenter.dismiss()
                        activeSheet = nil
                        withAnimation(.bouncy(extraBounce: 0)) {
                            router.navigate(to: .orders)
                        }
                    }
                )
            }
        }
    }

    // MARK: - Bottom section

    private var bottomSection: some View {
        Group {
            if viewModel.shopStatus == .order, cartItemCount > 0 {
                floatingCartBottomSection
            } else {
                ShopStatusView(shopStatus: viewModel.shopStatus)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: cartItemCount)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.shopStatus)
    }
    
    private var bottomOverlay: some View {
        Group {
            if viewModel.shopStatus == .order, cartItemCount > 0 {
                floatingCartBottomSection.padding()
            } else {
                ShopStatusView(shopStatus: viewModel.shopStatus)
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: cartItemCount)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.shopStatus)
    }

    private var floatingCartBottomSection: some View {
        Button {
            withAnimation(.bouncy(extraBounce: 0)) {
                router.navigate(to: .cart)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "cart")
                    .imageScale(.large)

                Text("screen.shop.view-cart".localized)
                    .font(Font.appFont(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(BrandPrimaryButtonStyle())
    }

    // MARK: - Trailing nav button

    private func makeTrailingNavigationButtons() -> some View {
        HStack(spacing: 16) {
            Button {
                router.navigate(to: .cart)
            } label: {
                CartIconBadgeView(count: cartItemCount)
                    .foregroundStyle(Color.primary)
                    .frame(width: 28, height: 28)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: cartItemCount)
            }
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
            get: { viewModel.selectedProducts[product.id] ?? 0 },
            set: { quantity in
                viewModel.selectedProducts[product.id] = quantity > 0 ? quantity : nil
            }
        )
    }

    // MARK: - Lists

    private func makeShopListView(products: [ShopContract.Product]) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.shopStatus == .unavailable {
                    InfoView(text: "screen.shop.unavailable".localized)
                }
                
                if products.isEmpty {
                    LazyVStack(alignment: .leading, spacing: .zero) {
                        Text("screen.product_detail.product_unavailable".localized)
                            .font(Font.appFont(size: 22, weight: .semibold))
                            .foregroundStyle(Color.foregroundDark)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 54)
                } else {
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
                                activeSheet = .product(product)
                            }
                        }
                    }
                    .padding(.bottom, 96)
                }
            }
            .padding(.top)
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal)
        .refreshable {
            await viewModel.refresh()
        }
    }

    private func makePromotionsListView() -> some View {
        PromotionListView(viewModel: PromotionListViewModel())
    }
}

#Preview {
    ShopView(viewModel: ShopViewModelMock())
}

private final class ShopViewModelMock: ObservableObject, ShopViewModelInput {

    @Published var shopStatus: ShopContract.ShopStatus = .order
    @Published var selectedProducts: [ShopContract.Product.ID: Int] = [4: 1]

    @Published private(set) var categories: [Category] = [
        Category(id: 1, name: "Sandwiches"),
        Category(id: 2, name: "Cold Drinks")
    ]

    @Published private(set) var ordersCount: Int = 1

    var isSelectionAllowedWhenShopClosed: Bool { false }

    var shopSections: [ShopContract.Section] {
        var sections: [ShopContract.Section] = []

        if let first = categories.first {
            sections.append(.init(type: .products(category: first), index: 0))
            sections.append(.init(type: .promotions, index: 1))

            categories.dropFirst().forEach { category in
                sections.append(.init(type: .products(category: category), index: sections.count))
            }
        } else {
            sections.append(.init(type: .promotions, index: 0))
        }

        return sections
    }

    private let allProducts: [ShopContract.Product] = [
        .init(id: 1, image: nil, categoryId: 2, name: "Pepsi", description: "", availableQuantity: 1, price: .init(amount: 3, currency: .eur)),
        .init(id: 2, image: nil, categoryId: 1, name: "Sandwich", description: "", availableQuantity: 1, price: .init(amount: 3, currency: .eur)),
        .init(id: 3, image: nil, categoryId: 2, name: "Sprite", description: "", availableQuantity: 0, price: .init(amount: 3, currency: .eur)),
        .init(id: 4, image: nil, categoryId: 2, name: "Fanta", description: "", availableQuantity: 1, price: .init(amount: 3, currency: .eur))
    ]

    init() { }

    func onAppear() { }

    func refresh() async { }

    func products(for category: Category) -> [ShopContract.Product] {
        allProducts.filter { $0.categoryId == category.id }
    }
}
