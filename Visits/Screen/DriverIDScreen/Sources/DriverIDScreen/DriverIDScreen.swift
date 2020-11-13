import ComposableArchitecture
import SwiftUI
import Views

public struct DriverIDScreen: View {
  public struct State {
    let driverID: String
    let buttonDisabled: Bool
    
    public init(driverID: String, buttonDisabled: Bool) {
      self.driverID = driverID
      self.buttonDisabled = buttonDisabled
    }
  }
  public enum Action {
    case buttonTapped
    case driverIDChanged(String)
    case nextEnterKeyboardButtonTapped
  }
  
  let store: Store<State, Action>
  
  public init(store: Store<State, Action>) { self.store = store }
  
  public var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Title(title: "Enter your Driver ID")
        TextFieldBlock(
          text: viewStore.binding(
            get: \.driverID,
            send: Action.driverIDChanged
          ),
          name: "Driver ID",
          errorText: "",
          focused: true,
          textContentType: .emailAddress,
          keyboardType: .asciiCapable,
          returnKeyType: .next,
          enterButtonPressed: { viewStore.send(.nextEnterKeyboardButtonTapped) }
        )
        .padding(.top, 50)
        .padding([.trailing, .leading], 16)
        PrimaryButton(
          variant: viewStore.buttonDisabled ? .disabled(title: "Next") : .normal(title: "Next")) {
          viewStore.send(.buttonTapped)
        }
        .disabled(viewStore.buttonDisabled)
        .padding(.top, 39)
        .padding([.trailing, .leading], 58)
        Spacer()
      }
      .modifier(AppBackground())
      .edgesIgnoringSafeArea(.all)
    }
  }
}

extension DriverIDScreen.State: Equatable {}
extension DriverIDScreen.Action: Equatable {}


struct DriverIDScreen_Previews: PreviewProvider {
  static var previews: some View {
    DriverIDScreen(
      store: .init(
        initialState: .init(driverID: "+123456789", buttonDisabled: false),
        reducer: .empty,
        environment: ()
      )
    )
  }
}
