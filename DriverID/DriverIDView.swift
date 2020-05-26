import ComposableArchitecture
import SwiftUI
import ViewsComponents

public struct DriverIDView: View {
  struct State: Equatable {
    let driverIDTextFieldValue: String
    let driverIDTextFieldDisabled: Bool
    let nextButtonDisabled: Bool
    let nextButtonInProgress: Bool
  }
  enum Action {
    case driverIDFieldChanged(String)
    case nextButtonTapped
    case nextEnterKeyboardButtonTapped
  }
  let store: Store<DriverIDState, DriverIDAction>
  @ObservedObject private var viewStore: ViewStore<DriverIDView.State, DriverIDView.Action>
  
  public init(store: Store<DriverIDState, DriverIDAction>) {
    self.store = store
    self.viewStore = ViewStore(
      self.store.scope(
        state: State.init(driverIDState:),
        action: DriverIDAction.init
      )
    )
  }
  
  public var body: some View {
    VStack {
      TitleView(title: "Enter your Driver ID")
      PrimaryTextField(
        placeholder: "Driver ID",
        text: viewStore.binding(
          get: \.driverIDTextFieldValue,
          send: { .driverIDFieldChanged($0) }
        ),
        isFocused: true,
        errorText: "",
        textContentType: .emailAddress,
        keyboardType: .asciiCapable,
        returnKeyType: .next,
        onEnterButtonPressed: { self.viewStore.send(.nextButtonTapped) }
      )
        .disabled(viewStore.driverIDTextFieldDisabled)
        .padding(.top, 50)
        .padding([.trailing, .leading], 16)
      PrimaryButton(
        state: viewStore.nextButtonDisabled ? .disabled : .normal,
        isActivityVisible: viewStore.nextButtonInProgress,
        title: "Next"
      ) { self.viewStore.send(.nextButtonTapped) }
        .padding(.top, 39)
        .padding([.trailing, .leading], 58)
      Spacer()
    }
    .modifier(AppBackground())
    .edgesIgnoringSafeArea(.all)
  }
}

extension DriverIDView.State {
  init(driverIDState: DriverIDState) {
    switch driverIDState {
    case let .ready(ready):
      self.driverIDTextFieldValue = ready.driverID.rawValue
      self.driverIDTextFieldDisabled = ready.inProgress
      self.nextButtonDisabled = ready.inProgress
      self.nextButtonInProgress = ready.inProgress
    case .empty:
      self.driverIDTextFieldValue = ""
      self.driverIDTextFieldDisabled = false
      self.nextButtonDisabled = true
      self.nextButtonInProgress = false
    }
  }
}

extension DriverIDAction {
  init(action: DriverIDView.Action) {
    switch action {
    case let .driverIDFieldChanged(driverID):
      self = .driverIDChanged(driverID)
    case .nextButtonTapped, .nextEnterKeyboardButtonTapped:
      self = .tryToRegister
    }
  }
}


struct DriverIDView_Previews: PreviewProvider {
  static var previews: some View {
    DriverIDView(
      store: Store<DriverIDState, DriverIDAction>(
        initialState: DriverIDState.initialState,
        reducer: driverIDReducer,
        environment: ()
      )
    )
  }
}
