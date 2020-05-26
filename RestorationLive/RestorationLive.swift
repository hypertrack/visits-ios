import Foundation

import ComposableArchitecture
import Prelude

import Restoration

enum RestorationKey {
  static let completedDeliveriesIDs = "FKvsz7tEs4"
  static let publishableKey = "UeiDZRFEOd"
  static let driverID = "Hp6XdOsXsw"
}

extension RestorationEnvironment {
  public static let live = RestorationEnvironment(
    saveCompletedDeliveries: { completedDeliveries in
      .fireAndForget {
        UserDefaults.standard.set(
          completedDeliveries.map { $0.rawValue },
          forKey: RestorationKey.completedDeliveriesIDs
        )
      }
    },
    saveDriverID: { driverID in
      .fireAndForget {
        UserDefaults.standard.set(
          driverID.rawValue,
          forKey: RestorationKey.driverID
        )
      }
    },
    savePublishableKey: { publishableKey in
      .fireAndForget {
        UserDefaults.standard.set(
          publishableKey.rawValue,
          forKey: RestorationKey.publishableKey
        )
      }
    }
  )
}
