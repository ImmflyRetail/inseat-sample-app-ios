import SwiftUI

struct OrdersView<ViewModel: OrdersViewModelInput>: View {

    @ObservedObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: .zero) {
                ScrollView {
                    VStack(spacing: 24) {
                        ForEach(viewModel.orders, id: \.id) { order in
                            OrderDetailsView(order: order, deleteAction: {
                                viewModel.delete(orderId: order.id)
                            })
                        }
                    }
                    .padding(.vertical, 16)
                }
                .background(Color.backgroundGray)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("My orders")
            .onAppear(perform: viewModel.onAppear)
        }
    }

    private struct OrderDetailsView: View {

        let order: Order
        let deleteAction: () -> Void

        var body: some View {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 8) {
                        Text(DateFormatter.inseatOrderDateFormatter.string(from: order.createdAt))
                            .foregroundStyle(Color.lightForeground)
                            .font(.system(size: 12, weight: .regular))

                        Spacer()

                        Text(order.status.title)
                            .foregroundStyle(order.status == .completed ? Color.successText : Color.darkForeground)
                            .font(.system(size: 10, weight: .semibold))
                            .padding(.vertical, 7)
                            .padding(.horizontal, 8)
                            .background(order.status == .completed ? Color.successBackground : Color.complementary)
                            .clipShape(RoundedRectangle(cornerRadius: 24))

                        if order.status == .placed || order.status == .received {
                            Button {
                                deleteAction()
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(Color.primaryRed)
                            }
                        }
                    }

                    Text("Details")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(height: 44)

                    KeyValueDetailView(key: "Order ID", value: order.id)
                    KeyValueDetailView(key: "Seat number", value: order.seatNumber)

                    Divider()

                    Text("Summary")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(height: 44)

                    VStack(spacing: 16) {
                        ForEach(order.items, id: \.id) { item in
                            ProductItemView(item: item)
                        }
                    }

                    Divider()

                    TotalPriceView(totalPrice: order.totalPrice)
                        .padding(.bottom, 8)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.backgroundLight)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 16)
        }
    }

    private struct KeyValueDetailView: View {

        let key: String
        let value: String

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(key)
                    .foregroundStyle(Color.lightForeground)
                    .font(.system(size: 14, weight: .regular))

                Text(value)
                    .foregroundStyle(Color.darkForeground)
                    .font(.system(size: 14, weight: .semibold))
            }
        }
    }

    private struct ProductItemView: View {

        let item: OrderItem

        var body: some View {
            HStack(spacing: 12) {
                Text("\(item.quantity)x")
                    .font(.system(size: 14, weight: .semibold))

                Text(item.name)
                    .font(.system(size: 14, weight: .regular))

                Spacer()

                Text("\(item.unitPrice.formatted())")
                    .font(.system(size: 14, weight: .semibold))
            }
        }
    }

    private struct TotalPriceView: View {

        let totalPrice: Price

        var body: some View {
            HStack {
                Text("Total")
                    .font(.system(size: 18, weight: .semibold))

                Spacer()

                Text("\(totalPrice.formatted())")
                    .font(.system(size: 18, weight: .semibold))
            }
        }
    }
}

extension Order.Status {

    fileprivate var title: String {
        switch self {
        case .placed:
            "Order placed"
        case .received:
            "Order received"
        case .preparing:
            "Order preparing"
        case .cancelledByCrew:
            "Rejected"
        case .cancelledByPassenger:
            "Cancelled"
        case .cancelledByTimeout:
            "Cancelled"
        case .completed:
            "Delivered"
        }
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
            seatNumber: "2A",
            items: [
                OrderItem(id: 123, name: "Pepsi", quantity: 1, unitPrice: .init(amount: 3, currencyCode: "EUR"))
            ],
            totalPrice: .init(amount: 3, currencyCode: "EUR"),
            status: .placed,
            createdAt: Date()
        )
    ]

    func onAppear() { }

    func delete(orderId: Order.ID) { }

    init() {  }
}
