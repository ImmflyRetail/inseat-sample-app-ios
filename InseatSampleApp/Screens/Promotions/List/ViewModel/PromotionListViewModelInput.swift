import Combine
import Inseat

protocol PromotionListViewModelInput: ObservableObject {
    var promotions: [PromotionListContract.ListItem] { get }

    func fetchPromotions() async
    func promotion(id: Int) -> Inseat.Promotion

    func onAppear()
}
