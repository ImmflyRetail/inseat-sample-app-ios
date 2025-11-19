import SwiftUI

struct OrdersView<ViewModel: OrdersViewModelInput>: View {

    @EnvironmentObject var router: ShopRouter

    @ObservedObject var viewModel: ViewModel

    @State var isExpanded: [Order.ID: Bool] = [:]

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationBar(
            title: "screen.orders.title".localized,
            leading: BackButton { router.navigateBack() }
        ) {
            makeListView()
        }
        .toolbar(.hidden)
        .onAppear(perform: viewModel.onAppear)
        .navigationDestination(for: ShopRouter.OrderDestination.self) { destination in
            switch destination {
            case .orderStatus(let order):
                return OrderStatusView(
                    viewModel: OrderStatusViewModel(
                        order: order
                    )
                )
            }
        }
    }

    private func makeListView() -> some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(viewModel.orders, id: \.id) { order in
                    OrderDetailsView(
                        order: order,
                        isExpanded: Binding(
                            get: {
                                isExpanded[order.id] ?? false
                            },
                            set: { newValue in
                                isExpanded[order.id] = newValue
                            }
                        ),
                        viewStatusAction: {
                            router.navigate(to: .orderStatus(order: order))
                        },
                        deleteAction: {
                            viewModel.delete(orderId: order.id)
                        }
                    )
                }
            }
            .padding(.vertical, 16)
        }
        .background(Color.backgroundGray)
    }

    private struct OrderDetailsView: View {

        let order: Order
        @Binding var isExpanded: Bool
        let viewStatusAction: () -> Void
        let deleteAction: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: .zero) {
                VStack(alignment: .leading, spacing: .zero) {
                    makeHeaderGroup()

                    if isExpanded {
                        makeDetailsGroup()
                            .padding(.top, 24)
                            .padding(.bottom, 24)

                        Divider()

                        makeSummaryGroup()
                            .padding(.top, 24)
                            .padding(.bottom, 24)

                        Divider()
                            .padding(.bottom, 24)

                        makeTotalsGroup()

                    } else {
                        makeCompactGroup()
                            .padding(.top, 16)
                            .padding(.bottom, 16)
                        Divider()
                    }
                }

                makeDropdownButton()
                    .padding(.vertical, 12)
            }
            .padding(.top, 12)
            .padding(.horizontal, 16)
            .background(Color.backgroundLight)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 16)
            .animation(.bouncy, value: "\(order.id)_\(isExpanded)")
        }

        private func makeHeaderGroup() -> some View {
            HStack(spacing: 8) {
                Text(DateFormatter.orderDateString(from: order.createdAt))
                    .font(Font.appFont(size: 12, weight: .regular))
                    .foregroundStyle(Color.foregroundLight)

                Spacer()

                StatusView(order: order)

                if order.status == .placed || order.status == .received {
                    Button {
                        deleteAction()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(Color.primaryRed)
                    }
                }
            }
        }

        private func makeCompactGroup() -> some View {
            HStack(spacing: 8) {
                Spacer()
                Text(makeAttributedText())
                Spacer()
            }
            .foregroundStyle(Color.foregroundDark)
            .id("order_\(order.id)_compact_info")
        }

        private func makeAttributedText() -> AttributedString {
            var text1 = AttributedString("screen.orders.summary.compact".localized(order.items.count) + " ")

            text1.font = Font.appFont(size: 16, weight: .regular)
            text1.foregroundColor = Color.foregroundDark

            var text2 = AttributedString(order.totalPrice.formatted())
            text2.font = Font.appFont(size: 16, weight: .semibold)
            text2.foregroundColor = Color.foregroundDark

            return text1 + text2
        }

        private func makeDetailsGroup() -> some View {
            FormGroupView(title: "screen.orders.summary.details".localized) {
                VerticalKeyValueView(key: "screen.orders.summary.details.order_id".localized, value: order.id)
                VerticalKeyValueView(key: "screen.orders.summary.details.seat_number".localized, value: order.seatNumber)
            }
        }

        private func makeSummaryGroup() -> some View {
            FormGroupView(title: "screen.orders.summary".localized) {
                VStack(spacing: 16) {
                    ForEach(order.items, id: \.id) { item in
                        CartItemView(item: CartItemView.Item(item))
                    }
                }
            }
        }

        private func makeTotalsGroup() -> some View {
            VStack(alignment: .leading, spacing: 16) {
                PriceKeyValueView(title: "screen.orders.summary.subtotal".localized, price: order.subtotalPrice)

                if let savings = order.totalSavings {
                    PriceKeyValueView(title: "screen.orders.summary.savings".localized, price: savings.negative)
                }
                PriceKeyValueView(title: "screen.orders.summary.total".localized, price: order.totalPrice, style: .large)
            }
        }

        private func makeDropdownButton() -> some View {
            switch order.status {
            case .placed, .received, .preparing:
                DropdownButton(
                    style: .detail(title: "screen.orders.actions.status".localized),
                    isExpanded: .constant(false),
                    action: {
                        viewStatusAction()
                    }
                )

            case .cancelledByCrew, .cancelledByPassenger, .cancelledByTimeout, .completed, .refunded:
                DropdownButton(
                    style: .dropdown(
                        expandedTitle: "screen.orders.actions.collapse".localized,
                        collapsedTitle: "screen.orders.actions.expand".localized
                    ),
                    isExpanded: $isExpanded,
                    action: {
                        withAnimation(.bouncy) {
                            isExpanded.toggle()
                        }
                    }
                )
            }
        }
    }

    private struct StatusView: View {

        let order: Order

        var body: some View {
            Text(order.status.title)
                .foregroundStyle(order.status.foregroundColor)
                .font(Font.appFont(size: 10, weight: .semibold))
                .padding(.vertical, 7)
                .padding(.horizontal, 8)
                .background(order.status.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
}

extension Order.Status {

    fileprivate var title: String {
        switch self {
        case .placed:
            "screen.orders.order_status.placed".localized
        case .received:
            "screen.orders.order_status.received".localized
        case .preparing:
            "screen.orders.order_status.preparing".localized
        case .cancelledByCrew:
            "screen.orders.order_status.cancelled_by_crew".localized
        case .cancelledByPassenger, .cancelledByTimeout:
            "screen.orders.order_status.cancelled_by_passenger".localized
        case .completed:
            "screen.orders.order_status.delivered".localized
        case .refunded:
            "screen.orders.order_status.refunded".localized
        }
    }

    fileprivate var foregroundColor: Color {
        switch self {
        case .placed, .received, .refunded:
            return Color.foregroundDark
        case .preparing:
            return Color.baseWarning
        case .cancelledByCrew, .cancelledByPassenger, .cancelledByTimeout:
            return Color.baseNegative
        case .completed:
            return Color.basePositive
        }
    }

    fileprivate var backgroundColor: Color {
        switch self {
        case .placed, .received, .refunded:
            return Color.complementary
        case .preparing:
            return Color.backgroundWarning
        case .cancelledByCrew, .cancelledByPassenger, .cancelledByTimeout:
            return Color.backgroundNegative
        case .completed:
            return Color.backgroundPositive
        }
    }
}

extension CartItemView.Item {

    fileprivate init(_ orderItem: Order.Item) {
        self.init(id: orderItem.id, name: orderItem.name, quantity: orderItem.quantity, unitPrice: orderItem.unitPrice)
    }
}

// MARK: - Preview

#Preview {
    OrdersView(viewModel: OrdersViewModelMock())
}

private final class OrdersViewModelMock: OrdersViewModelInput {

    let orders: [Order] = [
        Order(
            id: UUID().uuidString,
            seatNumber: "1A",
            items: [
                .init(id: 123, name: "Pepsi", quantity: 1, unitPrice: .init(amount: 3, currency: .eur)),
                .init(id: 234, name: "Coca-Cola", quantity: 2, unitPrice: .init(amount: 3, currency: .eur))
            ],
            subtotalPrice: .init(amount: 9, currency: .eur),
            totalSavings: .init(amount: 2, currency: .eur),
            totalPrice: .init(amount: 7, currency: .eur),
            status: .placed,
            createdAt: Date()
        ),
        Order(
            id: UUID().uuidString,
            seatNumber: "2A",
            items: [
                .init(id: 345, name: "Sprite", quantity: 1, unitPrice: .init(amount: 3, currency: .eur))
            ],
            subtotalPrice: .init(amount: 3, currency: .eur),
            totalSavings: nil,
            totalPrice: .init(amount: 3, currency: .eur),
            status: .preparing,
            createdAt: Date()
        ),
        Order(
            id: UUID().uuidString,
            seatNumber: "3A",
            items: [
                .init(id: 345, name: "Sprite", quantity: 1, unitPrice: .init(amount: 3, currency: .eur))
            ],
            subtotalPrice: .init(amount: 3, currency: .eur),
            totalSavings: nil,
            totalPrice: .init(amount: 3, currency: .eur),
            status: .completed,
            createdAt: Date()
        ),
        Order(
            id: UUID().uuidString,
            seatNumber: "4A",
            items: [
                .init(id: 345, name: "Sprite", quantity: 1, unitPrice: .init(amount: 3, currency: .eur))
            ],
            subtotalPrice: .init(amount: 3, currency: .eur),
            totalSavings: nil,
            totalPrice: .init(amount: 3, currency: .eur),
            status: .cancelledByPassenger,
            createdAt: Date()
        )
    ]

    func onAppear() { }

    func delete(orderId: Order.ID) { }

    init() {  }
}
