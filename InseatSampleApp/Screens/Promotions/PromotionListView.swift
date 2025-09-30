import SwiftUI

struct PromotionListView<ViewModel: PromotionListViewModelInput>: View {

    @ObservedObject var router = PromotionsRouter()

    @ObservedObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack(path: $router.navPath) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    Text("Total Count: \(viewModel.promotions.count)")
                        .padding(.horizontal, 16)

                    ForEach(viewModel.promotions, id: \.id) { promotion in
                        PromotionItemView(promotion: promotion)
                    }
                }
            }
            .refreshable {
                await viewModel.fetchPromotions()
            }
            .background(Color.backgroundGray)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Promotions")
            .onAppear(perform: viewModel.onAppear)
        }
    }
}

private struct PromotionItemView: View {

    let promotion: PromotionItem

    var body: some View {
        VStack(alignment: .leading) {
            Text("ID: \(promotion.id) | \(promotion.name)")
                .font(.system(size: 18, weight: .medium))
            Text("Trigger Type: \(promotion.triggerType.displayName)")
                .font(.system(size: 16, weight: .regular))
            Text("Discount Type: \(promotion.discountType.displayName)")
                .font(.system(size: 16, weight: .regular))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

private final class PromotionListViewModelMock: PromotionListViewModelInput {

    var promotions: [PromotionItem] = [
        PromotionItem(id: 1, name: "Meal Deal", triggerType: .productPurchase, discountType: .percentage(10)),
        PromotionItem(id: 2, name: "Meal Deal", triggerType: .productPurchase, discountType: .amount(.init(amount: 1, currency: "EUR"))),
        PromotionItem(id: 3, name: "Meal Deal", triggerType: .productPurchase, discountType: .fixedPrice(.init(amount: 4, currency: "EUR"))),
        PromotionItem(id: 4, name: "Meal Deal", triggerType: .productPurchase, discountType: .coupon(1234))
    ]

    init() {}

    func onAppear() { }

    func fetchPromotions() async {

    }
}

#Preview {
    PromotionListView(viewModel: PromotionListViewModelMock())
}

