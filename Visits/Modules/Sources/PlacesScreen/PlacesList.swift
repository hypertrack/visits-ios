import NonEmpty
import SwiftUI
import Types


struct PlacesList: View {
  let placesToDisplay: [PlacesSection]
  let visitsToDisplay: [VisitsSection]
  let selected: Place?
  let presentation: PlacesPresentation
  let select: (Place?) -> Void
  let copy: (NonEmptyString) -> Void
  let mapTapped: (Coordinate, Address) -> Void
  
  var navigationLink: NavigationLink<EmptyView, PlaceScreen>? {
    guard let place = selected  else { return nil }
    
    return NavigationLink(
      destination: PlaceScreen(
        state: .init(place: place),
        copy: copy,
        mapTapped: mapTapped
      ),
      tag:  place,
      selection: .init(
        get: { selected },
        set: { select($0) }
      )
    ) {
      EmptyView()
    }
  }
  
  var body: some View {
    ZStack {
      navigationLink
      List {
        if presentation == .byPlace {
          ForEach(placesToDisplay, id: \.header) { section in
            Section(header: Text(section.header).font(.subheadline)) {
              ForEach(section.places, id: \.place.id) { placeAndTime in
                Button {
                  select(placeAndTime.place)
                } label: {
                  PlaceView(placeAndTime: placeAndTime)
                }
              }
            }
          }
        } else {
          ForEach(visitsToDisplay, id: \.header.date) { section in
            Section(
              header: HStack {
                Text(Calendar.current.isDate(section.header.date, equalTo: Date(), toGranularity: .day) ? "TODAY" : DateFormatter.stringDate(section.header.date))
                Spacer()
                Text(section.header.distance == 0 ? "" : localizedDistance(section.header.distance))
              }
            ) {
              ForEach(section.visits, id: \.entryOrVisit.id) { visit in
                Button {
                  select(visit.place)
                } label: {
                  VisitItemView(item: visit, copy: copy)
                }
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

struct VisitItemView: View {
  let item: VisitItem
  let copy: (NonEmptyString) -> Void

  var body: some View {
    VStack {
      PlaceView(
        placeAndTime: .init(
          place: item.place,
          time: nil
        ),
        showNumberOfVisits: false
      )
      switch item.entryOrVisit {
      case let .entry(entry):
        VisitView(
          id: entry.id.rawValue,
          entry: entry.entry.rawValue,
          exit: nil,
          duration: safeAbsoluteDuration(from: entry.entry.rawValue, to: Date()),
          copy: copy
        )
        .padding()
        if let route = entry.route {
          RouteView(
            distance: route.distance.rawValue,
            duration: route.duration.rawValue,
            idleTime: route.idleTime.rawValue
          )
          .padding(.horizontal)
          .padding(.bottom)
        }
      case let .visit(visit):
        VisitView(
          id: visit.id.rawValue,
          entry: visit.entry.rawValue,
          exit: visit.exit.rawValue,
          duration: safeAbsoluteDuration(from: visit.entry.rawValue, to: visit.exit.rawValue),
          copy: copy
        )
        .padding()
        if let route = visit.route {
          RouteView(
            distance: route.distance.rawValue,
            duration: route.duration.rawValue,
            idleTime: route.idleTime.rawValue
          )
          .padding(.horizontal)
          .padding(.bottom)
        }
      }
    }
  }
}
