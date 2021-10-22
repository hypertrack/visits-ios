import APIEnvironment
import Combine
import ComposableArchitecture
import LogEnvironment
import NonEmpty
import Utility
import Types

// MARK: - Cancel

func cancelOrder(_ token: Token.Value, _ deID: DeviceID, _ o: Order, _ tripID: Trip.ID) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never> {
  changeOrderStatus(token, deID, o, tripID, status: .cancelled)
}

// MARK: - Complete

func completeOrder(_ token: Token.Value, _ deID: DeviceID, _ o: Order, _ tripID: Trip.ID) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never> {
  changeOrderStatus(token, deID, o, tripID, status: .completed)
}

// MARK: - Snooze

func snoozeOrder(_ token: Token.Value, _ deID: DeviceID, _ o: Order, _ tripID: Trip.ID) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never> {
  changeOrderStatus(token, deID, o, tripID, status: .snooze)
}

// MARK: - Unsnooze

func unsnoozeOrder(_ token: Token.Value, _ deID: DeviceID, _ o: Order, _ tripID: Trip.ID) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never> {
  changeOrderStatus(token, deID, o, tripID, status: .unsnooze)
}

// MARK: - Change Order Status

private enum APIOrderStatus: String {
  case completed = "complete"
  case cancelled = "cancel"
  case snooze = "disable"
  case unsnooze = "enable"
}

private func changeOrderStatus(_ token: Token.Value, _ deID: DeviceID, _ o: Order, _ tripID: Trip.ID, status: APIOrderStatus) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never> {
  logEffect("\(status.rawValue)Order \(o.id)")

  return callAPI(
    request: changeOrderStatusRequest(auth: token, deviceID: deID, order: o, tripID: tripID, status: status),
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

private func changeOrderStatusRequest(auth token: Token.Value, deviceID: DeviceID, order: Order, tripID: Trip.ID, status: APIOrderStatus) -> URLRequest {
  let url = URL(string: "\(clientURL)/trips/\(tripID)/orders/\(order.id)/\(status.rawValue)")!
  var request = URLRequest(url: url)
  request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  request.httpMethod = "POST"
  return request
}

// MARK: - Update Note

func updateOrderNote(_ token: Token.Value, _ deID: DeviceID, _ o: Order, _ tripID: Trip.ID, _ note: Order.Note) -> Effect<(Order, Result<Terminal, APIError<Token.Expired>>), Never> {
  logEffect("update order \(o.id) note: \(String(describing: o.note))")
  
  return callAPI(
    request: updateOrderNoteRequest(auth: token, deviceID: deID, order: o, tripID: tripID, note: note),
    success: Trip.self,
    failure: Token.Expired.self
  )
    .catchToEffect()
    .map { (o, $0.map(constant(unit))) }
}

private func updateOrderNoteRequest(auth token: Token.Value, deviceID: DeviceID, order: Order, tripID: Trip.ID, note: Order.Note) -> URLRequest {
  let url = URL(string: "\(clientURL)/trips/\(tripID)/orders/\(order.id)")!
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
