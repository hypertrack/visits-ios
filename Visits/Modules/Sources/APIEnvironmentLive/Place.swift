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
  _ c: PlaceCenter,
  _ r: PlaceRadius,
  _ ie: IntegrationEntity,
  _ a: CustomAddress?,
  _ d: PlaceDescription?
) -> Effect<Result<Place, APIError<Token.Expired>>, Never> {
  logEffect("addPlace")
  
  return callAPI(
    request: createPlaceRequest(
      auth: token,
      deviceID: dID,
      center: c,
      radius: r,
      integrationEntity: ie,
      customAddress: a,
      description: d
    ),
    success: NonEmptyArray<Geofence>.self,
    failure: Token.Expired.self
  )
  .map(\.first)
  .map(Place.init(geofence:))
  .catchToEffect()
}

func createPlaceRequest(
  auth token: Token.Value,
  deviceID: DeviceID,
  center: PlaceCenter,
  radius: PlaceRadius,
  integrationEntity: IntegrationEntity,
  customAddress: CustomAddress?,
  description: PlaceDescription?
) -> URLRequest {
  let url = URL(string: "\(clientURL)/geofences")!
  var request = URLRequest(url: url)
  request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
  request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
  request.httpMethod = "POST"

  var metadata: [String: Any] = [
    "integration": [
      "id": integrationEntity.id.string,
      "name": integrationEntity.name.string
    ],
    "name": integrationEntity.name.string
  ]

  if let customAddress = customAddress {
    metadata["address"] = customAddress.string
  }

  if let description = description {
    metadata["description"] = description.string
  }

  request.httpBody = try! JSONSerialization.data(
    withJSONObject: [
      "device_id": deviceID.string,
      "geofences": [
        [
          "geometry": [
            "type": "Point",
            "coordinates": [center.longitude, center.latitude]
          ],
          "metadata": metadata,
          "radius": Int(radius.rawValue)
        ]
      ]
    ],
    options: JSONSerialization.WritingOptions(rawValue: 0)
  )
  return request
}
