import NonEmpty
import SwiftUI
import Types
import Views


public struct PlacesScreen: View {
  public struct State {
    let places: Set<Place>
    let selected: Place?
    let refreshing: Bool
    let integrationStatus: IntegrationStatus
    let coordinates: [Coordinate]
    
    var currentLocation: Coordinate? { coordinates.last }
    
    public init(places: Set<Place>, selected: Place? = nil, refreshing: Bool, integrationStatus: IntegrationStatus, coordinates: [Coordinate] = []) {
      self.places = places
      self.selected = selected
      self.refreshing = refreshing
      self.integrationStatus = integrationStatus
      self.coordinates = coordinates
    }
  }
  public enum Action {
    case refresh
    case addPlace
    case copyToPasteboard(NonEmptyString)
    case selectPlace(Place?)
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
      PlacesList(
        placesToDisplay: state.placesToDisplay,
        selected: state.selected,
        select: { send(.selectPlace($0)) },
        copy: { send(.copyToPasteboard($0)) }
      )
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
    .navigationViewStyle(StackNavigationViewStyle())
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
            currentlyInside: .init(id: "1", entry: .init(rawValue: ISO8601DateFormatter().date(from: "2020-04-01T19:27:00Z")!), duration: 0),
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
