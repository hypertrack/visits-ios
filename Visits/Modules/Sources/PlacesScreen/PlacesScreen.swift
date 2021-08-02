import MapKit
import Utility
import SwiftUI
import Types
import Views


public struct PlacesScreen: View {
   
  public struct State {
    let places: Set<Place>
    let refreshing: Bool
    let integrationStatus: IntegrationStatus
    
    public init(places: Set<Place>, refreshing: Bool, integrationStatus: IntegrationStatus) {
      self.places = places
      self.refreshing = refreshing
      self.integrationStatus = integrationStatus
    }
  }
  public enum Action {
    case refresh
    case addPlace
  }
  
  let state: State
  let send: (Action) -> Void
  
  public init(
    state: State,
    send: @escaping (Action) -> Void
  ) {
    self.state = state
    self.send = send
  }
  
  var integrated: Bool {
    if case .integrated = state.integrationStatus {
      return true
    }
    return false
  }
  
  public var body: some View {
    NavigationView {
      PlacesList(placesToDisplay: state.placesToDisplay)
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            RefreshButton(state: state.refreshing ? .refreshing : .enabled) {
              send(.refresh)
            }
          }
        }
        .if(integrated) { view in
          view.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
              Button(action: { send(.addPlace) }) {
                Image(systemName: "plus")
              }
            }
          }
        }
    }
  }
}



struct PlacesList: View {
  let placesToDisplay: [PlacesSection]
  
  var body: some View {
    ZStack {
      List {
        ForEach(placesToDisplay, id: \.header) { section in
          Section(header: Text(section.header).font(.subheadline)) {
            ForEach(section.places, id: \.place.id) { placeAndTime in
              NavigationLink(
                destination: PlaceScreen(state: .init(place: placeAndTime.place))
              ) {
                PlaceView(placeAndTime: placeAndTime)
              }
            }
          }
        }
      }
      .listStyle(GroupedListStyle())
      if placesToDisplay.isEmpty {
        Text("No places yet")
          .font(.title)
          .foregroundColor(Color(.secondaryLabel))
          .fontWeight(.bold)
      }
    }
    .navigationBarTitle(Text("Places"), displayMode: .automatic)
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

extension Place {
  var name: String? {
    if let name = metadata["name"] {
      return name.string
    }
    if let nameKey = metadata.keys.first(where: { $0.string.contains("name") }),
       let name = metadata[nameKey]  {
      return name.string
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
    PlacesScreen(state: .init(places: [], refreshing: false, integrationStatus: .integrated(.notRefreshing)), send: {_ in })
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
                center: Coordinate(
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
                center: Coordinate(
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
                center: Coordinate(
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
                center: Coordinate(
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
                center: Coordinate(
                  latitude: 35.54,
                  longitude: 42.654
                )!,
                radius: 100
              )
            ),
            visits: [
              .init(id: "1", entry: .init(rawValue: Date()), exit: .init(rawValue: Date()), duration: .init(rawValue: 0)),
              .init(id: "2", entry: .init(rawValue: Date()), exit: .init(rawValue: Date()), duration: .init(rawValue: 0))
            ]
          )
        ], refreshing: false, integrationStatus: .integrated(.notRefreshing)
      ), send: {_ in }
    )
    .preferredColorScheme(.light)
  }
}

struct PlaceView: View {
  let placeAndTime: PlacesSection.PlaceAndTime
  
  var body: some View {
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
           let address = placeAndTime.place.address.anyAddressStreetBias?.rawValue {
          PrimaryRow(place)
            .padding(.bottom, -3)
          SecondaryRow(address)
        } else {
          PrimaryRow(
            placeAndTime.place.name ??
              (placeAndTime.place.address.anyAddressStreetBias?.rawValue ??
                placeAndTime.place.fallbackTitle)
          )
        }
      }
    }
    .padding(.vertical, 10)
  }
}

public struct PlaceScreen: View {
  public struct State {
    let place: Place
    
    public init(place: Place) {
      self.place = place
    }
  }
  
  let state: State
  
  public init(state: State) {
    self.state = state
  }
  
  public var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        AppleMapView(coordinate: state.place.shape.centerCoordinate.coordinate2D, span: 150)
          .frame(height: 250)
          .onTapGesture(perform: {})
        ContentCell(
          title: "ID",
          subTitle: state.place.id.string,
          leadingPadding: 24,
          isCopyButtonEnabled: true,
          { str in }
        )
        .padding(.top, 8)
        if let address = state.place.address.anyAddressFullBias?.rawValue {
          ContentCell(
            title: "Location",
            subTitle: address,
            leadingPadding: 24,
            isCopyButtonEnabled: true,
            { str in }
          )
          .padding(.top, 8)
        }
        ForEach(state.place.metadata.sorted(by: { $0.0 < $1.0 }), id: \.key) { name, contents in
          ContentCell(
            title: name.string
              .capitalized
              .replacingOccurrences(of: "_", with: " "),
            subTitle: contents.string,
            leadingPadding: 24,
            isCopyButtonEnabled: true,
            { str in }
          )
        }
        .padding(.top, 8)
        if let entry = state.place.currentlyInside {
          VisitView(
            entry: entry.entry.rawValue,
            exit: nil,
            duration: entry.duration.rawValue
          )
          .padding(.horizontal)
          .padding(.top)
          if let route = entry.route {
            RouteView(
              distance: route.distance.rawValue,
              duration: route.duration.rawValue,
              idleTime: route.idleTime.rawValue
            )
            .padding(.horizontal)
            .padding(.top)
          }
        }
        ForEach(state.place.visits) { visit in
          VisitView(
            entry: visit.entry.rawValue,
            exit: visit.exit.rawValue,
            duration: visit.duration.rawValue
          )
          .padding(.horizontal)
          .padding(.top)
          if let route = visit.route {
            RouteView(
              distance: route.distance.rawValue,
              duration: route.duration.rawValue,
              idleTime: route.idleTime.rawValue
            )
            .padding(.horizontal)
            .padding(.top)
          }
        }
        
        Spacer()
      }
    }
    .navigationBarTitle(Text(state.place.name ?? state.place.fallbackTitle), displayMode: .inline)
  }
}

struct PlaceScreen_Previews: PreviewProvider {
  static var previews: some View {
    PlaceScreen(
      state: .init(
        place: Place(
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
            .init(id: "1", entry: .init(rawValue: Date()), exit: .init(rawValue: Date()), duration: .init(rawValue: 0)),
            .init(id: "2", entry: .init(rawValue: Date()), exit: .init(rawValue: Date()), duration: .init(rawValue: 0))
          ]
        )
      )
    )
    .preferredColorScheme(.dark)
  }
}

struct TimelinePieceView<Content: View>: View {
  private let content: () -> Content
  
  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }
  
  var body: some View {
    ZStack(alignment: .leading) {
      Color(.secondarySystemBackground)
      content()
        .padding()
    }
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }
}

struct VisitView: View {
  let entry: Date
  let exit: Date?
  let duration: UInt
  
  var body: some View {
    TimelinePieceView {
      HStack {
        Image(systemName: "mappin")
          .font(.system(size: 24, weight: .regular))
          .foregroundColor(.accentColor)
          .frame(width: 25, height: 25, alignment: .center)
        VStack(alignment: .leading) {
          Text(entryExitTime(entry: entry, exit: exit))
            .font(.callout)
            .foregroundColor(Color(.label))
          if duration != 0 {
            Text(localizedTime(duration, style: .full))
              .font(.subheadline)
              .foregroundColor(Color(.secondaryLabel))
          }
        }
      }
    }
  }
}

func today(_ date: Date) -> Bool {
  Calendar.current.isDate(date, equalTo: Date(), toGranularity: .day)
}

struct RouteView: View {
  let distance: UInt
  let duration: UInt
  let idleTime: UInt
  
  var body: some View {
    TimelinePieceView {
      HStack {
        Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
          .font(.system(size: 24, weight: .regular))
          .foregroundColor(.accentColor)
          .frame(width: 25, height: 25, alignment: .center)
        
        VStack(alignment: .leading) {
          Text("Traveled\(distance == 0 ? "" : " " + localizedDistance(distance) + " for") \(localizedTime(duration))")
            .font(.callout)
            .foregroundColor(Color(.label))
          if idleTime != 0 {
            Text("Idle for \(localizedTime(idleTime))")
              .font(.callout)
              .foregroundColor(Color(.label))
          }
        }
      }
    }
  }
}

func localizedDistance(_ distanceMeters: UInt) -> String {
  let formatter = MKDistanceFormatter()
  formatter.unitStyle = .default
  return formatter.string(fromDistance: CLLocationDistance(distanceMeters))
}

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

func entryExitTime(entry: Date, exit: Date?) -> String {
  let enteredToday = today(entry)
  let entryDate = DateFormatter.stringDate(entry)
  let entryTime = DateFormatter.stringTime(entry)
  let todayString = "Today"
  let entryOrToday = enteredToday ? todayString : entryDate
  if let exit = exit {
    let exitedToday = today(exit)
    let exitDate = DateFormatter.stringDate(exit)
    let exitTime = DateFormatter.stringTime(exit)
    let exitOrToday = exitedToday ? todayString : exitDate
    let sameDayVisit = Calendar.current.isDate(entry, equalTo: exit, toGranularity: .day)
    return entryOrToday + ", " + entryTime + " - " + (sameDayVisit ? "" : exitOrToday + ", ") + exitTime
  } else {
    return entryOrToday + ", " + entryTime + " - " + "Now"
  }
}

func visitDateTimestamp(entry: Date, exit: Date?) -> String {
  let isTodayEntry = Calendar.current.isDate(entry, equalTo: Date(), toGranularity: .day)
  let stringDateEntry = DateFormatter.stringDate(entry)
  let today = "TODAY"
  let entryOrToday = isTodayEntry ? today : stringDateEntry
  if let exit = exit {
    let isTodayExit = Calendar.current.isDate(exit, equalTo: Date(), toGranularity: .day)
    let stringDateExit = DateFormatter.stringDate(entry)
    let exitOrToday = isTodayExit ? today : stringDateExit
    if isTodayEntry, isTodayExit {
      return today
    } else {
      if Calendar.current.isDate(entry, equalTo:exit, toGranularity: .day) {
        return entryOrToday
      } else {
        return entryOrToday + " - " + exitOrToday
      }
    }
  } else {
    return entryOrToday
  }
}

struct VisitView_Previews: PreviewProvider {
  static var previews: some View {
    VisitView(
      entry: Date() + (-200000),
      exit: Date(),
      duration: 20000
    )
  }
}
