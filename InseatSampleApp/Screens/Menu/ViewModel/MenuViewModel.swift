import Combine
import Inseat

protocol MenuViewModelInput: ObservableObject {
    var menus: [Menu] { get }

    func onAppear()
    func fetchMenus() async
    func select(menu: Menu)
}

final class MenuViewModel: MenuViewModelInput {

    @Published var menus: [Menu] = []

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
                    Menu(id: $0.key, name: $0.displayName.first!.text)
                }
            }
        } catch {
            Logger.log("error while fetching menus", level: .error)
        }
    }

    func select(menu: Menu) {
        guard let inseatMenu = inseatMenus.first(where: { $0.key == menu.id }) else {
            return
        }
        let userData = UserData(menu: inseatMenu)
        InseatAPI.shared.setUserData(userData)
    }
}
