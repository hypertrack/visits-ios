import Foundation
import Types


extension PlacesScreen.State {
  var placesToDisplay: [PlacesSection] {
    var notVisited: [Place] = []
    var visited: [(Place, Date)] = []
    for place in places {
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
    
    let notVisitedSorted = notVisited.sorted(by: \.createdAt.rawValue)
    let notVisitedReversed = notVisitedSorted.reversed()
    
    if !notVisitedReversed.isEmpty {
      sections.append(
        .init(
          header: "Not visited",
          places: notVisitedReversed.map{ .init(place: $0, time: nil) }
        )
      )
    }
    return sections
  }
}
