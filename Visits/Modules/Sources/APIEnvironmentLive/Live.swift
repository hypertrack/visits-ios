import APIEnvironment
import NonEmpty


public extension APIEnvironment {
  static let live = Self(
    cancelOrder: cancelOrder(_:_:_:_:),
    completeOrder: completeOrder(_:_:_:_:),
    snoozeOrder: snoozeOrder(_:_:_:_:),
    unsnoozeOrder: unsnoozeOrder(_:_:_:_:),
    createPlace: createPlace(_:_:_:_:_:_:_:),
    getHistory: getHistory(_:_:_:),
    getIntegrationEntities: getIntegrationEntities(_:_:_:),
    getTrip: getTrip(_:_:),
    getPlaces: getPlaces(_:_:_:_:_:),
    getProfile: getProfile(_:_:),
    getToken: getToken(_:_:),
    getVisits: getVisits(_:_:_:_:),
    signIn: signIn(_:_:),
    updateOrderNote: updateOrderNote(_:_:_:_:_:)
  )
}

let baseURL: NonEmptyString = "https://live-app-backend.htprod.hypertrack.com"
let clientURL: NonEmptyString = baseURL + "/client"
let internalAPIURL: NonEmptyString = "https://live-api.htprod.hypertrack.com"
let graphQLURL: NonEmptyString = "https://s6a3q7vbqzfalfhqi2vr32ugee.appsync-api.us-west-2.amazonaws.com/graphql"
let graphQLKey: NonEmptyString = "da2-p6gfdp2tyndifmyufg6qfbscv4"

extension NonEmptyString: Error {}
