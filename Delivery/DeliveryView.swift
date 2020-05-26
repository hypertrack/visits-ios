import MapKit
import SwiftUI
import Prelude
import Combine
import ViewsComponents
import ComposableArchitecture

public struct DeliveryView: View {
  public struct State: Equatable {
    public let delivery: SingleDelivery
    public let deliveryNote: String
    public let isCompleted: Bool
    public let isDeliveryCompleted: Bool
    public let isNoteFieldFocused: Bool
    public let isVisited: Bool
    public let viewTitle: NonEmptyString
    
    public let isAlertPresent: Bool
    public let alertBody: NonEmptyString
  
    public init(
      delivery: SingleDelivery,
      deliveryNote: String,
      isCompleted: Bool,
      isDeliveryCompleted: Bool,
      isNoteFieldFocused: Bool,
      isVisited: Bool,
      viewTitle: NonEmptyString,
      isAlertPresent: Bool,
      alertBody: NonEmptyString
    ) {
      self.delivery = delivery
      self.deliveryNote = deliveryNote
      self.isCompleted = isCompleted
      self.isDeliveryCompleted = isDeliveryCompleted
      self.isNoteFieldFocused = isNoteFieldFocused
      self.isVisited = isVisited
      self.viewTitle = viewTitle
      self.isAlertPresent = isAlertPresent
      self.alertBody = alertBody
    }
  }
  enum Action {
    case backButtonTapped
    case mapTapped
    case copyTextPressed(String)
    case completeDeliveryButtonTapped
    case noteTapped
    case noteFieldChanged(String)
    case noteEnterKeyboardButtonTapped
    case tappedOutsideFocusedTextField
    case alertСompleted
  }

  let store: Store<DeliveryState, DeliveryAction>
  @ObservedObject var viewStore: ViewStore<DeliveryView.State, DeliveryView.Action>

  public init(store: Store<DeliveryState, DeliveryAction>) {
    self.store = store
    self.viewStore = ViewStore(
      self.store.scope(
        state: State.init(deliveriesState:),
        action: DeliveryAction.init
      )
    )
  }
  
  public var body: some View {
    Navigation(
      title: self.viewStore.viewTitle.rawValue,
      leading: {
        NavigationBackButton { self.viewStore.send(.backButtonTapped) }
      },
      trailing: {
        EmptyView()
      },
      content: {
        ZStack {
          ScrollView {
            VStack(spacing: 0.0) {
              AppleMapView(coordinate: self.viewStore.delivery.coordinate(), span: 150)
                .frame(height: 160)
                .padding(.top, 44)
                .onTapGesture { self.viewStore.send(.mapTapped) }
              if self.viewStore.isVisited {
                NotificationView(text: "Visited: 10:38AM - 10:46AM",state: .onVisited)
              } else if self.viewStore.isCompleted {
                NotificationView(text: "Completed",state: .onCompleted)
              }
              ContentTextField(
                placeholder: "Delivery note",
                text: self.viewStore.binding(
                  get: \.deliveryNote,
                  send: { .noteFieldChanged($0) }
                ),
                isFocused: self.viewStore.isNoteFieldFocused,
                enablesReturnKeyAutomatically: true,
                errorText: "",
                textContentType: .emailAddress,
                keyboardType: .default,
                returnKeyType: .send,
                wantsToBecomeFocused: { self.viewStore.send(.noteTapped) },
                onEnterButtonPressed: { self.viewStore.send(.noteEnterKeyboardButtonTapped) }
              )
              .padding([.top, .trailing, .leading], 16)
              ContentCell(title: "Location", subTitle: self.viewStore.delivery.fullAddress, leadingPadding: 16) {
                self.viewStore.send(.copyTextPressed($0))
              }
              ForEach(self.viewStore.delivery.metadata, id: \.self) {
                ContentCell(title: $0.key, subTitle: $0.value, leadingPadding: 16) {
                  self.viewStore.send(.copyTextPressed($0))
                }
              }.padding(.top, 8)
            }
          }
          .frame(maxWidth: .infinity)
          RaundedStack(isVisible: !self.viewStore.isDeliveryCompleted) {
            PrimaryButton(
              state: .normal,
              isActivityVisible: false,
              title: "Complete delivery"
            ) { self.viewStore.send(.completeDeliveryButtonTapped) }
              .padding([.trailing, .leading], 58)
          }
          if self.viewStore.isAlertPresent {
            DoneAlert(
              title: self.viewStore.alertBody,
              visibilityInterval: 1.0,
              shows: self.viewStore.binding(
                get: \.isAlertPresent,
                send: { _ in .alertСompleted }
            ))
          }
        }
        .modifier(AppBackground())
        .edgesIgnoringSafeArea(.bottom)
        .onTapGesture {
          if self.viewStore.isNoteFieldFocused {
            self.viewStore.send(.tappedOutsideFocusedTextField)
          }
        }
    })
  }
}

extension DeliveryView.State {
  init(deliveriesState: DeliveryState) {
    self.delivery = deliveriesState.delivery
    self.viewTitle = deliveriesState.delivery.shortAddress.isEmpty ? NonEmptyString(stringLiteral: "Delivery") : NonEmptyString(stringLiteral: deliveriesState.delivery.shortAddress)
    self.deliveryNote = deliveriesState.deliveryNote
    self.isNoteFieldFocused = deliveriesState.isNoteFieldFocused
    self.isDeliveryCompleted = deliveriesState.isDeliveryCompleted
    self.isVisited = false
    self.isCompleted = deliveriesState.isDeliveryCompleted
    
    switch deliveriesState.alertContent {
    case .completedDelivery: self.isAlertPresent = true
    case .metadataSent: self.isAlertPresent = true
    case .copy: self.isAlertPresent = true
    case .none: self.isAlertPresent = false
    }
    
    self.alertBody = NonEmptyString(stringLiteral: deliveriesState.alertContent.rawValue)
    print("self.isAlertPresent \(self.isAlertPresent)")
  }
}

extension DeliveryAction {
  init(action: DeliveryView.Action) {
    switch action {
    case .backButtonTapped:
      self = .deselectDelivery
    case .mapTapped:
      self = .openAppleMaps
    case let .copyTextPressed(text):
      self = .copyDeliverySection(text)
    case .completeDeliveryButtonTapped:
      self = .completeDelivery
    case .noteTapped:
      self = .focusDeliveryNote
    case let .noteFieldChanged(note):
      self = .changeDeliveryNote(note)
    case .noteEnterKeyboardButtonTapped:
      self = .sendDeliveryNote
    case .tappedOutsideFocusedTextField:
      self = .unfocusDeliveryNote
    case .alertСompleted:
      self = .alertPresentingFinished
    }
  }
}

struct DeliveryView_Previews: PreviewProvider {
  static var previews: some View {
    let delivery = SingleDelivery(
      id: "2c1f2901-c5a5-43f6-a29e-33e58ca9a19e",
      lat: 48.230319,
      lng: 16.376480,
      shortAddress: "Rauscherstraße 5",
      fullAddress: "Rauscherstraße 5, 1200 Wien, Австрия",
      metadata: [SingleDelivery.Metadata(key: "testKey", value: "testValue")]
    )
    return Group {
      DeliveryView(store: Store<DeliveryState, DeliveryAction>(
        initialState: DeliveryState.initialState(publishableKey: "Test_publishableKey", delivery: delivery, isDeliveryCompleted: false, alertContent: .none),
        reducer: deliveryReducer,
        environment: SystemEnvironment<DeliveryEnvironment>.live(environment: Delivery.live)
      )).environment(\.colorScheme, .dark)
      DeliveryView(store: Store<DeliveryState, DeliveryAction>(
        initialState: DeliveryState.initialState(publishableKey: "Test_publishableKey", delivery: delivery, isDeliveryCompleted: false, alertContent: .none),
        reducer: deliveryReducer,
        environment: SystemEnvironment<DeliveryEnvironment>.live(environment: Delivery.live)
      )).environment(\.colorScheme, .light)
    }
  }
}
