import Foundation
import Types


struct PlacesSection {
  struct PlaceAndTime {
    let place: Place
    let time: String?
  }
  
  let header: String
  let places: [PlaceAndTime]
}

struct VisitsSection {
  let header: VisitsHeader
  let visits: [VisitItem]
}

struct VisitsHeader {
  let date: Date
  let distance: UInt
}

struct VisitItem {
  let entryOrVisit: EntryOrVisit
  let place: Place
}

enum EntryOrVisit {
  case entry(Place.Entry)
  case visit(Place.Visit)
}

extension EntryOrVisit {
  var entry: Date {
    switch self {
    case let .entry(e): return e.entry.rawValue
    case let .visit(v): return v.entry.rawValue
    }
  }

  var id: String {
    switch self {
    case let .entry(e): return e.id.string
    case let .visit(v): return v.id.string
    }
  }
}
