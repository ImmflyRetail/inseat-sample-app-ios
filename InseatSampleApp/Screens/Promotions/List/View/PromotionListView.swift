import SwiftUI
import Inseat

struct PromotionListView<ViewModel: PromotionListViewModelInput>: View {

    @EnvironmentObject var router: ShopRouter

    @ObservedObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                Text("screen.promotions.title".localized)
                    .font(Font.appFont(size: 22, weight: .semibold))
                    .foregroundStyle(Color.foregroundDark)
                    .padding(.top, 24)
                    .padding(.bottom, 8)
                    .padding(.horizontal, 16)

                ForEach(viewModel.promotions, id: \.id) { promotion in
                    PromotionListItemView(
                        promotion: promotion,
                        selectionHandler: {
                            router.navigate(to: .promotionBuilder(promotion: viewModel.promotion(id: promotion.id)))
                        }
                    )
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 96)
        }
        .refreshable {
            await viewModel.fetchPromotions()
        }
        .background(Color.backgroundGray)
        .onAppear(perform: viewModel.onAppear)
    }
}

private final class PromotionListViewModelMock: PromotionListViewModelInput {

    var promotions: [PromotionListContract.ListItem] = [
        PromotionListContract.ListItem(
            id: 1,
            name: "Sandwich & drink combo",
            description: "Choose your favourite sandwich and pair it with a refreshing drink.",
            image: UIImage(named: "Promotion_SandwichCombo"),
            discountType: .percentage(10)
        ),
        PromotionListContract.ListItem(
            id: 2,
            name: "The healthy combo",
            description: "Our wholesome meal options are what you need.",
            image: UIImage(named: "Promotion_HealthyCombo"),
            discountType: .amount(Price(amount: 2, currency: .eur))
        ),
        PromotionListContract.ListItem(
            id: 3,
            name: "Sandwich & drink combo",
            description: "Choose your favourite sandwich and pair it with a refreshing drink.",
            image: UIImage(named: "Promotion_SandwichCombo"),
            discountType: .fixedPrice(Price(amount: 5, currency: .eur))
        ),
        PromotionListContract.ListItem(
            id: 4,
            name: "Sandwich & drink combo",
            description: "Get this combo and earn a voucher with extra discounts to use on your next purchase on this flight.",
            image: UIImage(named: "Promotion_SandwichCombo"),
            discountType: .coupon
        )
    ]

    init() {}

    func onAppear() { }

    func fetchPromotions() async { }

    func promotion(id: Int) -> Inseat.Promotion {
        fatalError()
    }
}

#Preview {
    PromotionListView(viewModel: PromotionListViewModelMock())
}

