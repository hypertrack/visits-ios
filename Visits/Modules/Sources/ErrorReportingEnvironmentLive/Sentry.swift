import ErrorReportingEnvironment
import Sentry
import Types


public extension ErrorReportingEnvironment {
  static let live = Self(
    addBreadcrumb: { type, message in
      .fireAndForget {
        for breadcrumb in splitBreadcrumb(type, message) {
          SentrySDK.addBreadcrumb(crumb: breadcrumb)
        }
      }
    },
    capture: { m in
      .fireAndForget {
        if m.string.count > maxBreadcrumbLength {
          for breadcrumb in splitBreadcrumb(.error, .init(rawValue: m.rawValue)) {
            SentrySDK.addBreadcrumb(crumb: breadcrumb)
          }
        }
        SentrySDK.capture(message: m.string)
      }
    },
    startErrorMonitoring: {
      .fireAndForget {
        SentrySDK.start { options in
          options.dsn = "https://b7c00b414cf14086b0bd873305058044@sentry.htprod.hypertrack.com/7"
          options.attachStacktrace = false
        }
      }
    },
    updateUser: { deviceID in
      .fireAndForget {
        SentrySDK.setUser(sentryUser(from: deviceID))
      }
    }
  )
}

func sentryUser(from deviceID: DeviceID) -> Sentry.User {
  let sentryUser = Sentry.User()
  sentryUser.userId = deviceID.string
  return sentryUser
}

let maxBreadcrumbLength = 4096

func splitBreadcrumb(_ t: BreadcrumbType, _ m: BreadcrumbMessage) -> [Breadcrumb] {
  m.string.split(by: maxBreadcrumbLength).map {
    breadcrumb(t.rawValue, m: $0)
  }
}

func breadcrumb(_ t: String, m: String) -> Breadcrumb {
  let crumb = Breadcrumb()
  crumb.category = t
  crumb.message = m
  return crumb
}

extension String {
  func split(by length: Int) -> [String] {
    let splitted = self.split(whereSeparator: \.isNewline)
    
    var output: [String] = []
    var candidate: String = ""
    
    for element in splitted {
      let stringElement = String(element)
      let combined = candidate + "\n" + stringElement
      if combined.count > length {
        output.append(candidate)
        candidate = stringElement
      } else {
        candidate = combined
      }
    }
    if !candidate.isEmpty {
      output.append(candidate)
    }
    return output
  }
}
