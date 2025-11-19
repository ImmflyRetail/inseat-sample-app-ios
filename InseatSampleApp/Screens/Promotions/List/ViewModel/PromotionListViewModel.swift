import Combine
import Inseat

final class PromotionListViewModel: PromotionListViewModelInput {

    @Published var promotions: [PromotionListContract.ListItem] = []

    private var rawPromotions: [Inseat.Promotion] = []

    private let cartManager: CartManaging

    init(cartManager: CartManaging = CartManager.shared) {
        self.cartManager = cartManager
    }

    func onAppear() {
        Task {
            await fetchPromotions()
        }
    }

    func fetchPromotions() async {
        let promotions = (try? await InseatAPI.shared.fetchPromotions()) ?? []

        Logger.log("[Promotions] count = \(promotions.count)", level: .info)

        await MainActor.run {
            self.rawPromotions = promotions
            self.promotions = promotions.compactMap { promotion -> PromotionListContract.ListItem? in
                let discountType: PromotionListContract.ListItem.DiscountType
                switch promotion.discountType {
                case .percentage(let percentage):
                    discountType = .percentage(percentage)

                case .amount(let discounts):
                    guard let value = discounts.first(where: { $0.currency == cartManager.selectedCurrency.code }) else {
                        return nil
                    }
                    discountType = .amount(.init(amount: value.amount, currency: cartManager.selectedCurrency))

                case .fixedPrice(let fixedPrice):
                    guard let value = fixedPrice.first(where: { $0.currency == cartManager.selectedCurrency.code }) else {
                        return nil
                    }
                    discountType = .fixedPrice(.init(amount: value.amount, currency: cartManager.selectedCurrency))

                case .coupon:
                    discountType = .coupon

                @unknown default:
                    discountType = .percentage(.zero)
                }
                return PromotionListContract.ListItem(
                    id: promotion.id,
                    name: promotion.name,
                    description: promotion.description,
                    image: promotion.image,
                    discountType: discountType
                )
            }
        }
    }

    func promotion(id: Int) -> Inseat.Promotion {
        return rawPromotions.first { $0.id == id }!
    }
}
