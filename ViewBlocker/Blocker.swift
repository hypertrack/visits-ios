import ComposableArchitecture
import ViewsComponents
import Prelude
import SwiftUI

public enum BlockReason: Equatable {
  case locationPermissionsDenied
  case locationPermissionsNotDetermined
  case locationPermissionsRestricted
  case locationServiceDisabled
  case motionPermissionsDenied
  case motionPermissionsNeedRestart
  case motionPermissionsNotDetermined
  case motionPermissionsUnknown
  case motionServiceDisabled
  case hyperTrackAccountTrialEnded
}

public enum BlockAction: Equatable {
  case openAppSettings
  case requestLocationPermissions
  case requestMotionPermissions
}

public struct Blocker: View {
  public struct State: Equatable {
    let title: NonEmptyString
    let message: NonEmptyString
    let showsButton: Bool
    let buttonTitle: String
    let buttonAction: BlockAction
  }
  
  let store: Store<BlockReason, BlockAction>
  @ObservedObject private var viewStore: ViewStore<Blocker.State, BlockAction>

  public init(store: Store<BlockReason, BlockAction>) {
    self.store = store
    self.viewStore = ViewStore(self.store.scope(state: State.init(reason:)))
  }

  public var body: some View {
    Block(
      title: viewStore.title,
      message: viewStore.message,
      showsButton: viewStore.showsButton,
      buttonTitle: viewStore.buttonTitle
    ) { self.viewStore.send(self.viewStore.buttonAction) }
  }
}

extension Blocker.State {
  init(reason: BlockReason) {
    switch reason {
    case .locationPermissionsDenied:
      self.title = "Allow Location Access"
      self.message =
        """
        We need your permission to access your location. Logistics app shares your current location with a fleet manager.
        
        Please navigate to Settings > Logistics > Location and set to Always.
        """
      self.buttonTitle = "Open Settings"
      self.showsButton = true
      self.buttonAction = .openAppSettings
    case .locationPermissionsNotDetermined:
      self.title = "Allow Location Access"
      self.message = "We need your permission to access your location. Logistics app shares your current location with a fleet manager."
      self.buttonTitle = "Allow Access"
      self.showsButton = true
      self.buttonAction = .requestLocationPermissions
    case .locationPermissionsRestricted:
      self.title = "Remove Location Restrictions"
      self.message =
        """
        We need Location Services to track your current location. Logistics app shares your current location with a fleet manager.
        
        Please remove restrictions in Settings > Screen Time > Content & Privacy Restriction > Location Services or contact your administrator.
        """
      self.buttonTitle = "Open Settings"
      self.showsButton = true
      self.buttonAction = .openAppSettings
    case .locationServiceDisabled:
      self.title = "Enable Location"
      self.message =
        """
        We need Location Services to track your current location. Logistics app shares your current location with a fleet manager.
        
        Please enable Location Services in Settings > Privacy > Location Services.
        """
      self.buttonTitle = "Open Settings"
      self.showsButton = true
      self.buttonAction = .openAppSettings
    case .motionPermissionsDenied:
      self.title = "Allow Motion Access"
      self.message =
        """
        We need your permission to access your motion.
        
        We use Motion & Fitness to efficiently use your battery when sending data.
        
        Please enable Motion & Fitness in Settings > Logistics > Motion & Fitness.
        """
      self.buttonTitle = "Open Settings"
      self.showsButton = true
      self.buttonAction = .openAppSettings
    case .motionPermissionsNeedRestart:
      self.title = "Allow Motion Access"
      self.message =
        """
        We need your permission to access your motion.
        
        We use Motion & Fitness to efficiently use your battery when sending data.
        
        Please make sure that Logistics has permissions in Settings > Logistics > Motion & Fitness and Fitness Tracking is enabled in Settings > Privacy > Motion & Fitness > Fitness Tracking and then restart the app.
        """
      self.buttonTitle = "Open Settings"
      self.showsButton = true
      self.buttonAction = .openAppSettings
    case .motionPermissionsNotDetermined:
      self.title = "Allow Motion Access"
      self.message =
        """
        We need your permission to access your motion.
        
        We use Motion & Fitness to efficiently use your battery when sending data.
        """
      self.buttonTitle = "Allow Access"
      self.showsButton = true
      self.buttonAction = .requestMotionPermissions
    case .motionPermissionsUnknown:
      self.title = "Allow Motion Access"
      self.message =
        """
        We need your permission to access your motion.
        
        We use Motion & Fitness to efficiently use your battery when sending data.
        
        Please make sure that Logistics has permissions in Settings > Logistics > Motion & Fitness and Fitness Tracking is enabled in Settings > Privacy > Motion & Fitness > Fitness Tracking.
        """
      self.buttonTitle = "Open Settings"
      self.showsButton = true
      self.buttonAction = .openAppSettings
    case .motionServiceDisabled:
      self.title = "Enable Motion & Fitness"
      self.message =
        """
        We use Motion & Fitness to efficiently use your battery when sending data.
        
        Please enable Fitness Tracking in Settings > Privacy > Motion & Fitness > Fitness Tracking.
        """
      self.buttonTitle = "Open Settings"
      self.showsButton = true
      self.buttonAction = .openAppSettings
    case .hyperTrackAccountTrialEnded:
      self.title = "Events limit reached"
      self.message =
        """
        You have exhausted your HyperTrack events quota for this month, please contact your manager for more information.
        """
      self.buttonTitle = ""
      self.showsButton = false
      self.buttonAction = .openAppSettings
    }
  }
}

#if DEBUG
  struct Blocker_Previews: PreviewProvider {
    static var previews: some View {
      Group {
        Blocker(
          store: Store<BlockReason, BlockAction>(
            initialState: .locationPermissionsDenied,
            reducer: .empty,
            environment: ()
          )
        )
        Blocker(
          store: Store<BlockReason, BlockAction>(
            initialState: .locationPermissionsNotDetermined,
            reducer: .empty,
            environment: ()
          )
        )
        Blocker(
          store: Store<BlockReason, BlockAction>(
            initialState: .locationPermissionsRestricted,
            reducer: .empty,
            environment: ()
          )
        )
        Blocker(
          store: Store<BlockReason, BlockAction>(
            initialState: .locationServiceDisabled,
            reducer: .empty,
            environment: ()
          )
        )
      }
    }
  }
#endif
