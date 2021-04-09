import Prelude
import SwiftUI
import Types
import Views


public struct PlacesScreen: View {
  public struct State {
    let places: Set<Place>
    
    var placesToDisplay: [Section] {
      var notVisited: [Place] = []
      var visited: [(Place, Date)] = []
      for place in places {
        if let visit = place.currentlyInside?.entry.rawValue ?? place.visits.first?.exit.rawValue {
          visited += [(place, visit)]
        } else {
          notVisited.append(place)
        }
      }
      
      var sections: [Section] = []
      
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
              .map{ ($0.0, DateFormatter.stringTime($0.1)) }
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
    
    struct Section {
      struct PlaceAndTime {
        let place: Place
        let time: String?
      }
      
      let header: String
      let places: [PlaceAndTime]
    }
    
    public init(places: Set<Place>) {
      self.places = places
    }
  }
  
  //"Place created @ \(DateFormatter.stringTime(createdAt.rawValue))"
  @Environment(\.colorScheme) var colorScheme
  
  let state: State
  
  public init(state: State) {
    self.state = state
  }
  
  public var body: some View {
    NavigationView {
      List {
        ForEach(state.placesToDisplay, id: \.header) { section in
          Section(header: Text(section.header).font(.subheadline)) {
            
            ForEach(section.places, id: \.place.id) { placeAndTime in
              HStack {
                Image(systemName: "mappin.circle")
                  .font(.title)
                  .foregroundColor(.accentColor)
                  .padding(.trailing, 10)
                VStack {
                  if placeAndTime.time != nil || placeAndTime.place.numberOfVisits != 0 {
                    HStack {
                      if let time = placeAndTime.time {
                        Text(time)
                          .font(.caption)
                          .foregroundColor(Color(.secondaryLabel))
                      }
                      Spacer()
                      if case let count = placeAndTime.place.numberOfVisits, count != 0 {
                        HStack {
                          Spacer()
                          Text("Visited \(count) \(count == 1 ? "time" : "times")")
                            .font(.caption)
                            .foregroundColor(Color(.secondaryLabel))
                        }
                      }
                    }
                  }
                  if let place = placeAndTime.place.name,
                     let address = placeAndTime.place.address.anyAddress?.rawValue {
                    PrimaryRow(place)
                      .padding(.bottom, -3)
                    SecondaryRow(address)
                  } else {
                    PrimaryRow(
                      placeAndTime.place.name ??
                        (placeAndTime.place.address.anyAddress?.rawValue ??
                          placeAndTime.place.fallbackTitle)
                    )
                  }
                }
                
              }
              .padding(.vertical, 10)
            }
          }
        }
      }
      .listStyle(GroupedListStyle())
      .navigationBarTitle(Text("Places"), displayMode: .automatic)
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

extension Sequence {
  func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
    return sorted { a, b in
      return a[keyPath: keyPath] < b[keyPath: keyPath]
    }
  }
}

struct PrimaryRow: View {
  let text: String
  
  init(_ text: String) { self.text = text }
  
  var body: some View {
    HStack {
      Text(text)
        .font(.headline)
        .foregroundColor(Color(.label))
      Spacer()
    }
  }
}

struct SecondaryRow: View {
  let text: String
  
  init(_ text: String) { self.text = text }
  
  var body: some View {
    HStack {
      Text(text)
        .font(.footnote)
        .foregroundColor(Color(.secondaryLabel))
        .fontWeight(.bold)
      Spacer()
    }
  }
}



extension Place {
  var name: String? {
    if let name = metadata["name"] {
      return name.rawValue.rawValue
    }
    if let nameKey = metadata.keys.first(where: { $0.rawValue.rawValue.contains("name") }),
       let name = metadata[nameKey]  {
      return name.rawValue.rawValue
    }
    return nil
  }
  
  var fallbackTitle: String {
    if Calendar.current.isDate(createdAt.rawValue, equalTo: Date(), toGranularity: .day) {
      return "Place created @ \(DateFormatter.stringTime(createdAt.rawValue))"
    } else {
      return "Place created @ \(DateFormatter.stringDate(createdAt.rawValue)), \(DateFormatter.stringTime(createdAt.rawValue))"
    }
  }
  var numberOfVisits: UInt {
    switch currentlyInside {
    case .some: return UInt(1 + visits.count)
    case .none: return UInt(visits.count)
    }
  }
}

extension DateFormatter {
  static func stringTime(_ date: Date) -> String {
    let dateFormat = DateFormatter()
    dateFormat.locale = Locale(identifier: "en_US_POSIX")
    dateFormat.dateFormat = "h:mm a"
    return dateFormat.string(from: date)
  }
}

extension DateFormatter {
  static func stringDate(_ date: Date) -> String {
    let dateFormat = DateFormatter()
    dateFormat.locale = Locale(identifier: "en_US_POSIX")
    if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .year) {
      dateFormat.dateFormat = "MMM d"
    } else {
      dateFormat.dateFormat = "MMM d, yyyy"
    }
    return dateFormat.string(from: date)
  }
}

struct PlacesScreen_Previews: PreviewProvider {
  static var previews: some View {
    PlacesScreen(
      state: .init(
        places: [
          Place(
            id: "a4bde564-bc91-45b5-8a8c-19deb695bc4b",
            address: .init(
              street: "1301 Market St",
              fullAddress: "Market Square, 1301 Market St, San Francisco, CA  94103, United States"
            ),
            createdAt: .init(rawValue: ISO8601DateFormatter().date(from: "2021-03-28T10:44:00Z")!),
            currentlyInside: nil,
            metadata: ["stop_name":"One"],
            shape: .circle(
              .init(
                center: .init(
                  latitude: 35.54,
                  longitude: 42.654
                )!,
                radius: 100
              )
            ),
            visits: []
          ),
          Place(
            id: "a4bde564-bc91-45b5-8a8c-19deb695bc4j",
            address: .none,
            createdAt: .init(rawValue: ISO8601DateFormatter().date(from: "2021-03-28T10:44:00Z")!),
            currentlyInside: nil,
            metadata: [:],
            shape: .circle(
              .init(
                center: .init(
                  latitude: 35.54,
                  longitude: 42.654
                )!,
                radius: 100
              )
            ),
            visits: []
          ),
          Place(
            id: "a4bde564-bc91-45b5-8a8c-19deb695bc4a",
            address: .init(
              street: "1301 Market St",
              fullAddress: "Market Square, 1301 Market St, San Francisco, CA  94103, United States"
            ),
            createdAt: .init(rawValue: ISO8601DateFormatter().date(from: "2021-03-28T10:45:00Z")!),
            currentlyInside: nil,
            metadata: [:],
            shape: .circle(
              .init(
                center: .init(
                  latitude: 35.54,
                  longitude: 42.654
                )!,
                radius: 100
              )
            ),
            visits: []
          ),
          Place(
            id: "a4bde564-bc91-45b5-8a8c-19deb695bc4c",
            address: .init(
              street: "1301 Market St",
              fullAddress: "Market Square, 1301 Market St, San Francisco, CA  94103, United States"
            ),
            createdAt: .init(rawValue: ISO8601DateFormatter().date(from: "2020-03-30T10:42:03Z")!),
            currentlyInside: .init(entry: .init(rawValue: ISO8601DateFormatter().date(from: "2020-04-01T19:27:00Z")!), duration: 0),
            metadata: ["name":"Home"],
            shape: .circle(
              .init(
                center: .init(
                  latitude: 35.54,
                  longitude: 42.654
                )!,
                radius: 100
              )
            ),
            visits: []
          ),
          Place(
            id: "a4bde564-bc91-45b5-8a8c-19deb695bc4d",
            address: .none,
            createdAt: .init(rawValue: Date()),
            currentlyInside: nil,
            metadata: [:],
            shape: .circle(
              .init(
                center: .init(
                  latitude: 35.54,
                  longitude: 42.654
                )!,
                radius: 100
              )
            ),
            visits: [
              .init(entry: .init(rawValue: Date()), exit: .init(rawValue: Date()), duration: .init(rawValue: 0)),
              .init(entry: .init(rawValue: Date()), exit: .init(rawValue: Date()), duration: .init(rawValue: 0))
            ]
          )
        ]
      )
    )
    .preferredColorScheme(.light)
  }
}
