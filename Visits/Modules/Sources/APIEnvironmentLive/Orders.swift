import APIEnvironment
import Combine
import ComposableArchitecture
import LogEnvironment
import NonEmpty
import Utility
import Types

// MARK: - Get

func getOrders(_ pk: PublishableKey, _ deID: DeviceID) -> Effect<Result<Set<Order>, APIError<Never>>, Never> {
  logEffect("getHistory", failureType: APIError<Never>.self)
    .flatMap { getToken(auth: pk, deviceID: deID)}
    .flatMap { token in
      getTrips(auth: token, deviceID: deID)
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
    }
    .catchToEffect()
}

// MARK: - Cancel

func cancelOrder(_ pk: PublishableKey, _ deID: DeviceID, _ o: Order) -> Effect<Result<Terminal, APIError<Never>>, Never> {
  logEffect("cancelOrder", failureType: APIError<Never>.self)
    .flatMap {
      callAPIWithAuth(publishableKey: pk, deviceID: deID, success: Terminal.self) { token in
        changeOrderStatusRequest(auth: token, deviceID: deID, order: o, status: .cancelled)
      }
    }
    .catchToEffect()
}

// MARK: - Complete

func completeOrder(_ pk: PublishableKey, _ deID: DeviceID, _ o: Order) -> Effect<Result<Terminal, APIError<Never>>, Never> {
  logEffect("completeOrder", failureType: APIError<Never>.self)
    .flatMap {
      callAPIWithAuth(publishableKey: pk, deviceID: deID, success: Terminal.self) { token in
        changeOrderStatusRequest(auth: token, deviceID: deID, order: o, status: .completed)
      }
    }
    .catchToEffect()
}

enum APIOrderStatus: String {
  case completed = "complete"
  case cancelled = "cancel"
}

func changeOrderStatusRequest(auth token: Token, deviceID: DeviceID, order: Order, status: APIOrderStatus) -> URLRequest {
  let url = URL(string: "\(clientURL)/trips/\(order.tripID)/orders/\(order.id)/\(status.rawValue)")!
  var request = URLRequest(url: url)
  request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  request.httpMethod = "POST"
  return request
}
