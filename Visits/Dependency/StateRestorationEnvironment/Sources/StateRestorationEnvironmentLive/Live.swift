import ComposableArchitecture
import Credentials
import DriverID
import Log
import ManualVisitsStatus
import NonEmpty
import Prelude
import PublishableKey
import RestorationState
import StateRestorationEnvironment
import Visit



public extension StateRestorationEnvironment {
  static let live = StateRestorationEnvironment(
    loadState: {
      Effect<StorageState?, Never>.result {
        logEffect("loadState")
        return .success(
          restoredStateFrom(
            screen: UserDefaults.standard.string(forKey: RestorationKey.screen.rawValue)
              >>- Screen.init(rawValue:),
            email: UserDefaults.standard.string(forKey: RestorationKey.email.rawValue)
              >>- NonEmptyString.init(rawValue:)
              <¡> Email.init(rawValue:),
            publishableKey: UserDefaults.standard.string(forKey: RestorationKey.publishableKey.rawValue)
              >>- NonEmptyString.init(rawValue:)
              <¡> PublishableKey.init(rawValue:),
            driverID: UserDefaults.standard.string(forKey: RestorationKey.driverID.rawValue)
              >>- NonEmptyString.init(rawValue:)
              <¡> DriverID.init(rawValue:),
            mvs: UserDefaults.standard.string(forKey: RestorationKey.manualVisitsStatus.rawValue)
              >>- ManualVisitsStatus.init(rawValue:),
            visits: (UserDefaults.standard.object(forKey: RestorationKey.visits.rawValue) as? Data)
              >>- { try? JSONDecoder().decode(Visits.self, from: $0) }
          )
        )
      }
    },
    saveState: { s in
      .fireAndForget {
        logEffect("saveState: \(String(describing: s))")
        
        let ud = UserDefaults.standard
        
        switch s {
        case .none:
          for key in RestorationKey.allCases {
            ud.removeObject(forKey: key.rawValue)
          }
        case let .some(s):
          switch s {
          case let .signIn(e):
            ud.set(Screen.signIn.rawValue, forKey: RestorationKey.screen.rawValue)
            ud.set(e <¡> \.rawValue.rawValue, forKey: RestorationKey.email.rawValue)
          case let .driverID(dID, pk, mvs):
            ud.set(Screen.driverID.rawValue, forKey: RestorationKey.screen.rawValue)
            ud.set(dID <¡> \.rawValue.rawValue, forKey: RestorationKey.driverID.rawValue)
            ud.set(pk <¡> \.rawValue.rawValue, forKey: RestorationKey.publishableKey.rawValue)
            ud.set(mvs <¡> \.rawValue, forKey: RestorationKey.manualVisitsStatus.rawValue)
          case let .visits(v, pk, dID):
            ud.set(Screen.visits.rawValue, forKey: RestorationKey.screen.rawValue)
            ud.set(try? JSONEncoder().encode(v), forKey: RestorationKey.visits.rawValue)
            ud.set(pk <¡> \.rawValue.rawValue, forKey: RestorationKey.publishableKey.rawValue)
            ud.set(dID <¡> \.rawValue.rawValue, forKey: RestorationKey.driverID.rawValue)
          }
        }
      }
    }
  )
}

func restoredStateFrom(
  screen: Screen?,
  email: Email?,
  publishableKey: PublishableKey?,
  driverID: DriverID?,
  mvs: ManualVisitsStatus?,
  visits: Visits?
) -> StorageState? {
  switch (screen, email, publishableKey, driverID, mvs, visits) {
  // Old app that got to deliveries screen. Assuming no manual visits by default
  case let (.none, _, .some(publishableKey), .some(driverID), _, _):
    return .visits(.assigned([]), publishableKey, driverID)
  // Old app that only got to the DriverID screen
  case let (.none, _, .some(publishableKey), .none, _, _):
    return .driverID(nil, publishableKey, nil)
  // Freshly installed app that didn't go though the deep link search,
  // or an old app that didn't open the deep link
  case (.none, _, .none, .none, _, _):
    return nil
  // Sign in screen
  case let (.signIn, email, _, _, _, _):
    return .signIn(email)
  // Driver ID screen
  case let (.driverID, _, .some(publishableKey), driverID, mvs, _):
    return .driverID(driverID, publishableKey, mvs)
  // Visits screens
  case let (.visits, _, .some(publishableKey), .some(driverID), _, .some(visits)):
    return .visits(visits, publishableKey, driverID)
  // State restoration failed, back to the starting screen
  default: return nil
  }
}

enum RestorationKey: String, CaseIterable {
  case publishableKey = "UeiDZRFEOd"
  case driverID = "Hp6XdOsXsw"
  case visits = "nB24HHL2T5"
  case screen = "ZJNLfS0Nhw"
  case email = "sXwAlVbnPT"
  case manualVisitsStatus = "T7XH9g2sFQ"
}

enum Screen: String {
  case signIn
  case driverID
  case visits
}
