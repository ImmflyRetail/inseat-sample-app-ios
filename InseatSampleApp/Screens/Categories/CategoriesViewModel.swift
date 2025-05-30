import Combine
import SwiftUI
import Inseat

protocol CategoriesViewModelInput: ObservableObject {
    var categories: [CategoryItem] { get }
    func onAppear()
}

final class CategoriesViewModel: CategoriesViewModelInput {

    @Published var categories: [CategoryItem] = []

    func onAppear() {
        Task {
            let categories = try await InseatAPI.shared
                .fetchCategories()
                .flatMap { $0.subcategories }
                .sorted(by: { ($0.sortOrder ?? 0) < ($1.sortOrder ?? 0) })
                .map {
                    CategoryItem(id: $0.categoryId, name: $0.name)
                }

            await MainActor.run {
                self.categories = categories
            }
        }
    }
}
