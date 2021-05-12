import Types

struct PlacesSection {
  struct PlaceAndTime {
    let place: Place
    let time: String?
  }
  
  let header: String
  let places: [PlaceAndTime]
}
