import Foundation

struct Order: Codable, Hashable {
    typealias ID = String

    enum Status: Codable, Hashable {
        case placed
        case received
        case preparing
        case cancelledByCrew
        case cancelledByPassenger
        case cancelledByTimeout
        case completed
        case refunded
    }

    struct Item: Codable, Hashable {
        typealias ID = Int

        let id: ID
        let name: String
        let quantity: Int
        /// Price per single item.
        let unitPrice: Price
    }

    let id: ID
    let seatNumber: String
    let items: [Item]

    let subtotalPrice: Price
    let totalSavings: Price?
    let totalPrice: Price

    let status: Status
    let createdAt: Date
}

extension Order {

    enum DisplayStatus: Equatable {
        case placed
        case preparing
        case delivered(DeliveryStatus)

        var sortedStages: [DisplayStatus] {
            var stages: [DisplayStatus] = [.placed, .preparing]

            switch self {
            case .placed, .preparing:
                stages.append(.delivered(.delivered))

            case .delivered(let status):
                stages.append(.delivered(status))
            }

            return stages
        }

        init(rawStatus: Status) {
            switch rawStatus {
            case .placed, .received:
                self = .placed

            case .preparing:
                self = .preparing

            case .cancelledByCrew:
                self = .delivered(.cancelled)

            case .cancelledByPassenger:
                self = .delivered(.cancelled)

            case .cancelledByTimeout:
                self = .delivered(.cancelled)

            case .completed:
                self = .delivered(.delivered)

            case .refunded:
                self = .delivered(.refunded)
            }
        }
    }

    enum DeliveryStatus: Equatable {
        case cancelled
        case delivered
        case refunded
    }

    var displayStatus: DisplayStatus {
        return DisplayStatus(rawStatus: status)
    }
}
