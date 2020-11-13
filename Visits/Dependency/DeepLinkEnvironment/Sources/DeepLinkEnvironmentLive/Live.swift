import Branch
import Combine
import ComposableArchitecture
import DeepLinkEnvironment
import DriverID
import ManualVisitsStatus
import NonEmpty
import PublishableKey


public extension DeepLinkEnvironment {
  static let live = DeepLinkEnvironment(
    subscribeToDeepLinks: {
      Effect.run { subscriber in
        print("🚀 subscribeToDeepLinks")
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
        print("🚀 continueUserActivity")
        Branch
          .getInstance()
          .continue(userActivity)
      }
    }
  )
}

func handleBranchCallback(
  _ f: @escaping ((PublishableKey, DriverID?, ManualVisitsStatus?)) -> Void
) -> ([AnyHashable : Any]?, Error?) -> Void {
  { params, error in
    print("Params:\n\(String(describing: params))\nError:\n\(String(describing: error))\n")
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
      
      let ManualVisitsStatus: ManualVisitsStatus?
      if let statusBool = params["show_manual_visits"] as? Bool {
        if statusBool {
          ManualVisitsStatus = .showManualVisits
        } else {
          ManualVisitsStatus = .hideManualVisits
        }
      } else {
        ManualVisitsStatus = nil
      }
      
      f((publishableKey, driverID, ManualVisitsStatus))
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
