import ComposableArchitecture
import SwiftUI
import Types
import Views


struct ChoosingCompanyView: View {
  struct State: Equatable {
    var search: IntegrationEntity.Search
    var integrationEntities: [IntegrationEntity]
    var refreshing: Bool
  }
  
  public enum Action: Equatable {
    case cancelChoosingCompany
    case updateIntegrationsSearch(IntegrationEntity.Search)
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
