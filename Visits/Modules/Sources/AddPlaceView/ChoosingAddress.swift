import ComposableArchitecture
import NonEmpty
import SwiftUI
import Types
import Views


struct ChoosingAddressView: View {
  struct State: Equatable {
    var search: Street?
    var searchResults: [LocalSearchCompletion]
    var selectedResult: LocalSearchCompletion?
  }
  enum Action {
    case cancelChoosingAddress
    case searchPlaceOnMap
    case selectAddress(LocalSearchCompletion)
    case updateAddressSearch(Street?)
  }
  
  let store: Store<State, Action>
  init(store: Store<State, Action>) { self.store = store }
  
  var body: some View {
    GeometryReader { geometry in
      WithViewStore(store) { viewStore in
        VStack(spacing: 0) {
          VStack(spacing: 0) {
            TopPadding(geometry: geometry)
            Header(
              title: "Add place",
              backAction: { viewStore.send(.cancelChoosingAddress) }
            )
            SearchBar(
              placeholder: "Search address",
              text: .init(
                get: {
                  viewStore.search?.string ?? ""
                },
                set: { str in
                  viewStore.send(.updateAddressSearch(NonEmptyString(rawValue: str).map(Street.init(rawValue:))))
                }
              ),
              geometry: geometry,
              tapSearchBar: {},
              active: true
            )
          }
          .background(Color(.systemBackground))
          .clipped()
          .shadow(radius: 5)
          List {
            ForEach(viewStore.searchResults, id: \.hashValue) { ls in
              Address(
                address: ls,
                processing: ls == viewStore.selectedResult,
                selected: { viewStore.send(.selectAddress($0)) }
              )
              .padding([.vertical])
            }
            Button {
              viewStore.send(.searchPlaceOnMap)
            } label: {
              SetOnMap()
            }
          }
        }
        .edgesIgnoringSafeArea(.top)
      }
    }
  }
}

struct SetOnMap: View {
  var body: some View {
    HStack {
     Spacer()
      Image(systemName: "mappin")
        .font(.footnote.weight(.semibold))
        .foregroundColor(.accentColor)
        .padding(.trailing, 10)
      Text("Set on map")
        .font(.footnote.weight(.semibold))
        .foregroundColor(Color(.secondaryLabel))
      Spacer()
    }
  }
}

struct Address: View {
  var address: LocalSearchCompletion
  var processing: Bool
  var selected: (LocalSearchCompletion) -> Void
  
  @ViewBuilder var imageOrProcessing: some View {
    if processing {
      ProgressView()
        .progressViewStyle(CircularProgressViewStyle())
    } else {
      Image(systemName: "mappin.circle")
        .font(.title)
        .foregroundColor(.accentColor)
    }
  }
  
  var body: some View {
    Button {
      selected(address)
    } label: {
      HStack {
        imageOrProcessing
          .frame(width: 20, height: 20, alignment: .center)
          .padding(.trailing, 10)
        VStack {
          PrimaryRow(address.title.string)
            .padding(.bottom, -3)
          if let subtitle = address.subtitle {
            SecondaryRow(subtitle.string)
          }
        }
      }
    }
  }
}

