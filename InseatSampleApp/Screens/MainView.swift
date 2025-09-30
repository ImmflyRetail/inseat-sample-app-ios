import SwiftUI

struct MainView: View {

    var body: some View {
        TabView {
            MenuView(viewModel: MenuViewModel())
                .tabItem {
                    TabViewItem(title: "Shop", imageName: "Shop")
                }

            PromotionListView(viewModel: PromotionListViewModel())
                .tabItem {
                    TabViewItem(title: "Promotions", imageName: "Shop")
                }

            CartView(viewModel: CartViewModel())
                .tabItem {
                    TabViewItem(title: "Cart", imageName: "Cart")
                }

            OrdersView(viewModel: OrdersViewModel())
                .tabItem {
                    TabViewItem(title: "Orders", imageName: "Orders")
                }

            SettingsView(viewModel: SettingsViewModel())
                .tabItem {
                    TabViewItem(title: "Settings", imageName: "Settings")
                }
        }
        .tint(Color(hex: "DD083A"))
    }

    struct TabViewItem: View {

        let title: String
        let imageName: String

        var body: some View {
            VStack {
                Image(imageName).renderingMode(.template)
                Text(title)
            }
        }
    }
}
