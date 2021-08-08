import APIEnvironment
import Combine
import ComposableArchitecture
import LogEnvironment
import NonEmpty
import Utility
import Types


func createPlace(
  _ token: Token.Value,
  _ dID: DeviceID,
  _ c: Coordinate,
  _ ie: IntegrationEntity
) -> Effect<Result<Place, APIError<Token.Expired>>, Never> {
  logEffect("addPlace")
  
  return callAPI(
    request: createPlaceRequest(auth: token, deviceID: dID, coordinate: c, integrationEntity: ie),
    success: NonEmptyArray<Geofence>.self,
    failure: Token.Expired.self
  )
  .map(\.first)
  .map(Place.init(geofence:))
  .catchToEffect()
}

func createPlaceRequest(auth token: Token.Value, deviceID: DeviceID, coordinate: Coordinate, integrationEntity: IntegrationEntity) -> URLRequest {
  let url = URL(string: "\(clientURL)/geofences")!
  var request = URLRequest(url: url)
  request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  request.httpMethod = "POST"
  request.httpBody = try! JSONSerialization.data(
    withJSONObject: [
      "device_id": deviceID.string,
      "geofences": [
        [
          "geometry": [
            "type": "Point",
            "coordinates": [coordinate.longitude, coordinate.latitude]
          ],
          "metadata": [
            "integration": [
              "id": integrationEntity.id.string,
              "name": integrationEntity.name.string
            ],
            "name": integrationEntity.name.string
          ],
          "radius": 150
        ]
      ]
    ],
    options: JSONSerialization.WritingOptions(rawValue: 0)
  )
  return request
}
