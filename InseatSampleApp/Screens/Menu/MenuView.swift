import SwiftUI

struct MenuView<ViewModel: MenuViewModelInput>: View {

    @ObservedObject var router = ShopRouter()

    @ObservedObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack(path: $router.navPath) {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Menu selection")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(Color.darkForeground)

                        Text("Choose which menu you want to view based on your preferences.")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(Color.darkForeground)
                    }

                    VStack(spacing: 16) {
                        ForEach(viewModel.menus, id: \.id) { menu in
                            Button(menu.name) {
                                viewModel.select(menu: menu)
                                router.navigate(to: .shop)
                            }
                            .buttonStyle(BrandButtonStyle())
                        }
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 16)
            }
            .background(Color.backgroundGray)
            .onAppear(perform: viewModel.onAppear)
            .navigationDestination(for: ShopRouter.Destination.self) { destination in
                switch destination {
                case .shop:
                    return ShopView(viewModel: ShopViewModel())
                }
            }
        }
    }
}

private final class MenuViewModelMock: MenuViewModelInput {

    var menus: [MenuItem] = [
        MenuItem(id: "123", name: "Inseat EU"),
        MenuItem(id: "456", name: "Inseat UK")
    ]

    init() {}

    func onAppear() { }

    func select(menu: MenuItem) { }
}

#Preview {
    MenuView(viewModel: MenuViewModelMock())
}
