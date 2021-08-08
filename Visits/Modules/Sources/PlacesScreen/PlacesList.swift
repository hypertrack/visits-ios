import NonEmpty
import SwiftUI
import Types


struct PlacesList: View {
  let placesToDisplay: [PlacesSection]
  let selected: Place?
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
