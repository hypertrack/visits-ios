import ComposableArchitecture
import MapKit
import SwiftUI
import Types
import Utility
import Views


public struct AddPlaceView: View {
  public struct State: Equatable {
    public var flow: AddPlaceFlow
    
    public init(flow: AddPlaceFlow) { self.flow = flow }
  }
  
  public enum Action: Equatable {
    case cancelAddPlace
    case cancelChoosingCompany
    case updatedAddPlaceCoordinate(Coordinate)
    case confirmAddPlaceCoordinate
    case updateIntegrationsSearch(Search)
    case searchForIntegrations
    case selectedIntegration(IntegrationEntity)
  }
  
  let store: Store<State, Action>
  public init(store: Store<State, Action>) { self.store = store }
  
  public var body: some View {
    WithViewStore(store) { viewStore in
      switch viewStore.flow {
      case let .choosingCoordinate(c, _):
        ChoosingCoordinateView(
          store: store.scope(
            state: constant(.init(coordinate: c)),
            action: { a in
              switch a {
              case     .cancelAddPlace:               return .cancelAddPlace
              case let .updatedAddPlaceCoordinate(c): return .updatedAddPlaceCoordinate(c)
              case     .confirmAddPlaceCoordinate:    return .confirmAddPlaceCoordinate
              }
            }
          )
        )
      case let .choosingIntegration(_, s, r, ies):
        ChoosingCompanyView(
          store: store.scope(
            state: { _ in
              .init(search: s, integrationEntities: ies, refreshing: r == .refreshing)
            },
            action: { a in
              switch a {
              case     .cancelChoosingCompany:       return .cancelChoosingCompany
              case let .updateIntegrationsSearch(s): return .updateIntegrationsSearch(s)
              case     .searchForIntegrations:       return .searchForIntegrations
              case let .selectedIntegration(ie):     return .selectedIntegration(ie)
              }
            }
          )
        )
      case let .addingPlace(c, ie, _, _):
        VStack(spacing: 0) {
          AppleMapView(coordinate: c.coordinate2D, span: 150)
            .frame(height: 250)
          ContentCell(
            title: "Company",
            subTitle: ie.name.string,
            leadingPadding: 24,
            isCopyButtonEnabled: true,
            { str in }
          )
          .padding(.top, 8)
          Spacer()
          ProgressView("Creating Place")
            .padding()
          Spacer()
        }
        .edgesIgnoringSafeArea(.top)
      }
    }
  }
}

private struct ChoosingCompanyView: View {
  struct State: Equatable {
    var search: Search
    var integrationEntities: [IntegrationEntity]
    var refreshing: Bool
  }
  
  public enum Action: Equatable {
    case cancelChoosingCompany
    case updateIntegrationsSearch(Search)
    case searchForIntegrations
    case selectedIntegration(IntegrationEntity)
  }
  
  let store: Store<State, Action>
  public init(store: Store<State, Action>) { self.store = store }
  
  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationView {
        IntegrationListView(
          store: store.scope(
            state: { s in
              .init(search: viewStore.search, integrationEntities: viewStore.integrationEntities)
            },
            action: { a in
              switch a {
              case let .updateIntegrationsSearch(s): return .updateIntegrationsSearch(s)
              case     .searchForIntegrations:       return .searchForIntegrations
              case let .selectedIntegration(ie):     return .selectedIntegration(ie)
              }
            }
          )
        )
        .toolbar {
          ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { viewStore.send(.cancelChoosingCompany) }) {
              Image(systemName: "arrow.backward")
            }
          }
        }
        .if(viewStore.refreshing) { view in
          view.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
              RefreshButton(state: .refreshing) {}
            }
          }
        }
      }
    }
  }
}

private struct IntegrationListView: View {
  struct State: Equatable {
    var search: Search
    var integrationEntities: [IntegrationEntity]
  }
  
  public enum Action: Equatable {
    case updateIntegrationsSearch(Search)
    case searchForIntegrations
    case selectedIntegration(IntegrationEntity)
  }
  
  let store: Store<State, Action>
  public init(store: Store<State, Action>) { self.store = store }
  
//  @State private var username: String = ""
//  @State private var isEditing = false
//  @State private var commited = false
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        TextField(
          "Enter company name",
          text: .init(
            get: {
              viewStore.search.rawValue
            },
            set: { s in
              viewStore.send(.updateIntegrationsSearch(.init(rawValue: s)))
            }
          )
        ) { isEditing in
          
        } onCommit: {
          viewStore.send(.searchForIntegrations)
        }
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .padding()
        List {
          ForEach(viewStore.integrationEntities, id: \.id) { ie in
            Button(action: { viewStore.send(.selectedIntegration(ie)) }) {
              IntegrationEntityView(integrationEntity: ie)
            }
          }
        }
      }
      .navigationBarTitle(Text("Attach Company"), displayMode: .inline)
    }
  }
}

struct IntegrationEntityView: View {
  let integrationEntity: IntegrationEntity

  var body: some View {
    HStack {
      Image(systemName: "building.2.crop.circle")
        .font(.title)
        .foregroundColor(.accentColor)
        .padding(.trailing, 10)
      PrimaryRow(
        integrationEntity.name.string
      )
    }
    .padding(.vertical, 10)  }
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

private struct ChoosingCoordinateView: View {
  struct State: Equatable {
    var coordinate: Coordinate?
  }
  enum Action {
    case cancelAddPlace
    case updatedAddPlaceCoordinate(Coordinate)
    case confirmAddPlaceCoordinate
  }
  
  
  let store: Store<State, Action>
  init(store: Store<State, Action>) { self.store = store }
  
  var body: some View {
    GeometryReader { geometry in
      WithViewStore(store) { viewStore in
        ZStack {
          PlaceMapView(
            inputCoordinateForSearch: .init(
              get: {
                viewStore.coordinate?.coordinate2D
              },
              set: {
                if let c = $0 {
                  viewStore.send(.updatedAddPlaceCoordinate(Coordinate(coordinate2D: c)!))
                }
              }
            )
          )
          HStack {
            VStack {
              Button(action: { viewStore.send(.cancelAddPlace) }) {
                Image(systemName: "arrow.backward")
              }
              .foregroundColor(.accentColor)
              .frame(width: 40, height: 40)
              .background(Color(.systemBackground))
              .clipShape(RoundedRectangle(cornerRadius: 8))
              .padding(.leading, 16)
              .padding(.top, 48)
              Spacer()
            }
            Spacer()
          }
          VStack {
            Spacer()
            PrimaryButton(variant: .normal(title: "Confirm")) {
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
