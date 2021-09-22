import SwiftUI
import Types
import Views

struct OrderCell: View {
  
  enum OrderStatus: String {
    case pending = "⏳ Pending"
    case visited = "📦 Visited"
    case completed = "🏁 Completed"
    case canceled = "❌ Canceled"
    case snoozed = "⏸ Snoozed"
  }
  
  let order: Order
  
  private static var dateFormatter: DateFormatter = {
    var format = DateFormatter()
    format.dateStyle = .medium
    format.timeStyle = .short
    return format
  }()
  
  init(order: Order) {
    self.order = order
  }
  
  var body: some View {
    HStack {
      Spacer()
      //            TODO: Images to reflect order status? [OA]
      //            Image(systemName: "mappin.circle")
      //                .font(.title)
      //                .foregroundColor(.accentColor)
      //                .padding(.trailing, 10)
      VStack {
        PrimaryRow(address)
        Spacer()
        SecondaryRow(date)
          .padding(.bottom, -3)
      }
      Text(orderCellStatus().rawValue.capitalized)
        .font(.caption)
        .foregroundColor(Color(.secondaryLabel))

    }
    .padding(.vertical, 10)
  }
  
  private var date: String {
    return OrderCell.dateFormatter.string(from: order.createdAt)
  }
  
  private var address: String {
    return order.address.anyAddressStreetBias?.rawValue ?? "No address availible"
  }
  
  func orderCellStatus() -> OrderStatus {
    switch order.status {
    case .ongoing, .cancelling, .completing:
      return order.visited != nil ? .visited : .pending
    case .completed:
      return .completed
    case .cancelled:
      return .canceled
    case .disabled:
      return .snoozed
    }
  }
}
