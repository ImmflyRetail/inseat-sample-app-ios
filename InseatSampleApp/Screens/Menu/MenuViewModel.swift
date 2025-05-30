import Combine
import Inseat

protocol MenuViewModelInput: ObservableObject {
    var menus: [MenuItem] { get }

    func onAppear()
    func select(menu: MenuItem)
}

final class MenuViewModel: MenuViewModelInput {

    @Published var menus: [MenuItem] = []

    private var inseatMenus: [Inseat.Menu] = []

    func onAppear() {
        Task {
            let menus = try await InseatAPI.shared.fetchMenus()
            await MainActor.run {
                self.inseatMenus = menus
                self.menus = menus.map {
                    MenuItem(id: $0.key, name: $0.displayName.first!.text)
                }
            }
        }
    }

    func select(menu: MenuItem) {
        guard let inseatMenu = inseatMenus.first(where: { $0.key == menu.id }) else {
            return
        }
        let userData = UserData(menu: inseatMenu)
        InseatAPI.shared.setUserData(userData)
    }
}
