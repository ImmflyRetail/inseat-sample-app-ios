import Foundation
import Combine
import Inseat

protocol ShopViewModelInput: ObservableObject {
    var shopStatus: ShopStatus { get }
    var products: [ShopProductItem] { get }
    var selectedProducts: [ShopProductItem.ID: Int] { get set }
    var selectedCategory: CategoryItem? { get set }

    func onAppear()
    func refresh() async
}

final class ShopViewModel: ShopViewModelInput {

    @Published var shopStatus: ShopStatus = .closed

    private var allProducts: [ShopProductItem] = []
    @Published var products: [ShopProductItem] = []

    @Published var selectedProducts: [ShopProductItem.ID: Int] = [:] {
        didSet {
            cartManager.updateCart(products: selectedProducts)
        }
    }

    @Published var selectedCategory: CategoryItem?

    private let cartManager: CartManaging

    // Observer is cancelled after this reference is removed from memory.
    private var shopObserver: Observer?
    private var productsObserver: Observer?

    private var cancellables: Set<AnyCancellable> = []

    init(cartManager: CartManaging = CartManager.shared) {
        self.cartManager = cartManager

        $selectedCategory
            .sink { [weak self] category in
                guard let self = self else {
                    return
                }
                self.products = self.allProducts.filter {
                    if let id = category?.id {
                        return $0.categoryId == id
                    }
                    return true
                }
            }
            .store(in: &cancellables)

        // It's included only for testing purposes to test fetching methods separately.
        AppSettings
            .automaticDataRefreshEnabled
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] automaticDataRefreshEnabled in
                if automaticDataRefreshEnabled {
                    self?.addObservers()
                } else {
                    self?.removeObservers()
                }
            }
            .store(in: &cancellables)
    }

    func onAppear() {
        addObservers()
        updateProductsFromCart()
    }

    func refresh() async {
        do {
            async let shopQuery = try InseatAPI.shared.fetchShop()
            async let productsQuery = try InseatAPI.shared.fetchProducts()

            let (shop, products) = try await (shopQuery, productsQuery)

            await MainActor.run {
                handleShop(shop)
                handleProducts(products)
            }
        } catch {
            print("Error while refreshing: \(error)")
        }
    }

    private func updateProductsFromCart() {
        selectedProducts = cartManager.selectedProducts
    }

    private func addObservers() {
        do {
            guard productsObserver == nil else {
                return
            }
            shopObserver = try InseatAPI.shared.observeShop { [weak self] shop in
                self?.handleShop(shop)
            }
            productsObserver = try InseatAPI.shared.observeProducts { [weak self] products in
                self?.handleProducts(products)
            }
        } catch {
            print("Error while registering observers: '\(error)'")
        }
    }

    private func removeObservers() {
        shopObserver = nil
        productsObserver = nil
    }

    private func handleShop(_ shop: Inseat.Shop?) {
        guard let shop = shop else {
            shopStatus = .unavailable
            return
        }
        switch shop.status {
        case .open:
            shopStatus = .open

        case .order:
            shopStatus = .open

        case .closed:
            shopStatus = .closed

        @unknown default:
            break
        }
    }

    private func handleProducts(_ products: [Inseat.Product]) {
        let date = Date()
        let products = products
            .sorted(by: { $0.name < $1.name })
            .filter {
                guard let start = $0.startDate, let end = $0.endDate else {
                    return true
                }
                return (start...end).contains(date)
            }

        cartManager.setAvailableProducts(products: products.map {
            Product(
                id: $0.id,
                image: $0.image,
                name: $0.name,
                availableQuantity: $0.quantity,
                price: .init(
                    amount: $0.prices.first { $0.currencyCode == "EUR" }?.amount ?? .zero,
                    currencyCode: $0.prices.first { $0.currencyCode == "EUR" }?.currencyCode ?? ""
                )
            )
        })

        self.allProducts = products.map {
            ShopProductItem(
                id: $0.id,
                image: $0.image,
                categoryId: $0.categoryId,
                name: $0.name,
                availableQuantity: $0.quantity,
                price: .init(
                    amount: $0.prices.first { $0.currencyCode == "EUR" }?.amount ?? .zero,
                    currencyCode: $0.prices.first { $0.currencyCode == "EUR" }?.currencyCode ?? ""
                )
            )
        }
        self.products = self.allProducts.filter {
            if let id = selectedCategory?.id {
                return $0.categoryId == id
            }
            return true
        }
    }
}
