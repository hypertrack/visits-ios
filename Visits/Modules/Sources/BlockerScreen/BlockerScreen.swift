import SwiftUI
import Views


public struct Blocker: View {
  public enum State: Equatable {
    case waiting
    case deleted(String)
    case invalidPublishableKey(String)
    case locationWhenInUse
    case locationWhenInUseFirstRequest
    case locationDenied
    case locationDisabled
    case locationNotDetermined
    case locationProvisional
    case locationRestricted
    case locationReduced
    case pushNotShown
  }
  
  public enum Action: Equatable {
    case deletedButtonTapped
    case invalidPublishableKeyButtonTapped
    case locationWhenInUseButtonTapped
    case locationWhenInUseFirstRequestButtonTapped
    case locationDeniedButtonTapped
    case locationDisabledButtonTapped
    case locationNotDeterminedButtonTapped
    case locationProvisionalButtonTapped
    case locationRestrictedButtonTapped
    case locationReducedButtonTapped
    case pushNotShownButtonTapped
  }
  
  let state: State
  let send: (Action) -> Void
  @Environment(\.colorScheme) var colorScheme
  
  public init(
    state: State,
    send: @escaping (Action) -> Void
  ) {
    self.state = state
    self.send = send
  }
  
  public var body: some View {
    VStack {
      Title(title: title(from: state))
      CustomText(text: message(from: state))
        .defaultTextColor()
        .padding(.top, 30)
        .padding([.trailing, .leading], 16)
      Spacer()
      if let (title, action) = button(from: state) {
        PrimaryButton(
          variant: .normal(title: title)
        ) {
          send(action)
        }
        .padding(.bottom, buttonSubtitle(from: state) == nil ? 40 : 5)
        .padding([.trailing, .leading], 58)
        if let subtitle = buttonSubtitle(from: state) {
          Text(subtitle)
            .fontWeight(.light)
            .foregroundColor(colorScheme == .light ? .sherpaBlue : .cosmicLatte)
            .padding(.bottom, 35)
        }
      }
    }
    .modifier(AppBackground())
    .edgesIgnoringSafeArea(.all)
  }
}

func title(from s: Blocker.State) -> String {
  switch s {
  case .deleted:                       return "Device Blocked"
  case .invalidPublishableKey:         return "Internal Error"
  case .locationDenied:                return "Allow Location Access"
  case .locationDisabled:              return "Enable Location"
  case .locationNotDetermined:         return "Allow Location Access"
  case .locationProvisional:           return "Allow Always Access"
  case .locationReduced:               return "Allow Full Accuracy"
  case .locationRestricted:            return "Remove Restrictions"
  case .locationWhenInUse:             return "Allow Always Access"
  case .locationWhenInUseFirstRequest: return "Allow Always Access"
  case .pushNotShown:                  return "Push Notifications"
  case .waiting:                       return "Waiting for HyperTrack"
  }
}

func message(from s: Blocker.State) -> String {
  switch s {
  case let .deleted(id):
    return "Your company blocked your device. Please contact your manager with the screenshot of this screen if this was a mistake.\n\nDeviceID: \(id)"
  case let .invalidPublishableKey(id):
    return "Our server can't identify the company belonging to your deeplink/credentials. Please contact your manager with the screenshot of this screen.\n\nDeviceID: \(id)"
  case .locationDenied:
    return """
           We need your permission to access your location. Visits app uses your location to manage your work on the move.
           
           Please navigate to Settings > Visits > Location and set to Always.
           """
  case .locationDisabled:
    return """
           Visits app uses your location to manage your work on the move.
            
           Please enable Location Services in Settings > Privacy > Location Services.
           """
  case .locationWhenInUseFirstRequest:
    return """
           We need background location permissions to be set to "Always". Visits app uses your location to manage your work on the move.
           """
  case .locationWhenInUse:
    return """
           We need location permissions to be set to "Always". Visits app uses your location to manage your work on the move.
            
           Please navigate to Settings > Visits > Location and set to Always.
           """
  case .locationNotDetermined:
    return "We need your permission to access your location. Visits app uses your location to manage your work on the move."
  case .locationProvisional:
    return """
           We need location permissions to be set to "Always". Visits app uses your location to manage your work on the move.

           Please navigate to Settings > Visits > Location and set to Always.
           """
  case .locationRestricted:
    return """
           We need your permission to access your location. Visits app uses your location to manage your work on the move.
           
           Please remove restrictions in Settings > Screen Time > Content & Privacy Restriction > Location Services or contact your administrator.
           """
  case .locationReduced:
    return """
           Visits app needs full location accuracy. Visits app uses your location to manage your work on the move.
           
           Please grant full accuracy in Settings > Visits > Location.
           """
  case .pushNotShown:
    return "We use push notifications to notify about new orders."
  case .waiting:
    return "Waiting for HyperTrack services to initialize. This should take less than a second. If the app is stuck on this screen, please shake the phone to generate an error report."
  }
}

func button(from s: Blocker.State) -> (String, Blocker.Action)? {
  switch s {
  case .waiting:                       return nil
  case .deleted:                       return nil
  case .invalidPublishableKey:         return nil
  case .locationWhenInUse:             return ("Open Settings", .locationWhenInUseButtonTapped)
  case .locationWhenInUseFirstRequest: return ("Allow Always", .locationWhenInUseFirstRequestButtonTapped)
  case .locationDenied:                return ("Open Settings", .locationDeniedButtonTapped)
  case .locationDisabled:              return ("Open Settings", .locationDisabledButtonTapped)
  case .locationNotDetermined:         return ("Allow Access", .locationNotDeterminedButtonTapped)
  case .locationRestricted:            return ("Open Settings", .locationRestrictedButtonTapped)
  case .locationReduced:               return ("Open Settings", .locationReducedButtonTapped)
  case .pushNotShown:                  return ("Next", .pushNotShownButtonTapped)
  case .locationProvisional:           return ("Open Settings", .locationProvisionalButtonTapped)
  }
}

func buttonSubtitle(from s: Blocker.State) -> String? {
  switch s {
  default:        return nil
  }
}

struct BlockerScreen_Previews: PreviewProvider {
  static var previews: some View {
    Blocker(
      state: .locationNotDetermined,
      send: { _ in }
    )
  }
}
