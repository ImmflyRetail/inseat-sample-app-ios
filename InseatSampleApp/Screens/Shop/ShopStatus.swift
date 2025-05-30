enum ShopStatus {
    case unavailable
    case open
    case closed

    var displayName: String {
        switch self {
        case .unavailable:
            return "Closed"
        case .open:
            return "Open"
        case .closed:
            return "Closed"
        }
    }
}
