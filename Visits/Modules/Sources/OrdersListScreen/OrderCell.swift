import SwiftUI
import Types
import Views

struct OrderCell: View {
  
  private enum OrderIconStatus: String {
    case ongoing = "square"
    case visited = "dot.square"
    case completed = "checkmark.square"
    case canceled = "xmark.square"
    case snoozed = "minus.square"
    
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
      Image(systemName: orderIconStatus().rawValue)
          .font(.title)
          .foregroundColor(.accentColor)
          .padding(.trailing, 10)
      VStack {
        PrimaryRow(primary)
        Spacer()
        if let secondary = secondary {
          SecondaryRow(secondary)
            .padding(.bottom, -3)
        }
      }
    }
    .padding(.vertical, 10)
  }
    
  private var primary: String {
    return order.name?.rawValue
      ?? order.address.anyAddressStreetBias?.rawValue
      ?? OrderCell.dateFormatter.string(from: order.createdAt)
  }
  
  private var secondary: String? {
    return order.name != nil ? order.address.anyAddressStreetBias?.rawValue : nil
  }
  
  private func orderIconStatus() -> OrderIconStatus {
    switch order.status {
    case .ongoing, .cancelling, .completing:
      return order.visited != nil ? .visited : .ongoing
    case .completed:
      return .completed
    case .cancelled:
      return .canceled
    case .disabled:
      return .snoozed
    }
  }
}
