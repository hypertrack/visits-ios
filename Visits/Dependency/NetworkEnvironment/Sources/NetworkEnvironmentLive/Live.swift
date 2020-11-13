import Combine
import ComposableArchitecture
import NetworkEnvironment
import Network


public extension NetworkEnvironment {
  static let live = Self(
    networkStatus: {
      Effect.future { callback in
        print("🚀 networkStatus")
        callback(.success(networkPath(pathMonitor.currentPath)))
      }
    },
    subscribeToNetworkUpdates: {
      Effect.run { subscriber in
        print("🚀 subscribeToNetworkUpdates")
        pathMonitor.start(queue: DispatchQueue.main)
        pathMonitor.pathUpdateHandler = {
          print("🚀 subscribeToNetworkUpdates.pathUpdateHandler")
          subscriber.send(networkPath($0))
        }
        return AnyCancellable { pathMonitor.cancel() }
      }
    }
  )
}

var pathMonitor = NWPathMonitor()

func networkPath(_ path: NWPath) -> Network {
  path.status == .satisfied ? .online : .offline
}
