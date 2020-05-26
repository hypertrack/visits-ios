import Combine
import Network

import ComposableArchitecture

import Reachability

extension ReachabilityEnvironment {
  public static let live = ReachabilityEnvironment(
    startMonitoring: {
      Effect.async { subscriber in
        dependency.start(queue: DispatchQueue.main)
        dependency.pathUpdateHandler = { subscriber.send($0.status == .satisfied) }
        return AnyCancellable { dependency.cancel() }
      }
    }
  )
}

private var dependency = NWPathMonitor()
