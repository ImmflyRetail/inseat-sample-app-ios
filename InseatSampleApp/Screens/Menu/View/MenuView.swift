import SwiftUI

struct MenuView<ViewModel: MenuViewModelInput>: View {

    @EnvironmentObject var router: ShopRouter

    @ObservedObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack(path: $router.navPath) {
            NavigationBar(title: "screen.menu.title".localized) {
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("screen.menu.subtitle".localized)
                                .font(Font.appFont(size: 22, weight: .semibold))
                                .foregroundStyle(Color.foregroundDark)

                            Text("screen.menu.select".localized)
                                .font(Font.appFont(size: 18, weight: .regular))
                                .font(.system(size: 18, weight: .regular))
                                .foregroundStyle(Color.foregroundDark)
                        }

                        VStack(spacing: 16) {
                            ForEach(viewModel.menus, id: \.id) { menu in
                                Button(menu.name) {
                                    viewModel.select(menu: menu)
                                    router.navigate(to: .shop)
                                }
                                .buttonStyle(BrandPrimaryButtonStyle())
                            }
                        }
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal, 16)
                }
                .refreshable {
                    await viewModel.fetchMenus()
                }
                .background(Color.backgroundGray)
            }
            .toolbar(.hidden)
            .onAppear(perform: viewModel.onAppear)
            .navigationDestination(for: ShopRouter.MenuDestination.self) { destination in
                switch destination {
                case .shop:
                    ShopView(viewModel: ShopViewModel())
                }
            }
        }
    }
}

private final class MenuViewModelMock: MenuViewModelInput {

    var menus: [Menu] = [
        Menu(id: "123", name: "Inseat EU"),
        Menu(id: "456", name: "Inseat UK")
    ]

    init() {}

    func onAppear() { }

    func fetchMenus() async { }

    func select(menu: Menu) { }
}

#Preview {
    MenuView(viewModel: MenuViewModelMock())
}
