import Foundation
import Types


func localizedTime(_ time: UInt, style: DateComponentsFormatter.UnitsStyle = .short) -> String {
  let formatter = DateComponentsFormatter()
  if time > 60 {
    formatter.allowedUnits = [.hour, .minute]
  } else {
    formatter.allowedUnits = [.second]
  }
  formatter.unitsStyle = style
  return formatter.string(from: TimeInterval(time))!
}

let placePreviewSample = Place(
  id: "a4bde564-bc91-45b5-8a8c-19deb695bc4d",
  address: .init(
    street: "1301 Market St",
    fullAddress: "Market Square, 1301 Market St, San Francisco, CA  94103, United States"
  ),
  createdAt: .init(rawValue: Date()),
  currentlyInside: nil,
  metadata: ["stop_name":"One", "title": "something"],
  shape: .circle(
    .init(
      center: Coordinate(
        latitude: 37.789784,
        longitude: -122.396867
      )!,
      radius: 100
    )
  ),
  visits: [
    .init(id: "1", entry: .init(rawValue: Date()), exit: .init(rawValue: Date())),
    .init(id: "2", entry: .init(rawValue: Date()), exit: .init(rawValue: Date()))
  ]
)
