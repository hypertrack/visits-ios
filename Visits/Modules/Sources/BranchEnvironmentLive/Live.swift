import Branch
import BranchEnvironment
import Combine
import ComposableArchitecture
import LogEnvironment
import NonEmpty
import Types


public extension BranchEnvironment {
  static let live = BranchEnvironment(
    subscribeToDeepLinks: {
      Effect.run { subscriber in
        logEffect("subscribeToDeepLinks")
        Branch
          .getInstance()
          .initSession(
            launchOptions: nil,
            andRegisterDeepLinkHandler: handleBranchCallback(subscriber.send)
          )
        return AnyCancellable {}
      }
    },
    continueUserActivity: { userActivity in
      .fireAndForget {
        logEffect("continueUserActivity")
        Branch
          .getInstance()
          .continue(userActivity)
      }
    }
  )
}

func handleBranchCallback(
  _ f: @escaping ((PublishableKey, DriverID?)) -> Void
) -> ([AnyHashable : Any]?, Error?) -> Void {
  { params, error in
    logEffect("subscribeToDeepLinks.handleBranchCallback Params: \(String(describing: params)) Error: \(String(describing: error))")
    if error == nil,
       let params = params,
       let nonEmptyPublishableKey = NonEmptyString(dict: params, key: "publishable_key")  {
      let publishableKey = PublishableKey(rawValue: nonEmptyPublishableKey)
      
      let driverID: DriverID?
      if let nonEmptyDriverID =  NonEmptyString(dict: params, key: "driver_id") {
        driverID = DriverID(rawValue: nonEmptyDriverID)
      } else {
        driverID = nil
      }
      
      f((publishableKey, driverID))
    }
  }
}

extension NonEmptyString {
  init?(dict: [AnyHashable : Any], key: String) {
    if let valueString = dict[key] as? String {
      self.init(rawValue: valueString)
    } else {
      return nil
    }
  }
}
