import Combine

protocol PromotionBuilderViewModelInput: ObservableObject {
    var promotionInfo: PromotionBuilderContract.PromotionInfo { get }

    var requiredIndividualProducts: [PromotionBuilderContract.RequiredIndividualProduct] { get }
    var requiredCategories: [PromotionBuilderContract.RequiredCategory] { get }

    var individualProductSelection: [Product.ID: Int] { get set }
    var categoryProductSelection: [Int: [Product.ID: Int]] { get set }

    var currentSpending: Price { get }
    var remainingSpending: Price? { get }
    var requiredTotalSpending: Price? { get }

    var isPromotionRequirementsSatisfied: Bool { get }

    var displayProductPrices: Bool { get }

    func remainingQuantity(for individualProduct: PromotionBuilderContract.RequiredIndividualProduct) -> Int
    func isSafisfied(individualProduct: PromotionBuilderContract.RequiredIndividualProduct) -> Bool

    func remainingQuantity(for category: PromotionBuilderContract.RequiredCategory) -> Int
    func isSafisfied(category: PromotionBuilderContract.RequiredCategory) -> Bool

    func onAppear()
    func addToCart()
}

extension PromotionBuilderViewModelInput {

    func isSafisfied(individualProduct: PromotionBuilderContract.RequiredIndividualProduct) -> Bool {
        return remainingQuantity(for: individualProduct) == 0
    }

    func isSafisfied(category: PromotionBuilderContract.RequiredCategory) -> Bool {
        return remainingQuantity(for: category) == 0
    }

    func selectedQuantity(of productId: Product.ID, in category: PromotionBuilderContract.RequiredCategory) -> Int {
        return categoryProductSelection[category.categoryId]?[productId] ?? 0
    }
}
