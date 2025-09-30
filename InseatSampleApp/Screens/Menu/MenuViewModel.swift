import Combine
import Inseat

protocol MenuViewModelInput: ObservableObject {
    var menus: [MenuItem] { get }

    func onAppear()
    func fetchMenus() async
    func select(menu: MenuItem)
}

final class MenuViewModel: MenuViewModelInput {

    @Published var menus: [MenuItem] = []

    private var inseatMenus: [Inseat.Menu] = []

    func onAppear() {
        Task {
            try await Task.sleep(nanoseconds: 2_000_000_000)    // Sleep for 2 seconds
            await fetchMenus()
        }
    }

    func fetchMenus() async {
        do {
            let menus = try await InseatAPI.shared.fetchMenus()
            await MainActor.run {
                self.inseatMenus = menus
                self.menus = menus.map {
                    MenuItem(id: $0.key, name: $0.displayName.first!.text)
                }
            }
        } catch {
            print("[DEBUG] error while fetching menus")
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
