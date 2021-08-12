import ComposableArchitecture
import SwiftUI
import Types


struct ChoosingCompanyView: View {
  struct State: Equatable {
    var search: IntegrationSearch
    var integrationEntities: [IntegrationEntity]
    var refreshing: Bool
  }
  
  enum Action: Equatable {
    case cancelChoosingCompany
    case updateIntegrationsSearch(IntegrationSearch)
    case searchForIntegrations
    case selectedIntegration(IntegrationEntity)
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
              title: "Choose Company",
              backAction: { viewStore.send(.cancelChoosingCompany) },
              refreshing: viewStore.refreshing
            )
            SearchBar(
              placeholder: "Enter company name",
              text: .init(
                get: {
                  viewStore.search.rawValue
                },
                set: { str in
                  viewStore.send(.updateIntegrationsSearch(.init(rawValue: str)))
                }
              ),
              geometry: geometry,
              tapSearchBar: {},
              enterButtonPressed: { viewStore.send(.searchForIntegrations) },
              active: true
            )
          }
          List {
            ForEach(viewStore.integrationEntities, id: \.id) { ie in
              Button {
                viewStore.send(.selectedIntegration(ie))
              } label: {
                IntegrationEntityView(integrationEntity: ie)
              }
            }
          }
        }
        .edgesIgnoringSafeArea(.top)
      }
    }
  }
}
