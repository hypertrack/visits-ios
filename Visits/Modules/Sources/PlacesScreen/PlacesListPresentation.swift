import Foundation
import Types


extension PlacesScreen.State {
  var placesToDisplay: [PlacesSection] {
    var notVisited: [Place] = []
    var visited: [(Place, Date)] = []
    for place in places?.places ?? [] {
      let currentlyInside = place.currentlyInside != nil ? Date() : nil
      if let visit = currentlyInside ?? place.visits.first?.exit.rawValue {
        visited += [(place, visit)]
      } else {
        notVisited.append(place)
      }
    }
    
    var sections: [PlacesSection] = []
    
    let keysAndValues = visited.sorted(by: \.1).reversed()
    
    var newDict: [String: [(Place, Date)]] = [:]
    
    for (place, date) in keysAndValues {
      let dateString = Calendar.current.isDate(date, equalTo: Date(), toGranularity: .day) ? "TODAY" : DateFormatter.stringDate(date)
      let places = newDict[dateString] ?? []
      newDict[dateString] = places + [(place, date)]
    }
    
    let new = newDict.sorted { one, two in
      one.value.first!.1 > two.value.first!.1
    }
    
    for (time, places) in new {
      let placesSorted = places.sorted(by: \.1).reversed()
      
      sections.append(
        .init(
          header: time,
          places: placesSorted
            .map{ ($0.0, Calendar.current.isDate($0.1, equalTo: Date(), toGranularity: .minute) ? "Now" : DateFormatter.stringTime($0.1)) }
            .map { .init(place: $0.0, time: $0.1) }
        )
      )
    }
    
    if let currentLocation = currentLocation {
      notVisited = notVisited.sorted { p1, p2 in
        currentLocation.distance(from: p1.shape.centerCoordinate)
          < currentLocation.distance(from: p2.shape.centerCoordinate)
      }
    } else {
      notVisited = notVisited.sorted(by: \.createdAt.rawValue).reversed()
    }
    
    if !notVisited.isEmpty {
      sections.append(
        .init(
          header: "Not visited",
          places: notVisited.map{ .init(place: $0, time: nil) }
        )
      )
    }
    return sections
  }

  var visitsToDisplay: [VisitsSection] {
    guard let places = places else { return [] }

    var sections: [VisitsSection] = []

    let calendar = Calendar.current

    let requestedDateComponents = calendar.dateComponents([.year, .month, .day], from: places.requestedAt)
    let cleanedRequestedDate = calendar.date(from: requestedDateComponents)!

    for (day, distance) in places.driveDistancesForDaysWithVisits.enumerated() {
      guard let distance = distance else { continue }

      let date = calendar.date(byAdding: .day, value: -day, to: cleanedRequestedDate)!
      let header = VisitsHeader(date: date, distance: distance)

      let visits = places.places.flatMap { (p: Place) -> [VisitItem] in
        var visitItems: [VisitItem] = []

        if let inside = p.currentlyInside,
           calendar.isDate(inside.entry.rawValue, equalTo: date, toGranularity: .day) {
          visitItems.append(.init(entryOrVisit: .entry(inside), place: p))
        }

        for visit in p.visits {
          if calendar.isDate(visit.entry.rawValue, equalTo: date, toGranularity: .day) {
            visitItems.append(.init(entryOrVisit: .visit(visit), place: p))
          }
        }

        return visitItems
      }
      .sorted(by: \.entryOrVisit.entry)
      .reversed()

      sections.append(.init(header: header, visits: Array(visits)))
    }

    return sections
  }
}
