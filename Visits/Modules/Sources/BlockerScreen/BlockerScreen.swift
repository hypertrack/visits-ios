import SwiftUI
import Views


public struct Blocker: View {
  public enum State: Equatable {
    case noMotionServices
    case deleted(String)
    case invalidPublishableKey(String)
    case stopped
    case locationDenied
    case locationDisabled
    case locationNotDetermined
    case locationRestricted
    case locationReduced
    case motionDenied
    case motionDisabled
    case motionNotDetermined
    case pushNotShown
  }
  
  public enum Action: Equatable {
    case deletedButtonTapped
    case invalidPublishableKeyButtonTapped
    case stoppedButtonTapped
    case locationDeniedButtonTapped
    case locationDisabledButtonTapped
    case locationNotDeterminedButtonTapped
    case locationRestrictedButtonTapped
    case locationReducedButtonTapped
    case motionDeniedButtonTapped
    case motionDisabledButtonTapped
    case motionNotDeterminedButtonTapped
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
  case .noMotionServices:      return "No Motion Services"
  case .deleted:               return "Device Blocked"
  case .invalidPublishableKey: return "Internal Error"
  case .stopped:               return "Clock In"
  case .locationDenied:        return "Allow Location Access"
  case .locationDisabled:      return "Enable Location"
  case .locationNotDetermined: return "Allow Location Access"
  case .locationRestricted:    return "Remove Restrictions"
  case .locationReduced:       return "Allow Full Accuracy"
  case .motionDenied:          return "Allow Motion Access"
  case .motionDisabled:        return "Enable Motion & Fitness"
  case .motionNotDetermined:   return "Allow Motion Access"
  case .pushNotShown:          return "Push Notifications"
  }
}

func message(from s: Blocker.State) -> String {
  switch s {
  case .noMotionServices:
    return "The app requires a device with an Apple M-series coprocessor. This includes all iPhones after iPhone 5S and iPads released after 2013. Please install the app on one of the supported devices."
  case let .deleted(id):
    return "Your company blocked your device. Please contact your manager with the screenshot of this screen if this was a mistake.\n\nDeviceID: \(id)"
  case let .invalidPublishableKey(id):
    return "Our server can't identify the company belonging to your deeplink/credentials. Please contact your manager with the screenshot of this screen.\n\nDeviceID: \(id)"
  case .stopped:
    return "You are currently clocked out. Clocking in starts location tracking and opens the orders for today.\n\nThe app does not track your location while you are clocked out."
  case .locationDenied:
    return """
           We need your permission to access your location. Visits app uses your location to calculate mileage.
           
           Please navigate to Settings > Logistics > Location and set to Always.
           """
  case .locationDisabled:
    return """
           We need Location Services to track your current location. Visits app uses your location to calculate mileage.
            
           Please enable Location Services in Settings > Privacy > Location Services.
           """
  case .locationNotDetermined:
    return "We need your permission to access your location. Visits app uses your location to calculate mileage."
  case .locationRestricted:
    return """
           Visits app needs Location Services to track your current location and calculate mileage.
           
           Please remove restrictions in Settings > Screen Time > Content & Privacy Restriction > Location Services or contact your administrator.
           """
  case .locationReduced:
    return """
           Visits app needs full location accuracy to calculate mileage.
           
           Please grant full accuracy in Settings > Visits > Location.
           """
  case .motionDenied:
    return """
           We need your permission to access your motion.
           
           We use Motion & Fitness to efficiently use your battery when tracking.
           
           Please enable Motion & Fitness in Settings > Logistics > Motion & Fitness.
           """
  case .motionDisabled:
    return """
           We use Motion & Fitness to efficiently use your battery when tracking.
           
           Please enable Fitness Tracking in Settings > Privacy > Motion & Fitness > Fitness Tracking.
           """
  case .motionNotDetermined:
    return "We use Motion & Fitness to efficiently use your battery when tracking."
    
  case .pushNotShown:
    return "We use push notifications to notify about new orders."
  }
}

func button(from s: Blocker.State) -> (String, Blocker.Action)? {
  switch s {
  case .noMotionServices:      return nil
  case .deleted:               return ("Resolved?", .deletedButtonTapped)
  case .invalidPublishableKey: return ("Resolved?", .invalidPublishableKeyButtonTapped)
  case .stopped:               return ("Clock In", .stoppedButtonTapped)
  case .locationDenied:        return ("Open Settings", .locationDeniedButtonTapped)
  case .locationDisabled:      return ("Open Settings", .locationDisabledButtonTapped)
  case .locationNotDetermined: return ("Allow Access", .locationNotDeterminedButtonTapped)
  case .locationRestricted:    return ("Open Settings", .locationRestrictedButtonTapped)
  case .locationReduced:       return ("Open Settings", .locationReducedButtonTapped)
  case .motionDenied:          return ("Open Settings", .motionDeniedButtonTapped)
  case .motionDisabled:        return ("Open Settings", .motionDisabledButtonTapped)
  case .motionNotDetermined:   return ("Allow Access", .motionNotDeterminedButtonTapped)
  case .pushNotShown:          return ("Next", .pushNotShownButtonTapped)
  }
}

func buttonSubtitle(from s: Blocker.State) -> String? {
  switch s {
  case .stopped:  return "This will start location tracking"
  default:        return nil
  }
}

struct BlockerScreen_Previews: PreviewProvider {
  static var previews: some View {
    Blocker(
      state: .motionNotDetermined,
      send: { _ in }
    )
  }
}
