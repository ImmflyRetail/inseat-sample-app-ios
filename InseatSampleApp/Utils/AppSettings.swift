import Combine

enum AppSettings {
    static let automaticDataRefreshEnabled = CurrentValueSubject<Bool, Never>(true)

    // Only for development convenience while running app on simulator.
    static let isOrdersEnabledWhenShopClosed = false
}
