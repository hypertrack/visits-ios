import ComposableArchitecture
import SwiftUI
import Types
import Views


struct ChoosingCoordinateView: View {
  struct State: Equatable {
    var geocoded: GeocodedResult?
    var places: Set<Place>
  }
  enum Action {
    case cancelAddPlace
    case confirmAddPlaceCoordinate
    case liftedAddPlaceCoordinatePin
    case searchPlaceByAddress
    case selectedPlace(Place)
    case updatedAddPlaceCoordinate(Coordinate)
  }
  
  
  let store: Store<State, Action>
  init(store: Store<State, Action>) { self.store = store }
  
  var body: some View {
    GeometryReader { geometry in
      WithViewStore(store) { viewStore in
        ZStack {
          VStack(spacing: 0) {
            VStack(spacing: 0) {
              TopPadding(geometry: geometry)
              Header(
                title: "Add place",
                backAction: { viewStore.send(.cancelAddPlace) },
                refreshing: false
              )
              SearchBar(
                placeholder: viewStore.geocoded?.address.street?.string ?? "Search address",
                text: .constant(""),
                geometry: geometry,
                tapSearchBar: { viewStore.send(.searchPlaceByAddress) },
                enterButtonPressed: {},
                active: false
              )
            }
            .background(Color(.systemBackground))
            .clipped()
            .shadow(radius: 5)
            PlaceMapView(
              inputCoordinateForSearch: .init(
                get: {
                  viewStore.geocoded?.coordinate.coordinate2D
                },
                set: {
                  if let c = $0 {
                    viewStore.send(.updatedAddPlaceCoordinate(Coordinate(coordinate2D: c)!))
                  }
                }
              ),
              places: viewStore.places,
              sendSelectedPlace: {
                viewStore.send(.selectedPlace($0))
              },
              sendLiftedPin: {
                viewStore.send(.liftedAddPlaceCoordinatePin)
              }
            )
          }
          VStack {
            Spacer()
            PrimaryButton(
              variant: viewStore.geocoded?.coordinate != nil ? .normal(title: "Confirm") : .disabled(title: "Confirm"),
              isHovering: true
            ) {
              viewStore.send(.confirmAddPlaceCoordinate)
            }
            .padding([.trailing, .leading], 64)
            .padding(
              .bottom,
              geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets
                .bottom : 24
            )
          }
        }
        .edgesIgnoringSafeArea(.all)
      }
    }
  }
}

struct ChoosingCoordinateView_Previews: PreviewProvider {
  static var previews: some View {
    ChoosingCoordinateView(
      store: .init(
        initialState: .init(
          geocoded: nil,
          places: []
        ),
        reducer: .empty,
        environment: ())
    )
  }
}


struct BackButton: View {
  let action: () -> Void
  var body: some View {
    Button(action: action) {
      Image(systemName: "arrow.backward")
        .padding(.leading, 16)
    }
  }
}

struct Title: View {
  private let text: String
  init(_ text: String) {
    self.text = text
  }
  
  var body: some View {
    Text(text)
      .font(.title2)
      .foregroundColor(Color(.label))
  }
}

struct TopPadding: View {
  let geometry: GeometryProxy
  
  var body: some View {
    Rectangle()
      .fill(Color.clear)
      .frame(
        height: geometry.safeAreaInsets.top > 0 ? geometry
          .safeAreaInsets.top : 20
      )
  }
}

struct SearchBar: View {
  let placeholder: String
  let text: Binding<String>
  let geometry: GeometryProxy
  let tapSearchBar: () -> Void
  let enterButtonPressed: () -> Void
  let active: Bool
  
  var body: some View {
    HStack {
      ZStack {
        HStack {
          TextOrTextField(
            placeholder: placeholder,
            text: text,
            isTextField: active,
            enterButtonPressed: enterButtonPressed
          )
            .frame(
              width: geometry.size.width - 126,
              height: 20,
              alignment: .leading
            )
            .font(Font.system(size: 14).weight(.medium))
            .padding(.trailing, 16)
          Image(systemName: "magnifyingglass")
            .foregroundColor(Color(.secondaryLabel))
        }
        if !active {
          Button(action: tapSearchBar) {
            Rectangle()
              .fill(Color(.secondarySystemFill))
              .opacity(0.1)
          }
          .background(Color.clear)
        }
      }
      .frame(width: geometry.size.width - 32, height: 44)
      .background(Color(.systemFill))
      .cornerRadius(22)
    }
    .padding([.top, .bottom], 16)
  }
}

struct TextOrTextField: View {
  let placeholder: String
  let text: Binding<String>
  let isTextField: Bool
  let enterButtonPressed: () -> Void
  
  var body: some View {
    if isTextField {
      CustomTextField(
        text: text,
        focused: true,
        textContentType: .fullStreetAddress,
        keyboardType: .default,
        returnKeyType: .search,
        enablesReturnKeyAutomatically: true,
        isSecureTextEntry: false,
        wantsToBecomeFocused: {},
        enterButtonPressed: enterButtonPressed
      )
    } else {
      Text(placeholder)
    }
  }
}

struct Header: View {
  let title: String
  let backAction: () -> Void
  let refreshing: Bool
  
  var body: some View {
    ZStack {
      HStack {
        BackButton(action: backAction)
        Spacer()
        if refreshing {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .padding()
        }
      }
      Title(title)
    }
    .frame(height: 24)
    .padding(.top, 8)
  }
}
