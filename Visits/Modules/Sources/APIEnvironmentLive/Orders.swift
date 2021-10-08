import APIEnvironment
import Combine
import ComposableArchitecture
import LogEnvironment
import NonEmpty
import Utility
import Types

// MARK: - Cancel

func cancelOrder(_ token: Token.Value, _ deID: DeviceID, _ o: Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never> {
  logEffect("cancelOrder \(o.id)")
  
  return callAPI(
    request: changeOrderStatusRequest(auth: token, deviceID: deID, order: o, status: .cancelled),
    success: Terminal.self,
    failure: Token.Expired.self
  )
  .catch { (e: APIError<Token.Expired>) -> AnyPublisher<Terminal, APIError<Token.Expired>> in
    switch e {
    case let .unknown(p, _, _) where p == "Received unexpected status code 409":
      return Just(unit)
        .setFailureType(to: APIError<Token.Expired>.self)
        .eraseToAnyPublisher()
    default:
      return Fail(error: e)
        .eraseToAnyPublisher()
    }
  }
    .catchToEffect()
    .map { (o, $0) }
}

// MARK: - Complete

func completeOrder(_ token: Token.Value, _ deID: DeviceID, _ o: Order) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never> {
  logEffect("completeOrder \(o.id)")
  
  return callAPI(
    request: changeOrderStatusRequest(auth: token, deviceID: deID, order: o, status: .completed),
    success: Terminal.self,
    failure: Token.Expired.self
  )
  .catch { (e: APIError<Token.Expired>) -> AnyPublisher<Terminal, APIError<Token.Expired>> in
    switch e {
    case let .unknown(p, _, _) where p == "Received unexpected status code 409":
      return Just(unit)
        .setFailureType(to: APIError<Token.Expired>.self)
        .eraseToAnyPublisher()
    default:
      return Fail(error: e)
        .eraseToAnyPublisher()
    }
  }
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

// MARK: - Update Note

func updateOrderNote(_ token: Token.Value, _ deID: DeviceID, _ o: Order, _ note: Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never> {
  logEffect("update order \(o.id) note: \(String(describing: o.note))")
  
  return callAPI(
    request: updateOrderNoteRequest(auth: token, deviceID: deID, order: o, note: note),
    success: Trip.self,
    failure: Token.Expired.self
  )
    .catchToEffect()
    .map { (o, $0.map(constant(unit))) }
}

func updateOrderNoteRequest(auth token: Token.Value, deviceID: DeviceID, order: Order, note: Order.Note) -> URLRequest {
  let url = URL(string: "\(clientURL)/trips/\(order.tripID)/orders/\(order.id)")!
  var request = URLRequest(url: url)
  request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  request.httpBody = try! JSONSerialization.data(
    withJSONObject: [
      "metadata": [
        "visits_app": [
          "note": note.string
        ]
      ]
    ],
    options: JSONSerialization.WritingOptions(rawValue: 0)
  )
  request.httpMethod = "PATCH"
  return request
}
