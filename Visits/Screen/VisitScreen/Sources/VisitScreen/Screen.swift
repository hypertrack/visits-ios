import ComposableArchitecture
import Coordinate
import NonEmpty
import SwiftUI
import Views


public struct VisitScreen: View {
  public struct State: Equatable {
    
    public var title: String
    public var visitNote: String
    public var noteFieldFocused: Bool
    public var visitType: VisitType
    public var deviceID: String
    public var publishableKey: String
    
    public struct Metadata: Hashable {
      public let key: String
      public let value: String
      
      public init(key: String, value: String) {
        self.key = key
        self.value = value
      }
    }
    
    public enum VisitType: Equatable {
      
      public enum ManualVisitStatus: Equatable {
        case notSent, checkedIn, checkedOut(String)
      }
      
      public enum AssignedVisitStatus: Equatable {
        case notSent, pickedUp, checkedIn, checkedOut(String), canceled
      }
      
      case manualVisit(status: ManualVisitStatus)
      case assignedVisit(
            coordinate: Coordinate,
            address: String,
            metadata: [Metadata],
            status: AssignedVisitStatus
           )
    }
    
    public var finished: Bool {
      switch visitType {
      case .manualVisit(.checkedOut),
           .assignedVisit(_, _, _, .checkedOut),
           .assignedVisit(_, _, _, .canceled):
        return true
      default:
        return false
      }
    }
    
    public init(
      title: String,
      visitNote: String,
      noteFieldFocused: Bool,
      visitType: VisitScreen.State.VisitType,
      deviceID: String,
      publishableKey: String
    ) {
      self.title = title
      self.visitNote = visitNote
      self.noteFieldFocused = noteFieldFocused
      self.visitType = visitType
      self.deviceID = deviceID
      self.publishableKey = publishableKey
    }
  }
  
  public enum Action: Equatable {
    case backButtonTapped
    case cancelButtonTapped
    case checkInButtonTapped
    case checkOutButtonTapped
    case copyTextPressed(NonEmptyString)
    case mapTapped
    case noteEnterKeyboardButtonTapped
    case noteFieldChanged(String)
    case noteTapped
    case pickedUpButtonTapped
    case tappedOutsideFocusedTextField
  }
  
  @Environment(\.colorScheme) var colorScheme
  @GestureState private var dragOffset = CGSize.zero
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
    Navigation(
      title: state.title,
      leading: {
        if state.visitType == .manualVisit(status: .notSent) {
          CancelButton { send(.backButtonTapped) }
        } else if state.visitType == .manualVisit(status: .checkedIn) {
          EmptyView()
        } else {
          BackButton { send(.backButtonTapped) }
        }
      },
      trailing: { EmptyView() }
    ) {
      ZStack {
        VisitInformationView(
          visitType: state.visitType,
          showButtons: !state.finished,
          visitNote: state.visitNote,
          deleveryNoteBinding: Binding(
            get: { state.visitNote },
            set: { send(.noteFieldChanged($0)) }
          ),
          noteFieldFocused: state.noteFieldFocused,
          visitNoteWantsToBecomeFocused: { send(.noteTapped) },
          visitNoteEnterButtonPressed: { send(.noteEnterKeyboardButtonTapped) },
          mapTapped: { send(.mapTapped) },
          copyTextPressed: {
            if let na = NonEmptyString(rawValue: $0) {
              send(.copyTextPressed(na))
            }
          }
        )
        VisitButtonView(
          visitType: state.visitType,
          cancelButtonTapped: { send(.cancelButtonTapped) },
          checkInButtonTapped: { send(.checkInButtonTapped) },
          checkOutButtonTapped: { send(.checkOutButtonTapped) },
          pickedUpButtonTapped: { send(.pickedUpButtonTapped) }
        )
      }
      .modifier(AppBackground())
      .edgesIgnoringSafeArea(.bottom)
      .onTapGesture {
        if state.noteFieldFocused {
          send(.tappedOutsideFocusedTextField)
        }
      }
      .gesture(
        DragGesture()
          .updating(
            $dragOffset,
            body: { value, state, transaction in
              if(value.startLocation.x < 20 && value.translation.width > 100) {
                if self.state.visitType != .manualVisit(status: .checkedIn) {
                  send(.backButtonTapped)
                }
              }
            }
          )
      )
    }
  }
}

struct VisitInformationView: View {
  let visitType: VisitScreen.State.VisitType
  let showButtons: Bool
  let visitNote: String
  @Binding var deleveryNoteBinding: String
  let noteFieldFocused: Bool
  let visitNoteWantsToBecomeFocused: () -> Void
  let visitNoteEnterButtonPressed: () -> Void
  let mapTapped: () -> Void
  let copyTextPressed: (String) -> Void
  
  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        switch visitType {
        case .manualVisit(.notSent):
          CustomText(text: "Pressing the Check In button will start a new visit. Visits not completed after 24 hours will be removed automatically.")
            .defaultTextColor()
            .padding(.top, 44 + 16)
            .padding([.trailing, .leading], 8)
        case .manualVisit(.checkedIn):
          TextFieldBlock(
            text: $deleveryNoteBinding,
            name: "Visit note",
            errorText: "",
            focused: noteFieldFocused,
            textContentType: .addressCityAndState,
            returnKeyType: .default,
            enablesReturnKeyAutomatically: true,
            wantsToBecomeFocused: visitNoteWantsToBecomeFocused,
            enterButtonPressed: visitNoteEnterButtonPressed
          )
          .padding([.trailing, .leading], 16)
          .padding(.top, 44 + 16)
        case let .manualVisit(.checkedOut(time)):
          VisitStatus(text: "Visited: \(time)", state: .visited)
            .padding(.top, 44)
          if !visitNote.isEmpty {
            ContentCell(
              title: "Visit note",
              subTitle: visitNote,
              leadingPadding: 16,
              copyTextPressed
            )
            .padding(.top, 16)
          }
        case let .assignedVisit(coordinate, address, metadata, status):
          AppleMapView(coordinate: coordinate.coordinate2D, span: 150)
            .frame(height: 160)
            .padding(.top, 44)
            .onTapGesture(perform: mapTapped)
          switch status {
          case .notSent, .pickedUp, .checkedIn:
            TextFieldBlock(
              text: $deleveryNoteBinding,
              name: "Visit note",
              errorText: "",
              focused: noteFieldFocused,
              textContentType: .addressCityAndState,
              returnKeyType: .default,
              enablesReturnKeyAutomatically: true,
              wantsToBecomeFocused: visitNoteWantsToBecomeFocused,
              enterButtonPressed: visitNoteEnterButtonPressed
            )
            .padding([.top, .trailing, .leading], 16)
            
          case let .checkedOut(time):
            VisitStatus(text: "Visited: \(time)", state: .visited)
            if !visitNote.isEmpty {
              ContentCell(
                title: "Visit note",
                subTitle: visitNote,
                leadingPadding: 16,
                copyTextPressed
              )
            }
          case .canceled:
            VisitStatus(text: "Canceled", state: .custom(color: .red))
            if !visitNote.isEmpty {
              ContentCell(
                title: "Visit note",
                subTitle: visitNote,
                leadingPadding: 16,
                copyTextPressed
              )
              .padding(.top, 8)
            }
          }
          if !address.isEmpty {
            ContentCell(
              title: "Location",
              subTitle: address,
              leadingPadding: 16,
              copyTextPressed
            )
            .padding(.top, 8)
          }
          ForEach(metadata, id: \.self) {
            ContentCell(
              title: $0.key,
              subTitle: $0.value,
              leadingPadding: 16,
              copyTextPressed
            )
          }
          .padding(.top, 8)
        }
      }
    }
    .frame(maxWidth: .infinity)
    .padding([.bottom], showButtons ? 88 + 8 : 8)
  }
}

struct VisitButtonView: View {
  let visitType: VisitScreen.State.VisitType
  let cancelButtonTapped: () -> Void
  let checkInButtonTapped: () -> Void
  let checkOutButtonTapped: () -> Void
  let pickedUpButtonTapped: () -> Void
  
  var body: some View {
    switch visitType {
    case .manualVisit(.notSent):
      RoundedStack {
        PrimaryButton(variant: .normal(title: "Check In"), checkInButtonTapped)
          .padding([.trailing, .leading], 58)
      }
    case .manualVisit(.checkedIn):
      RoundedStack {
        PrimaryButton(variant: .normal(title: "Check Out"), checkOutButtonTapped)
          .padding([.trailing, .leading], 58)
      }
    case .assignedVisit(_, _, _, .notSent):
      RoundedStack {
        HStack {
          PrimaryButton(variant: .normal(title: "Pick Up"), pickedUpButtonTapped)
            .padding([.leading], 16)
            .padding([.trailing], 2.5)
          PrimaryButton(variant: .normal(title: "Check In"), checkInButtonTapped)
            .padding([.leading], 2.5)
            .padding([.trailing], 16)
        }
      }
    case .assignedVisit(_, _, _, .pickedUp):
      RoundedStack {
        HStack {
          PrimaryButton(variant: .disabled(title: "Picked Up")) {}
            .padding([.leading], 16)
            .padding([.trailing], 2.5)
          PrimaryButton(variant: .normal(title: "Check In"), checkInButtonTapped)
            .padding([.leading], 2.5)
            .padding([.trailing], 16)
        }
      }
    case .assignedVisit(_, _, _, .checkedIn):
      RoundedStack {
        HStack {
          PrimaryButton(variant: .normal(title: "Check Out"), checkOutButtonTapped)
            .padding([.leading], 16)
            .padding([.trailing], 2.5)
          PrimaryButton(variant: .destructive(), cancelButtonTapped)
            .padding([.leading], 2.5)
            .padding([.trailing], 16)
        }
      }
    default:
      EmptyView()
    }
  }
}

struct CancelButton: View {
  @Environment(\.colorScheme) var colorScheme
  
  var cancelButtonTapped: () -> Void
  
  var body: some View {
    Button("Cancel", action: cancelButtonTapped)
      .font(.normalHighBold)
      .foregroundColor(colorScheme == .dark ? .white : .black)
      .frame(width: 110, height: 44, alignment: .leading)
  }
}


struct Screen_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      VisitScreen(
        state: .init(
          title: "Rauscherstraße 5",
          visitNote: "Waiting for client",
          noteFieldFocused: false,
          visitType: .assignedVisit(
            coordinate: Coordinate(latitude: 40.6908, longitude: -74.0459)!,
            address: "Rauscherstraße 5, 1200 Wien, Австрия",
            metadata: [
              .init(key: "Key1", value: "Value1"),
              .init(key: "Key2", value: "Value2"),
              .init(key: "Key3", value: "Value3"),
              .init(key: "Key4", value: "Value4")
            ],
            status: .canceled
          ),
          deviceID: "",
          publishableKey: ""
        ),
        send: { _ in }
      )
      .previewScheme(.light)
      VisitScreen(
        state: .init(
          title: "New Visit",
          visitNote: "Waiting for client",
          noteFieldFocused: false,
          visitType: .manualVisit(status: .checkedOut("5 PM")),
          deviceID: "",
          publishableKey: ""
        ),
        send: { _ in}
      )
      .previewScheme(.light)
    }
  }
}
