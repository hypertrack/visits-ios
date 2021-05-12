import ComposableArchitecture
import SwiftUI
import Types
import Views

public struct DriverIDScreen: View {
  public enum Action {
    case buttonTapped
    case driverIDChanged(String)
    case nextEnterKeyboardButtonTapped
  }
  
  let state: DriverIDState.Status
  let send: (Action) -> Void
  
  public init(
    state: DriverIDState.Status,
    send: @escaping (Action) -> Void
  ) {
    self.state = state
    self.send = send
  }
  
  var buttonDisabled: Bool {
    switch state {
    case .entering(.none), .entered: return true
    case .entering(.some):           return false
    }
  }
  
  var driverID: String {
    switch state {
    case     .entering(.none): return ""
    case let .entering(.some(drID)),
         let .entered(drID):   return drID.string
    }
  }
  
  public var body: some View {
    VStack {
      Title(title: "Enter your Driver ID")
      TextFieldBlock(
        text: Binding(
          get: { driverID },
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
        variant: buttonDisabled ? .disabled(title: "Next") : .normal(title: "Next")) {
        send(.buttonTapped)
      }
      .disabled(buttonDisabled)
      .padding(.top, 39)
      .padding([.trailing, .leading], 58)
      Spacer()
    }
    .modifier(AppBackground())
    .edgesIgnoringSafeArea(.all)
  }
}

extension DriverIDScreen.Action: Equatable {}


struct DriverIDScreen_Previews: PreviewProvider {
  static var previews: some View {
    DriverIDScreen(
      state: .entered("+123456789"),
      send: { _ in }
    )
  }
}
