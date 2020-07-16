import ComposableArchitecture
import Prelude
import Combine
import CoreLocation
import HyperTrack
import MapKit

// MARK: - Delivery model

public struct SingleDelivery: Identifiable {
  public let id: NonEmptyString
  public let lat: Double
  public let lng: Double
  public var shortAddress: String = ""
  public var fullAddress: String = ""
  public let metadata: [Metadata]
  
  public struct Metadata: Hashable {
    public let key: String
    public let value: String
    
    public init(key: String, value: String) {
      self.key = key
      self.value = value
    }
  }
  
  public init(id: NonEmptyString, lat: Double, lng: Double, shortAddress: String = "", fullAddress: String = "", metadata: [SingleDelivery.Metadata]) {
    self.id = id
    self.lat = lat
    self.lng = lng
    self.shortAddress = shortAddress
    self.fullAddress = fullAddress
    self.metadata = metadata
  }
}

extension SingleDelivery: Equatable {
  public static func == (lhs: SingleDelivery, rhs: SingleDelivery) -> Bool {
    return lhs.id == rhs.id
  }
}

extension NonEmptyString: Error {}

func hypertrack(_ publishableKey: NonEmptyString) -> HyperTrack {
  let pk = HyperTrack.PublishableKey(publishableKey.rawValue)!
  return try! HyperTrack(publishableKey: pk)
}

func sendDeliveryCompletion(_ publishableKey: NonEmptyString, _ geofenceID: NonEmptyString) -> Effect<Never, Never> {
  .fireAndForget {
    hypertrack(publishableKey).addGeotag(HyperTrack.Metadata(dictionary: ["geofence_id": geofenceID.rawValue, "completed":true])!)
  }
}

func sendDeliveryNote(_ publishableKey: NonEmptyString, _ note: NonEmptyString, _ geofenceID: NonEmptyString) -> Effect<Never, Never> {
  .fireAndForget {
    hypertrack(publishableKey).addGeotag(HyperTrack.Metadata(dictionary: ["geofence_id": geofenceID.rawValue, "delivery_note":note.rawValue])!)
  }
}

func openAppleMap(address: NonEmptyString, _ coordinate: CLLocationCoordinate2D) -> Effect<Never, Never> {
  .fireAndForget {
    let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.02))
    let placemark = MKPlacemark(coordinate: coordinate)
    let mapItem = MKMapItem(placemark: placemark)
    let options = [
        MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
        MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span)
    ]
    mapItem.name = address.rawValue
    mapItem.openInMaps(launchOptions: options)
  }
}
