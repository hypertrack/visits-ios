import APIEnvironment
import Combine
import ComposableArchitecture
import LogEnvironment
import NonEmpty
import Utility
import Types

// MARK: - Get

func getOrders(_ token: Token.Value, _ pk: PublishableKey, _ deID: DeviceID) -> Effect<Result<Set<Order>, APIError<Token.Expired>>, Never> {
  logEffect("getHistory")
  
  return getTrips(auth: token, deviceID: deID)
    .map { trips in
      trips
        .filter { $0.status == .active && !$0.orders.isEmpty }
        .sorted(by: \.createdAt)
        .first
        .map { trip in
          trip.orders.map { $0 |> \Order.tripID *< Order.TripID(rawValue: trip.id) } |> Set.init
        }
      ?? []
    }
    .catchToEffect()
}

// MARK: - Cancel

func cancelOrder(_ token: Token.Value, _ pk: PublishableKey, _ deID: DeviceID, _ o: Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never> {
  logEffect("cancelOrder \(o.id)")
  
  return callAPI(
    request: changeOrderStatusRequest(auth: token, deviceID: deID, order: o, status: .cancelled),
    success: Terminal.self,
    failure: Token.Expired.self
  )
    .catchToEffect()
    .map { (o, $0) }
}

// MARK: - Complete

func completeOrder(_ token: Token.Value, _ pk: PublishableKey, _ deID: DeviceID, _ o: Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never> {
  logEffect("completeOrder \(o.id)")
  
  return callAPI(
    request: changeOrderStatusRequest(auth: token, deviceID: deID, order: o, status: .completed),
    success: Terminal.self,
    failure: Token.Expired.self
  )
    .catchToEffect()
    .map { (o, $0) }
}

enum APIOrderStatus: String {
  case completed = "complete"
  case cancelled = "cancel"
}

func changeOrderStatusRequest(auth token: Token.Value, deviceID: DeviceID, order: Order, status: APIOrderStatus) -> URLRequest {
  let url = URL(string: "\(clientURL)/trips/\(order.tripID)/orders/\(order.id)/\(status.rawValue)")!
  var request = URLRequest(url: url)
  request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  request.httpMethod = "POST"
  return request
}
