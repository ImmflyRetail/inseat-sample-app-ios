import SwiftUI
import Combine

struct CheckoutView<ViewModel: CheckoutViewModelInput>: View {

    @EnvironmentObject var router: ShopRouter

    @ObservedObject var viewModel: ViewModel

    @State var isSummaryExpanded = false
    @State var isSavingsExpanded = false

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationBar(
            title: "screen.checkout.title".localized,
            leading: BackButton { router.navigateBack() }
        ) {
            ScrollView {
                VStack(spacing: 24) {
                    SectionView {
                        VStack(spacing: .zero) {
                            if isSummaryExpanded {
                                makeExpandedSummaryGroup()
                                    .padding(.bottom, 12)
                            } else {
                                makeCollapsedSummaryGroup()
                                    .padding(.bottom, 12)

                                Divider()
                            }

                            makeDropdownButton()
                                .padding(.top, 12)
                        }
                    }

                    SectionView {
                        makeInputGroup()
                    }

                    makeInfoGroup()
                }
                .padding(.top, 24)
                .padding(.horizontal, 16)
                ///Space so last content is not hidden behind the floating button
                .padding(.bottom, 96)
            }
            .safeAreaInset(edge: .bottom) {
                floatingBottomSection
            }
        }
        .toolbar(.hidden)
        .onAppear(perform: viewModel.onAppear)
    }

    // MARK: - Floating Bottom Button

    private var floatingBottomSection: some View {
        VStack(spacing: 0) {
            Button("screen.checkout.actions.order".localized, action: viewModel.makeOrder)
                .buttonStyle(BrandPrimaryButtonStyle())
                .disabled(!viewModel.isSeatNumberValid)
                .padding()
        }
    }

    // MARK: - Summary

    private func makeExpandedSummaryGroup() -> some View {
        VStack(alignment: .leading, spacing: 24) {
            FormGroupView(title: "screen.checkout.summary".localized) {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.displayData.cartItems, id: \.id) { item in
                        CartItemView(item: CartItemView.Item(item))
                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                PriceKeyValueView(
                    title: "screen.checkout.summary.subtotal".localized,
                    price: viewModel.displayData.subtotalPrice
                )

                if let savings = viewModel.displayData.totalSaving {
                    ExpandablePriceKeyValueView(
                        title: "screen.checkout.summary.savings".localized,
                        price: savings.negative,
                        style: .normal,
                        isExpanded: $isSavingsExpanded,
                        expandableContent: {
                            VStack(spacing: 8) {
                                ForEach(viewModel.displayData.appliedPromotions, id: \.id) { promotion in
                                    Text(promotion.name)
                                        .font(Font.appFont(size: 12, weight: .regular))
                                        .foregroundStyle(Color.foregroundLight)
                                }
                            }
                        },
                        expandAction: {
                            withAnimation(.bouncy) {
                                isSavingsExpanded.toggle()
                            }
                        }
                    )
                }

                PriceKeyValueView(
                    title: "screen.checkout.summary.total".localized,
                    price: viewModel.displayData.totalPrice,
                    style: .large
                )
            }
        }
    }

    private func makeCollapsedSummaryGroup() -> some View {
        HStack(spacing: 8) {
            Spacer()
            Text(makeAttributedText())
            Spacer()
        }
        .foregroundStyle(Color.foregroundDark)
        .padding(.vertical, 12)
    }

    private func makeAttributedText() -> AttributedString {
        var text1 = AttributedString("screen.checkout.items".localized(viewModel.displayData.cartItems.count) + " ")

        text1.font = Font.appFont(size: 16, weight: .regular)
        text1.foregroundColor = Color.foregroundDark

        var text2 = AttributedString(viewModel.displayData.totalPrice.formatted())
        text2.font = Font.appFont(size: 16, weight: .semibold)
        text2.foregroundColor = Color.foregroundDark

        return text1 + text2
    }

    private func makeDropdownButton() -> some View {
        DropdownButton(
            style: .dropdown(
                expandedTitle: "screen.checkout.actions.expand".localized,
                collapsedTitle: "screen.checkout.actions.collapse".localized
            ),
            isExpanded: $isSummaryExpanded,
            action: {
                withAnimation(.bouncy) {
                    isSummaryExpanded.toggle()
                }
            }
        )
    }

    // MARK: - Input + Info

    private func makeInputGroup() -> some View {
        FormGroupView(title: "screen.checkout.input".localized) {
            TextInputView(
                label: "screen.checkout.input.seat.title".localized,
                placeholder: "screen.checkout.input.seat.placeholder".localized,
                value: $viewModel.seatNumber,
                isValid: viewModel.isSeatNumberValid
            )
        }
    }

    private func makeInfoGroup() -> some View {
        InfoView(text: "screen.checkout.info".localized)
    }
}

// MARK: - Mapping helper

extension CartItemView.Item {
    init(_ cartItem: CheckoutContract.DisplayData.Item) {
        self.init(
            id: cartItem.id,
            name: cartItem.name,
            quantity: cartItem.quantity,
            unitPrice: cartItem.unitPrice
        )
    }
}

// MARK: - Preview

#Preview {
    CheckoutView(viewModel: CheckoutViewModelMock())
}

private final class CheckoutViewModelMock: CheckoutViewModelInput {

    var displayData: CheckoutContract.DisplayData {
        CheckoutContract.DisplayData(
            cartItems: [
                .init(id: 1, masterId: 11, name: "Coca-Cola", quantity: 1, unitPrice: .init(amount: 3, currency: .eur)),
                .init(id: 2, masterId: 22, name: "Fanta", quantity: 2, unitPrice: .init(amount: 3, currency: .eur))
            ],
            subtotalPrice: .init(amount: 6, currency: .eur),
            totalSaving: nil,
            appliedPromotions: [],
            totalPrice: .init(amount: 6, currency: .eur)
        )
    }

    @Published var seatNumber: String = ""
    @Published var isSeatNumberValid = false

    private var cancellables: Set<AnyCancellable> = []

    func onAppear() { }

    func makeOrder() { }

    init() {
        $seatNumber
            .map { seatNumber in
                let regex = /^([1-9]+[A-Z])$/
                return (try? regex.wholeMatch(in: seatNumber)) != nil
            }
            .removeDuplicates()
            .sink { [weak self] isValid in
                self?.isSeatNumberValid = isValid
            }
            .store(in: &cancellables)
    }
}
