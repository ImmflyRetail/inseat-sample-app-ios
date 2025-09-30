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

