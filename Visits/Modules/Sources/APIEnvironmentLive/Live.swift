import APIEnvironment
import NonEmpty


public extension APIEnvironment {
  static let live = Self(
    getHistory: getHistory(_:_:_:),
    getOrders: getOrders(_:_:),
    getPlaces: getPlaces(_:_:),
    reverseGeocode: reverseGeocode(_:),
    signIn: signIn(_:_:)
  )
}

let accountURL: NonEmptyString = "https://live-account.htprod.hypertrack.com"
let baseURL: NonEmptyString = "https://live-app-backend.htprod.hypertrack.com"
let clientURL: NonEmptyString = baseURL + "/client"
let internalAPIURL: NonEmptyString = "https://live-api.htprod.hypertrack.com"

extension NonEmptyString: Error {}
