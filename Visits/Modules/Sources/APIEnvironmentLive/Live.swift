import APIEnvironment
import NonEmpty


public extension APIEnvironment {
  static let live = Self(
    getHistory: getHistory(_:_:_:),
    getVisits: getVisits(_:_:),
    resendVerificationCode: resendVerification(email:),
    reverseGeocode: reverseGeocode(_:),
    signIn: signIn(_:_:),
    signUp: signUp(name:email:password:businessManages:managesFor:),
    verifyEmail: verifyEmail(email:code:)
  )
}

let accountURL: NonEmptyString = "https://live-account.htprod.hypertrack.com"
let baseURL: NonEmptyString = "https://live-app-backend.htprod.hypertrack.com"
let clientURL: NonEmptyString = baseURL + "/client"
let internalAPIURL: NonEmptyString = "https://live-api.htprod.hypertrack.com"

extension NonEmptyString: Error {}
