import SwiftUI

struct PromotionBuilderView<ViewModel: PromotionBuilderViewModelInput>: View {

    @EnvironmentObject var router: ShopRouter

    @ObservedObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationBar(
            title: "screen.promotion_builder.title".localized,
            leading: BackButton { router.navigateBack() }
        ) {
            VStack(spacing: .zero) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        makeHeaderSection()
                        makeIndividualItemSelectionSection()
                        makeCategorySelectionSection()
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 96)
                }
            }
            .background(Color.backgroundGray)
        }
        .toolbar(.hidden)
        .onAppear(perform: viewModel.onAppear)
        .safeAreaInset(edge: .bottom) {
            floatingBottomSection
        }
    }
    
    // MARK: - Floating bottom button

    private var floatingBottomSection: some View {
        VStack(spacing: 0) {
            Button("screen.promotion_builder.actions.add_to_cart".localized) {
                viewModel.addToCart()
            }
            .buttonStyle(BrandPrimaryButtonStyle())
            .disabled(!viewModel.isPromotionRequirementsSatisfied)
            .padding(16)
        }
    }

    private func makeHeaderSection() -> some View {
        VStack(spacing: 16) {
            PromotionBuilderHeaderView(
                promotionInfo: viewModel.promotionInfo
            )

            if let requiredTotalPrice = viewModel.requiredTotalSpending, let remainingSpending = viewModel.remainingSpending {
                PromotionBuilderSpendLimitProgressView(
                    currentSpending: viewModel.currentSpending,
                    remainingSpending: remainingSpending,
                    spendLimit: requiredTotalPrice
                )
            }
        }
    }

    private func makeIndividualItemSelectionSection() -> some View {
        ForEach(
            Array(viewModel.requiredIndividualProducts.enumerated()),
            id: \.element.product.id
        ) { (index, product) in
            if index != 0 {
                Divider()
            }
            makeProductGroupView(
                products: [product.product],
                isSatisfied: viewModel.isSafisfied(individualProduct: product),
                requiredQuantity: product.quantity,
                quantityLimit: { _ in
                    product.quantity
                },
                quantity: { productId in
                    Binding(
                        get: {
                            viewModel.individualProductSelection[productId] ?? 0
                        },
                        set: { quantity in
                            viewModel.individualProductSelection[productId] = quantity
                        }
                    )
                },
                isEnabled: { _ in true }
            )
        }
    }

    private func makeCategorySelectionSection() -> some View {
        ForEach(
            Array(viewModel.requiredCategories.enumerated()),
            id: \.element.categoryId
        ) { (index, category) in
            if index != 0 || !viewModel.requiredIndividualProducts.isEmpty {
                Divider()
            }
            makeProductGroupView(
                products: category.products,
                isSatisfied: viewModel.isSafisfied(category: category),
                requiredQuantity: category.quantity,
                quantityLimit: { productId in
                    viewModel.selectedQuantity(of: productId, in: category) + viewModel.remainingQuantity(for: category)
                },
                quantity: { productId in
                    Binding(
                        get: {
                            viewModel.categoryProductSelection[category.categoryId]?[productId] ?? 0
                        },
                        set: { quantity in
                            if viewModel.categoryProductSelection[category.categoryId] == nil {
                                viewModel.categoryProductSelection[category.categoryId] = [productId: quantity]
                            } else {
                                viewModel.categoryProductSelection[category.categoryId]?[productId] = quantity
                            }
                        }
                    )
                },
                isEnabled: { productId in
                    !viewModel.isSafisfied(category: category) || viewModel.selectedQuantity(of: productId, in: category) > 0
                }
            )
        }
    }

    private func makeProductGroupView(
        products: [Product],
        isSatisfied: Bool,
        requiredQuantity: Int?,
        quantityLimit: @escaping (Product.ID) -> Int?,
        quantity: @escaping (Product.ID) -> Binding<Int>,
        isEnabled: @escaping (Product.ID) -> Bool
    ) -> some View {

        VStack(alignment: .leading, spacing: 24) {
            if let requiredQuantity = requiredQuantity {
                HStack {
                    Text("screen.promotion_builder.select_n_items".localized(requiredQuantity))
                        .font(Font.appFont(size: 18, weight: .semibold))
                        .foregroundStyle(Color.foregroundDark)

                    Spacer()

                    Text(
                        isSatisfied
                        ? "screen.promotion_builder.satisfied".localized
                        : "screen.promotion_builder.required_n_items".localized(requiredQuantity)
                    )
                    .font(Font.appFont(size: 10, weight: .semibold))
                    .foregroundStyle(isSatisfied ? Color.basePositive : Color.foregroundDark)
                    .padding(.vertical, 7)
                    .padding(.horizontal, 8)
                    .background(isSatisfied ? Color.backgroundPositive : Color.complementary)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(products, id: \.id) { product in
                    PromotionBuilderProductView(
                        name: product.name,
                        description: product.description,
                        price: viewModel.displayProductPrices ? product.price : nil,
                        image: product.image,
                        quantityLimit: min(
                            product.availableQuantity,
                            quantityLimit(product.masterId) ?? product.availableQuantity
                        ),
                        quantity: quantity(product.masterId)
                    )
                    .padding(.bottom, 5)
                    .disabled(!isEnabled(product.masterId))
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        PromotionBuilderView(
            viewModel: PromotionBuilderViewModelMock(
                promotionInfo: .init(
                    name: "Sandwich + drink combo",
                    description: "Buy a Sandwich and a Premium Beer and get a You+ Peanut/You+ Chocolate for Free",
                    discountType: .fixedPrice(Price(amount: 5, currency: .eur))
                ),
                requiredIndividualProducts: [
                    PromotionBuilderContract.RequiredIndividualProduct(
                        product: Product(
                            id: 1,
                            masterId: 11,
                            categoryId: 111,
                            image: nil,
                            name: "Coca-Cola",
                            description: "Chilled 33cl can of Coca-cola zero.",
                            availableQuantity: 5,
                            price: Price(amount: 4, currency: .eur)
                        ),
                        quantity: 1
                    )
                ],
                requiredCategories: [
                    PromotionBuilderContract.RequiredCategory(
                        categoryId: 111,
                        products: [
                            Product(
                                id: 2,
                                masterId: 22,
                                categoryId: 111,
                                image: nil,
                                name: "Hot dog",
                                description: "Classic sausage in bun. Topping are on the side. ",
                                availableQuantity: 5,
                                price: Price(amount: 4, currency: .eur)
                            ),
                            Product(
                                id: 3,
                                masterId: 33,
                                categoryId: 111,
                                image: nil,
                                name: "Grilled cheese",
                                description: "Cheese, pastrami, caramelised onions.",
                                availableQuantity: 5,
                                price: Price(amount: 4, currency: .eur)
                            ),
                        ],
                        qualifier: .quantity(2)
                    )
                ]
            )
        )
    }
}

private final class PromotionBuilderViewModelMock: PromotionBuilderViewModelInput {

    let promotionInfo: PromotionBuilderContract.PromotionInfo

    @Published var requiredIndividualProducts: [PromotionBuilderContract.RequiredIndividualProduct] = []
    @Published var requiredCategories: [PromotionBuilderContract.RequiredCategory] = []

    @Published var individualProductSelection: [Product.ID: Int] = [:]
    @Published var categoryProductSelection: [Int: [Product.ID: Int]] = [:]

    @Published var currentSpending: Price
    @Published var remainingSpending: Price?
    @Published var requiredTotalSpending: Price?

    @Published var isPromotionRequirementsSatisfied = false

    let displayProductPrices = true

    init(
        promotionInfo: PromotionBuilderContract.PromotionInfo,
        requiredIndividualProducts: [PromotionBuilderContract.RequiredIndividualProduct] = [],
        requiredCategories: [PromotionBuilderContract.RequiredCategory] = [],
        currentSpending: Price = Price(amount: .zero, currency: .eur),
        remainingSpending: Price? = nil,
        requiredTotalSpending: Price? = nil
    ) {
        self.promotionInfo = promotionInfo
        self.requiredIndividualProducts = requiredIndividualProducts
        self.requiredCategories = requiredCategories
        self.currentSpending = currentSpending
        self.remainingSpending = remainingSpending
        self.requiredTotalSpending = requiredTotalSpending
    }

    func remainingQuantity(for individualProduct: PromotionBuilderContract.RequiredIndividualProduct) -> Int {
        return 1
    }

    func remainingQuantity(for category: PromotionBuilderContract.RequiredCategory) -> Int {
        return 2
    }

    func onAppear() { }

    func addToCart() { }
}
