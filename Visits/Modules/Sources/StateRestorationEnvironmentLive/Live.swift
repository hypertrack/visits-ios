import ComposableArchitecture
import LogEnvironment
import NonEmpty
import Utility
import StateRestorationEnvironment
import Types



public extension StateRestorationEnvironment {
  static let live = StateRestorationEnvironment(
    loadState: {
      Effect<Result<StorageState?, StateRestorationError>, Never>.result {
        logEffect("loadState")
        
        let ud = UserDefaults.standard

        return .success(
          restoredStateFrom(
            screen: ud.string(forKey: RestorationKey.screen.rawValue)
              >>- NonEmptyString.init(rawValue:)
              >-> StoredScreen.prism.extract(from:),
            email: ud.string(forKey: RestorationKey.email.rawValue)
              >>- NonEmptyString.init(rawValue:)
              <¡> Email.init(rawValue:),
            publishableKey: ud.string(forKey: RestorationKey.publishableKey.rawValue)
              >>- NonEmptyString.init(rawValue:)
              <¡> PublishableKey.init(rawValue:),
            name: ud.string(forKey: RestorationKey.name.rawValue)
              >>- NonEmptyString.init(rawValue:)
              <¡> Name.init(rawValue:),
            tabSelection: ud.string(forKey: RestorationKey.tabSelection.rawValue)
              >>- NonEmptyString.init(rawValue:)
              >-> TabSelection.prism.extract(from:),
            pushStatus: ud.string(forKey: RestorationKey.pushStatus.rawValue)
              >>- NonEmptyString.init(rawValue:)
              >-> PushStatus.prism.extract(from:),
            experience: ud.string(forKey: RestorationKey.experience.rawValue)
              >>- NonEmptyString.init(rawValue:)
              >-> Experience.prism.extract(from:),
            locationAlways: ud.string(forKey: RestorationKey.locationAlways.rawValue)
              >>- NonEmptyString.init(rawValue:)
              >-> LocationAlwaysPermissions.prism.extract(from:),
            workerHandle: ud.string(forKey: RestorationKey.workerHandle.rawValue)
              >>- NonEmptyString.init(rawValue:)
              <¡> WorkerHandle.init(rawValue:)
          )
        )
      }
    },
    saveState: { s in
      .fireAndForget {
        logEffect("saveState: \(String(describing: s))")
        
        let ud = UserDefaults.standard
        
        let screen: String
        var email: String? = nil
        var places: Data? = nil
        var tabSelection: String? = nil
        var publishableKey: String? = nil
        var name: String? = nil
        var workerHandle: String? = nil
        switch s.flow {
        case .firstRun:
          screen = StoredScreen.prism.embed(.firstRun).rawValue
        case let .signIn(e):
          screen = StoredScreen.prism.embed(.signIn).rawValue
          email = e?.string
        case let .main(s, pk, n, wh):
          screen = StoredScreen.prism.embed(.main).rawValue
          tabSelection = TabSelection.prism.embed(s).rawValue
          name = n <¡> \.string
          publishableKey = pk <¡> \.string
          workerHandle = wh <¡> \.string
        }
        
        ud.set(screen, forKey: RestorationKey.screen.rawValue)
        ud.set(email, forKey: RestorationKey.email.rawValue)
        ud.set(tabSelection, forKey: RestorationKey.tabSelection.rawValue)
        ud.set(publishableKey, forKey: RestorationKey.publishableKey.rawValue)
        ud.set(name, forKey: RestorationKey.name.rawValue)
        ud.set(workerHandle, forKey: RestorationKey.workerHandle.rawValue)
        
        ud.set(PushStatus.prism.embed(s.pushStatus).rawValue, forKey: RestorationKey.pushStatus.rawValue)
        ud.set(Experience.prism.embed(s.experience).rawValue, forKey: RestorationKey.experience.rawValue)
        ud.set(LocationAlwaysPermissions.prism.embed(s.locationAlways).rawValue, forKey: RestorationKey.locationAlways.rawValue)
      }
    }
  )
}

func restoredStateFrom(
  screen: StoredScreen?,
  email: Email?,
  publishableKey: PublishableKey?,
  name: Name?,
  tabSelection: TabSelection?,
  pushStatus: PushStatus?,
  experience: Experience?,
  locationAlways: LocationAlwaysPermissions?,
  workerHandle: WorkerHandle?
) -> Result<StorageState?, StateRestorationError> {
  switch (screen, email, publishableKey, name, tabSelection, pushStatus, experience, locationAlways, workerHandle) {
  
  // Latest, onboarded app on the main screen
  case let (.main, _, .some(publishableKey), .some(name), tabSelection, pushStatus, experience, locationAlways, workerHandle):
    return .success(
      StorageState(
        experience: experience ?? .regular,
        flow: .main(tabSelection ?? .defaultTab, publishableKey, name, workerHandle),
        locationAlways: locationAlways ?? .notRequested,
        pushStatus: pushStatus ?? .dialogSplash(.notShown)
      )
    )
    
  // Latest app on Sign In screen
  case let (.signIn, email, _, _, _, pushStatus, experience, locationAlways, _):
    return .success(
      .init(
        experience: experience ?? .firstRun,
        flow: .signIn(email),
        locationAlways: locationAlways ?? .notRequested,
        pushStatus: pushStatus ?? .dialogSplash(.notShown)
      )
    )
  
  // Latest app killed on first run splash screen
  case let (.firstRun, _, _, _, _, pushStatus, experience, locationAlways, _):
    return .success(
      .init(
        experience: experience ?? .firstRun,
        flow: .firstRun,
        locationAlways: locationAlways ?? .notRequested,
        pushStatus: pushStatus ?? .dialogSplash(.notShown)
      )
    )
    
  // Freshly installed app that didn't go though the deep link
  case (.none, .none, .none, .none, .none, .none, .none, .none, .none):
    return .success(nil)
    
  // State restoration failed, back to the starting screen
  default:
    return .failure(
      .init(
        name: name,
        email: email,
        experience: experience,
        locationAlways: locationAlways,
        publishableKey: publishableKey,
        pushStatus: pushStatus,
        screen: screen,
        tabSelection: tabSelection
      )
    )
  }
}

enum RestorationKey: String, CaseIterable {
  case name = "1GO62fagRR"
  case email = "XZ5TRYpn6b"
  case experience = "79koMswApt"
  case locationAlways = "BgEaxxcUEt"
  case publishableKey = "83Hw5bQ7IC"
  case pushStatus = "UucSji3z7h"
  case screen = "mDz3JJ2ekk"
  case tabSelection = "O0hNX6o1zP"
  case workerHandle = "b095c29aet"
}

extension TabSelection {
  private static let mapKey: NonEmptyString = "map"
  private static let ordersKey: NonEmptyString = "orders"
  private static let placesKey: NonEmptyString = "places"
  private static let visitsKey: NonEmptyString = "visits"
  private static let profileKey: NonEmptyString = "profile"
  private static let teamKey: NonEmptyString = "team"

  static let prism: Prism<NonEmptyString, Self> = .init(
    extract: { key in
      switch key {
      case mapKey:     return .map
      case ordersKey:  return .orders
      case placesKey:  return .places
      case profileKey: return .profile
      case visitsKey:  return .visits
      default:         return nil
      }
    },
    embed: { tabSelection in
      switch tabSelection {
      case .map:     return mapKey
      case .orders:  return ordersKey
      case .places:  return placesKey
      case .profile: return profileKey
      case .visits:  return visitsKey
      case .team: return teamKey
      }
    }
  )
}

extension PushStatus {
  private static let dialogSplashShownKey: NonEmptyString = "dialogSplashShown"
  private static let dialogSplashNotShownKey: NonEmptyString  = "dialogSplashNotShown"
  private static let dialogSplashWaitingForUserActionKey: NonEmptyString  = "dialogSplashWaitingForUserAction"
  
  static let prism: Prism<NonEmptyString, Self> = .init(
    extract: { key in
      switch key {
      case dialogSplashShownKey:                return .dialogSplash(.shown)
      case dialogSplashNotShownKey:             return .dialogSplash(.notShown)
      case dialogSplashWaitingForUserActionKey: return .dialogSplash(.waitingForUserAction)
      default:                                  return nil
      }
    },
    embed: { pushStatus in
      switch pushStatus {
      case .dialogSplash(.shown):                return dialogSplashShownKey
      case .dialogSplash(.notShown):             return dialogSplashNotShownKey
      case .dialogSplash(.waitingForUserAction): return dialogSplashWaitingForUserActionKey
      }
    }
  )
}

extension Experience {
  private static let firstRunKey: NonEmptyString = "EMcvpiyTCY"
  private static let regularKey: NonEmptyString  = "wDvZjD44fJ"

  static let prism: Prism<NonEmptyString, Self> = .init(
    extract: { key in
      switch key {
      case firstRunKey: return .firstRun
      case regularKey:  return .regular
      default:          return nil
      }
    },
    embed: { experience in
      switch experience {
      case .firstRun: return firstRunKey
      case .regular:  return regularKey
      }
    }
  )
}

extension StoredScreen {
  private static let signInKey: NonEmptyString = "signIn"
  private static let mainKey: NonEmptyString = "visits"
  private static let firstRunKey: NonEmptyString = "firstRun"
  
  static let prism: Prism<NonEmptyString, Self> = .init(
    extract: { key in
      switch key {
      case firstRunKey:    return .firstRun
      case signInKey:   return .signIn
      case mainKey:     return .main
      default:          return nil
      }
    },
    embed: { storedScreen in
      switch storedScreen {
      case .firstRun:   return firstRunKey
      case .signIn:     return signInKey
      case .main:       return mainKey
      }
    }
  )
}

extension LocationAlwaysPermissions {
  private static let requestedAfterWhenInUseKey: NonEmptyString = "3hcIg16dQu"
  private static let notRequestedKey: NonEmptyString  = "kWhjxi21lx"

  static let prism: Prism<NonEmptyString, LocationAlwaysPermissions> = .init(
    extract: { key in
      switch key {
      case requestedAfterWhenInUseKey: return .requestedAfterWhenInUse
      case notRequestedKey:            return .notRequested
      default:                         return nil
      }
    },
    embed: { locationAlways in
      switch locationAlways {
      case .requestedAfterWhenInUse:   return requestedAfterWhenInUseKey
      case .notRequested:              return notRequestedKey
      }
    }
  )
}
