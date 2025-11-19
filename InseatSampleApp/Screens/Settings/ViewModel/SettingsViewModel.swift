import Combine

protocol SettingsViewModelInput: ObservableObject {
    var isAutoUpdatesEnabled: Bool { get set }
}

final class SettingsViewModel: SettingsViewModelInput {

    @Published var isAutoUpdatesEnabled = true

    private var cancellables: Set<AnyCancellable> = []

    init() {
        isAutoUpdatesEnabled = AppSettings.automaticDataRefreshEnabled.value

        $isAutoUpdatesEnabled
            .sink { isEnabled in
                AppSettings.automaticDataRefreshEnabled.value = isEnabled
            }
            .store(in: &cancellables)
    }
}
