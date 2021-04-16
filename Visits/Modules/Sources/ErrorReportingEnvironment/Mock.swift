import ComposableArchitecture
import Types
import NonEmpty


public extension ErrorReportingEnvironment {
  static let noop = Self(
    addBreadcrumb: { _, _ in .none },
    capture: { _ in .none },
    startErrorMonitoring: { .none },
    updateUser: { _ in .none }
  )
  
  static let printing = Self(
    addBreadcrumb: { type, message in
      .fireAndForget {
        print("❗️ Adding Breadcrumb: \(type.rawValue) \n \(message.string)")
      }
    },
    capture: { message in
      .fireAndForget {
        print("❗️ Captured Event:" + message.string)
      }
    },
    startErrorMonitoring: {
      .fireAndForget {
        print("❗️ Starting Error Monitoring")
      }
    },
    updateUser: { deviceID in
      .fireAndForget {
        print("❗️ Updating User's Device ID:" + deviceID.string)
      }
    }
  )
}
