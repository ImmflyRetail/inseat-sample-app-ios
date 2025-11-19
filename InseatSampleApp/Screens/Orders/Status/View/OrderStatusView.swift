import SwiftUI

struct OrderStatusView<ViewModel: OrderStatusViewModelInput>: View {

    @EnvironmentObject var router: ShopRouter

    @ObservedObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationBar(
            title: "screen.order_status.title".localized,
            leading: BackButton { router.navigateBack() }
        ) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SectionView {
                        makeHeaderGroup()
                    }

                    SectionView {
                        VStack(alignment: .leading, spacing: 24) {
                            Text(DateFormatter.orderDateString(from: viewModel.order.createdAt))
                                .font(Font.appFont(size: 12, weight: .regular))
                                .foregroundStyle(Color.foregroundLight)

                            makeDetailsGroup()
                            Divider()

                            makeSummaryGroup()
                            Divider()

                            makeTotalsGroup()
                        }
                    }

                    if viewModel.order.status == .placed {
                        makeCancellationGroup()
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity)
            .background(Color.backgroundGray)
        }
        .toolbar(.hidden)
        .onAppear(perform: viewModel.onAppear)
    }

    private func makeHeaderGroup() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(viewModel.order.displayStatus.localizedTitle)
                .font(Font.appFont(size: 24, weight: .semibold))
                .foregroundStyle(Color.foregroundDark)

            StageView(
                stages: viewModel.order.displayStatus.sortedStages.map {
                    Stage(title: $0.localizedStageName)
                },
                currentIndex: viewModel.order.displayStatus.sortedStages.firstIndex(of: viewModel.order.displayStatus)
            )

            Text("screen.order_status.expected_delivery".localized)
                .font(Font.appFont(size: 10, weight: .regular))
                .foregroundStyle(Color.foregroundLight)
        }
    }

    private func makeDetailsGroup() -> some View {
        FormGroupView(title: "screen.order_status.summary.details".localized) {
            VStack(alignment: .leading, spacing: 16) {
                VerticalKeyValueView(key: "screen.order_status.summary.details.order_id".localized, value: viewModel.order.id)
                VerticalKeyValueView(key: "screen.order_status.summary.details.seat_number".localized, value: viewModel.order.seatNumber)
            }
        }
    }

    private func makeSummaryGroup() -> some View {
        FormGroupView(title: "screen.order_status.summary".localized) {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.order.items, id: \.id) { item in
                    CartItemView(
                        item: CartItemView.Item(item)
                    )
                }
            }
        }
    }

    private func makeTotalsGroup() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            PriceKeyValueView(title: "screen.order_status.summary.subtotal".localized, price: viewModel.order.subtotalPrice)

            if let savings = viewModel.order.totalSavings {
                PriceKeyValueView(title: "screen.order_status.summary.savings".localized, price: savings.negative)
            }
            PriceKeyValueView(title: "screen.order_status.summary.total".localized, price: viewModel.order.totalPrice, style: .large)
        }
    }

    private func makeCancellationGroup() -> some View {
        SectionView(background: Color.backgroundWarning) {
            VStack(spacing: 8) {
                Text("screen.order_status.cancellation.description".localized)
                    .font(Font.appFont(size: 16, weight: .regular))
                    .foregroundStyle(Color.foregroundDark)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button("screen.order_status.cancellation.action".localized, action: viewModel.cancelOrder)
                    .buttonStyle(BrandSmallButtonStyle())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

extension CartItemView.Item {

    fileprivate init(_ orderItem: Order.Item) {
        self.init(id: orderItem.id, name: orderItem.name, quantity: orderItem.quantity, unitPrice: orderItem.unitPrice)
    }
}

extension Order.DisplayStatus {

    fileprivate var localizedTitle: String {
        switch self {
        case .placed:
            return "screen.order_status.subtitle.placed".localized

        case .preparing:
            return "screen.order_status.subtitle.preparing".localized

        case .delivered(let status):
            switch status {
            case .delivered:
                return "screen.order_status.subtitle.delivered".localized

            case .cancelled:
                return "screen.order_status.subtitle.cancelled".localized

            case .refunded:
                return "screen.order_status.subtitle.refunded".localized
            }
        }
    }

    fileprivate var localizedStageName: String {
        switch self {
        case .placed:
            return "screen.order_status.stage.placed".localized

        case .preparing:
            return "screen.order_status.stage.preparing".localized

        case .delivered(let status):
            switch status {
            case .delivered:
                return "screen.order_status.stage.delivered".localized

            case .cancelled:
                return "screen.order_status.stage.cancelled".localized

            case .refunded:
                return "screen.order_status.stage.refunded".localized
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        OrderStatusView(viewModel: OrderStatusViewModelMock())
    }
}

private final class OrderStatusViewModelMock: OrderStatusViewModelInput {

    let order = Order(
        id: UUID().uuidString,
        seatNumber: "2A",
        items: [
            .init(id: 123, name: "Pepsi", quantity: 1, unitPrice: .init(amount: 3, currency: .eur)),
            .init(id: 345, name: "Coca-Cola", quantity: 2, unitPrice: .init(amount: 3, currency: .eur))
        ],
        subtotalPrice: .init(amount: 9, currency: .eur),
        totalSavings: .init(amount: 1, currency: .eur),
        totalPrice: .init(amount: 8, currency: .eur),
        status: .placed,
        createdAt: Date()
    )

    func onAppear() { }

    func cancelOrder() { }

    init() {  }
}
