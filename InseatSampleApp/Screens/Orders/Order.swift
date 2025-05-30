import Foundation

struct Order {
    typealias ID = String

    enum Status {
        case placed
        case received
        case preparing
        case cancelledByCrew
        case cancelledByPassenger
        case cancelledByTimeout
        case completed
    }

    let id: ID
    let seatNumber: String
    let items: [OrderItem]
    let totalPrice: Price
    let status: Status
    let createdAt: Date
}
