import Combine

enum AppSettings {
    static let automaticDataRefreshEnabled = CurrentValueSubject<Bool, Never>(true)
}
