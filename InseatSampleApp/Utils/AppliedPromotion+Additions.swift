import Inseat

extension Inseat.AppliedPromotion {

    var totalSaving: Money? {
        switch benefitType {
        case .discount(let totalSaving):
            return totalSaving

        case .coupon:
            return nil

        @unknown default:
            return nil
        }
    }
}

extension Array where Element == Inseat.Product {
    var signature: Int {
        var hasher = Hasher()
        hasher.combine(count)
        
        for product in self {
            hasher.combine(product.id)
            hasher.combine(product.masterId)
            hasher.combine(product.quantity)
            hasher.combine(product.name)
        }
        return hasher.finalize()
    }
}

extension Array where Element == Inseat.Category {
    var signature: Int {
        var hasher = Hasher()
        hasher.combine(count)
        
        for cat in self {
            hasher.combine(cat.categoryId)
            hasher.combine(cat.name)
            hasher.combine(cat.sortOrder ?? 0)
            hasher.combine(cat.subcategories.count)
        }
        return hasher.finalize()
    }
}

extension Inseat.Shop {
    var signature: Int {
        var hasher = Hasher()
        hasher.combine(status)
        hasher.combine(id)
        return hasher.finalize()
    }
}
