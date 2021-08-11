import ComposableArchitecture
import SwiftUI
import Types


struct IntegrationListView: View {
  struct State: Equatable {
    var search: IntegrationEntity.Search
    var integrationEntities: [IntegrationEntity]
  }
  
  public enum Action: Equatable {
    case updateIntegrationsSearch(IntegrationEntity.Search)
    case searchForIntegrations
    case selectedIntegration(IntegrationEntity)
  }
  
  let store: Store<State, Action>
  public init(store: Store<State, Action>) { self.store = store }
  
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
