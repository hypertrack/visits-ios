public enum Request: Equatable, Hashable {
  case cancelOrder(Order)
  case completeOrder(Order)
  case history
  case orders
  case places
}
