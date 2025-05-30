import SwiftUI

struct ShopView<ViewModel: ShopViewModelInput>: View {

    @ObservedObject var viewModel: ViewModel

    @State private var showCategorySelector: Bool = false

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: .zero) {
            Spacer(minLength: 4)

            Text("Shop Status: \(viewModel.shopStatus.displayName)")
                .foregroundStyle(viewModel.shopStatus == .open ? Color.successText : Color.errorText)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .font(Font.system(size: 14))
                .background(viewModel.shopStatus == .open ? Color.successBackground : Color.errorBackground)

            ScrollView {
                if viewModel.shopStatus == .unavailable {
                    InfoView(text: "The store is not open yet! Feel free to explore the available products, but keep in mind that prices and stock may change when the store officially opens.")
                        .padding(.all, 16)
                }

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(viewModel.products, id: \.id) { product in
                        ProductItemView(
                            product: product,
                            shopStatus: viewModel.shopStatus,
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
        .background(Color.backgroundGray)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .navigationTitle("Shop")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showCategorySelector.toggle()
                }, label: {
                    Image("Filter")
                })
            }
        }
        .sheet(isPresented: $showCategorySelector) {
            CategoriesView(
                selectedCategory: $viewModel.selectedCategory,
                viewModel: CategoriesViewModel()
            )
        }
        .onAppear(perform: viewModel.onAppear)
    }
}

private struct ProductItemView: View {

    let product: ShopProductItem
    let shopStatus: ShopStatus

    @Binding var totalQuantity: Int
    @Binding var cartQuantity: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .center, spacing: .zero) {
                Image(uiImage: product.image ?? UIImage(named: "ImagePlaceholder")!)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                if shopStatus == .open {
                    Stepper(
                        "\(cartQuantity)",
                        value: $cartQuantity,
                        in: 0...totalQuantity
                    )
                }
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(2)

                if shopStatus == .open {
                    Text("Stock: \(totalQuantity)")
                        .font(.system(size: 14, weight: .medium))
                }

                Text("\(product.price.currencyCode) \(product.price.amount)")
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
    var shopStatus: ShopStatus = .open

    var products: [ShopProductItem] = [
        ShopProductItem(id: 1, image: nil, categoryId: 1, name: "Pepsi", availableQuantity: 1, price: .init(amount: 3, currencyCode: "EUR")),
        ShopProductItem(id: 2, image: nil, categoryId: 1, name: "Sandwich", availableQuantity: 1, price: .init(amount: 3, currencyCode: "EUR")),
        ShopProductItem(id: 3, image: nil, categoryId: 1, name: "Sprite", availableQuantity: 1, price: .init(amount: 3, currencyCode: "EUR")),
        ShopProductItem(id: 4, image: nil, categoryId: 1, name: "Fanta", availableQuantity: 1, price: .init(amount: 3, currencyCode: "EUR"))
    ]

    var selectedProducts: [ShopProductItem.ID: Int] = [:]

    var selectedCategory: CategoryItem?

    func onAppear() { }

    func refresh() async { }

    init() {  }
}
