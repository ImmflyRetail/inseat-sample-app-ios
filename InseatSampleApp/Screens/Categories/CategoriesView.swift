import SwiftUI

struct CategoriesView<ViewModel: CategoriesViewModelInput>: View {

    @Environment(\.dismiss) private var dismiss

    @Binding var selectedCategory: CategoryItem?

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: .zero) {
                List {
                    CategoryItemView(
                        title: "All",
                        isSelected: Binding(
                            get: {
                                selectedCategory == nil
                            },
                            set: { newValue in
                                selectedCategory = nil
                                dismiss()
                            }
                        )
                    )
                    ForEach(viewModel.categories, id: \.id) { category in
                        CategoryItemView(
                            title: category.name,
                            isSelected: Binding(
                                get: {
                                    selectedCategory?.id == category.id
                                },
                                set: { newValue in
                                    if newValue {
                                        selectedCategory = category
                                        dismiss()
                                    }
                                }
                            )
                        )
                    }
                }
                .background(Color.backgroundGray)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("Cancel")
                    }
                }
            }
            .onAppear(perform: viewModel.onAppear)
        }
    }

    private struct CategoryItemView: View {

        let title: String
        @Binding var isSelected: Bool

        var body: some View {
            HStack(spacing: 0) {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.darkForeground)

                Spacer()

                Button {
                    isSelected.toggle()
                } label: {
                    if isSelected {
                        Image("Check")
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .frame(maxWidth: .infinity)
        }
    }
}
