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
  
  let state: State
  let send: (Action) -> Void
  
  public init(
    state: State,
    send: @escaping (Action) -> Void
  ) {
    self.state = state
    self.send = send
  }
  
  public var body: some View {
    VStack {
      Title(title: "Enter your Driver ID")
      TextFieldBlock(
        text: Binding(
          get: { state.driverID },
          set: { send(.driverIDChanged($0)) }
        ),
        name: "Driver ID",
        errorText: "",
        focused: true,
        textContentType: .nickname,
        keyboardType: .asciiCapable,
        returnKeyType: .next,
        enterButtonPressed: { send(.nextEnterKeyboardButtonTapped) }
      )
      .padding(.top, 50)
      .padding([.trailing, .leading], 16)
      PrimaryButton(
        variant: state.buttonDisabled ? .disabled(title: "Next") : .normal(title: "Next")) {
        send(.buttonTapped)
      }
      .disabled(state.buttonDisabled)
      .padding(.top, 39)
      .padding([.trailing, .leading], 58)
      Spacer()
    }
    .modifier(AppBackground())
    .edgesIgnoringSafeArea(.all)
  }
}

extension DriverIDScreen.State: Equatable {}
extension DriverIDScreen.Action: Equatable {}


struct DriverIDScreen_Previews: PreviewProvider {
  static var previews: some View {
    DriverIDScreen(
      state: .init(driverID: "+123456789", buttonDisabled: false),
      send: { _ in }
    )
  }
}
