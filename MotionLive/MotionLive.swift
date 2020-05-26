import CoreMotion

import ComposableArchitecture

import Motion


extension MotionEnvironment {
  public static let live = MotionEnvironment(
    check: {
      .future { callback in
        let manager: CMMotionActivityManager
        if let exist = dependency {
          manager = exist
        } else {
          manager = CMMotionActivityManager()
        }
        manager.queryActivityStarting(
          from: Date(),
          to: Date(),
          to: OperationQueue.main) { optionalActivities, optionalError in
            if optionalActivities != nil {
              callback(.success(.authorized))
            } else {
              let authorizationStatus = CMMotionActivityManager.authorizationStatus()
              switch (authorizationStatus, optionalError) {
              case (.denied, _):
                callback(.success(.denied))
              case (.authorized, .some):
                callback(.success(.restricted))
              case (.restricted, .some):
                callback(.success(.unknown))
              case (.notDetermined, .none):
                fatalError()
              case (.notDetermined, .some):
                fatalError()
              case (.restricted, .none):
                fatalError()
              case (.authorized, .none):
                fatalError()
              case (_, _):
                fatalError()
              }
            }
        }
      }
    }
  )
}

private var dependency: CMMotionActivityManager?
