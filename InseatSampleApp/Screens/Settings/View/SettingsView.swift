import SwiftUI

struct SettingsView<ViewModel: SettingsViewModelInput>: View {

    @ObservedObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: .zero) {
                ScrollView {
                    VStack(spacing: 24) {
                        SettingsSwitchItem(
                            title: "settings.config.automatic_refresh".localized,
                            isOn: Binding(
                                get: {
                                    viewModel.isAutoUpdatesEnabled
                                },
                                set: { newValue in
                                    viewModel.isAutoUpdatesEnabled = newValue
                                }
                            )
                        )
                    }
                    .padding(.top, 24)
                }
                .background(Color.backgroundGray)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("screen.settings.title".localized)
        }
    }

    private struct SettingsSwitchItem: View {

        let title: String
        @Binding var isOn: Bool

        var body: some View {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.foregroundDark)

                Spacer()

                Toggle("", isOn: $isOn)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.backgroundLight)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 16)
        }
    }
}
