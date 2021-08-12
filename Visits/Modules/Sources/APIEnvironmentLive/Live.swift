import APIEnvironment
import NonEmpty


public extension APIEnvironment {
  static let live = Self(
    cancelOrder: cancelOrder(_:_:_:),
    completeOrder: completeOrder(_:_:_:),
    createPlace: createPlace(_:_:_:_:_:_:_:),
    getHistory: getHistory(_:_:_:),
    getIntegrationEntities: getIntegrationEntities(_:_:_:),
    getOrders: getOrders(_:_:),
    getPlaces: getPlaces(_:_:),
    getProfile: getProfile(_:_:),
    getToken: getToken(_:_:),
    signIn: signIn(_:_:),
    updateOrderNote: updateOrderNote(_:_:_:_:)
  )
}

let accountURL: NonEmptyString = "https://live-account.htprod.hypertrack.com"
let baseURL: NonEmptyString = "https://live-app-backend.htprod.hypertrack.com"
let clientURL: NonEmptyString = baseURL + "/client"
let internalAPIURL: NonEmptyString = "https://live-api.htprod.hypertrack.com"

extension NonEmptyString: Error {}
