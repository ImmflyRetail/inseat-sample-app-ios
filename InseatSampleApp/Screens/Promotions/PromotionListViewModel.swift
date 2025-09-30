import Combine
import Inseat

protocol PromotionListViewModelInput: ObservableObject {
    var promotions: [PromotionItem] { get }
    func fetchPromotions() async
    func onAppear()
}

final class PromotionListViewModel: PromotionListViewModelInput {

    @Published var promotions: [PromotionItem] = []

    func onAppear() {
        Task {
            await fetchPromotions()
        }
    }

    func fetchPromotions() async {
        let promotions = (try? await InseatAPI.shared.fetchPromotions()) ?? []
        await MainActor.run {
            self.promotions = promotions.map { promotion in
                PromotionItem(
                    id: promotion.id,
                    name: promotion.name,
                    triggerType: {
                        switch promotion.triggerType {
                        case .productPurchase:
                            return .productPurchase

                        case .spendLimit:
                            return .spendLimit

                        @unknown default:
                            return .productPurchase
                        }
                    }(),
                    discountType: {
                        switch promotion.discountType {
                        case .percentage(let percentage):
                            return .percentage(percentage)

                        case .amount(let discounts):
                            let value = discounts.first { $0.currency == "EUR" } ?? discounts.first
                            return .amount(.init(amount: value?.amount ?? -1, currency: value?.currency ?? "N/A"))

                        case .fixedPrice(let fixedPrice):
                            let value = fixedPrice.first { $0.currency == "EUR" } ?? fixedPrice.first
                            return .fixedPrice(.init(amount: value?.amount ?? -1, currency: value?.currency ?? "N/A"))

                        case .coupon(let couponId):
                            return .coupon(couponId)

                        @unknown default:
                            return .percentage(.zero)
                        }
                    }()
                )
            }
        }
    }
}
