import APIEnvironment
import NonEmpty


public extension APIEnvironment {
  static let live = Self(
    getHistory: getHistory(_:_:_:),
    getVisits: getVisits(_:_:),
    reverseGeocode: reverseGeocode(_:),
    signIn: signIn(_:_:)
  )
}

let baseURL: NonEmptyString = "https://live-app-backend.htprod.hypertrack.com"
let clientURL: NonEmptyString = baseURL + "/client"
let internalAPIURL: NonEmptyString = "https://live-api.htprod.hypertrack.com"

extension NonEmptyString: Error {}
