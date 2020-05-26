import Combine

import ComposableArchitecture
import HyperTrack
import Prelude

import Tracking


var dependency: HyperTrack?
var cancellable: AnyCancellable?

extension TrackingEnvironment {
  public static  let live = TrackingEnvironment(
    checkInWithPublishableKey: { publishableKey in
      Effect.fireAndForget {
        let pk = HyperTrack.PublishableKey(publishableKey.rawValue)!
        let hyperTrack: HyperTrack
        if let ht = dependency {
          hyperTrack = ht
        } else {
          hyperTrack = try! HyperTrack(publishableKey: pk)
          dependency = hyperTrack
        }
        let deviceID = NonEmptyString(rawValue: hyperTrack.deviceID)!
        cancellable = getAccessTokenFuture(
          publishableKey: publishableKey,
          deviceID: deviceID
        )
        .flatMap{ accessToken in checkInFuture(accessToken: accessToken, deviceID: deviceID) }
        .catchToEffect()
        .map(const(()))
        .sink(receiveValue: { dependency?.syncDeviceSettings() })
      }
    },
    setDriverID: { driverID in
      .fireAndForget {
        dependency?.setDeviceMetadata(HyperTrack.Metadata(dictionary: ["driver_id": driverID.rawValue])!)
      }
    },
    subscribeToTrackingStarted: {
      NotificationCenter
      .default
      .publisher(for: HyperTrack.startedTrackingNotification)
      .map { _ in () }
      .eraseToEffect()
    },
    subscribeToTrackingStopped: {
      NotificationCenter
      .default
      .publisher(for: HyperTrack.stoppedTrackingNotification)
      .map { _ in () }
      .eraseToEffect()
    },
    subscribeToTrialEnded: {
      NotificationCenter
      .default
      .publisher(for: HyperTrack.didEncounterRestorableErrorNotification)
      .compactMap { $0.hyperTrackRestorableError() }
      .drop(while: { $0 != .trialEnded })
      .map(const(()))
      .eraseToEffect()
    },
    sync: {
      .fireAndForget {
        dependency?.syncDeviceSettings()
      }
    }
  )
}

func authenticationRequest(
  publishableKey: NonEmptyString,
  deviceID: NonEmptyString
) -> URLRequest {
  let url = URL(string: "https://live-api.htprod.hypertrack.com/authenticate/")!
  var request = URLRequest(url: url)
  request.setValue(
    "Basic \(Data(publishableKey.rawValue.utf8).base64EncodedString(options: []))",
    forHTTPHeaderField: "Authorization"
  )
  request.httpMethod = "POST"
  request.httpBody = try! JSONSerialization.data(
    withJSONObject: ["device_id": deviceID.rawValue],
    options: JSONSerialization.WritingOptions(rawValue: 0)
  )
  return request
}

enum CheckInError: Error {
  case tokenIsEmpty
  case decodingFailed
  case unknown
  case checkInFailed
}

func getAccessTokenFuture(
  publishableKey: NonEmptyString,
  deviceID: NonEmptyString
) -> AnyPublisher<NonEmptyString, CheckInError> {
  URLSession.shared.dataTaskPublisher(for: authenticationRequest(
      publishableKey: publishableKey,
      deviceID: deviceID
    )
  )
  .map { data, _ in data }
  .print()
  .decode(type: AccessTokenResult.self, decoder: JSONDecoder())
  .print()
  .mapError(const(CheckInError.decodingFailed))
  .tryMap { accessToken in
    print("MM: \(accessToken)")
    if let accessToken = NonEmptyString(rawValue: accessToken.access_token) {
      return accessToken
    } else {
      throw CheckInError.tokenIsEmpty
    }
  }
  .mapError(const(CheckInError.unknown))
  .eraseToAnyPublisher()
}

struct AccessTokenResult: Decodable {
  let access_token: String
}

func checkInRequest(
  accessToken: NonEmptyString,
  deviceID: NonEmptyString
) -> URLRequest {
  let url = URL(string: "https://live-app-backend.htprod.hypertrack.com/client/devices/\(deviceID.rawValue)/start")!
  var request = URLRequest(url: url)
  request.setValue(
    "Bearer \(accessToken.rawValue)",
    forHTTPHeaderField: "Authorization"
  )
  request.httpMethod = "POST"
  return request
}

func checkInFuture(
  accessToken: NonEmptyString,
  deviceID: NonEmptyString
) -> AnyPublisher<Void, CheckInError> {
  URLSession.shared.dataTaskPublisher(for: checkInRequest(
      accessToken: accessToken,
      deviceID: deviceID
    )
  )
  .print()
  .map{ _ in }
  .mapError(const(CheckInError.checkInFailed))
  .eraseToAnyPublisher()
}
