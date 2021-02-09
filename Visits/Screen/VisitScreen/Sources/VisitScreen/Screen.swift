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
        case notSent
        case pickedUp
        case entered(String)
        case visited(String)
        case checkedOut(visited: String?, completed: String)
        case canceled(visited: String?, canceled: String)
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
        .padding(.bottom, -10)
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

enum VisitStatusModel {
  case manual(VisitScreen.State.VisitType.ManualVisitStatus)
  case assigned(VisitScreen.State.VisitType.AssignedVisitStatus)

  init(visitType: VisitScreen.State.VisitType) {
    switch visitType {
    case let .manualVisit(status):
      self = .manual(status)
    case let .assignedVisit(_, _, _, status):
      self = .assigned(status)
    }
  }
}

struct VisitStatusView: View {
  let status: VisitStatusModel

  var body: some View {
    switch status {
    case .manual(.notSent),
         .manual(.checkedIn),
         .assigned(.notSent),
         .assigned(.pickedUp):
      EmptyView()
    case let .manual(.checkedOut(time)):
      VisitStatus(text: "Visited: \(time)", state: .visited)
        .padding(.top, 44)
    case let .assigned(.entered(time)), let .assigned(.visited(time)):
      VisitStatus(text: "Visited: \(time)", state: .visited)
    case let .assigned(.checkedOut(.some(visited), completed)):
      VisitStatus(text: "Visited: \(visited)", state: .visited)
      VisitStatus(text: "Completed: \(completed)", state: .completed)
    case let .assigned(.checkedOut(.none, completed)):
      VisitStatus(text: "Completed at: \(completed)", state: .completed)
    case let .assigned(.canceled(.some(visited), canceled)):
      VisitStatus(text: "Visited: \(visited)", state: .visited)
      VisitStatus(text: "Canceled at: \(canceled)", state: .custom(color: .red))
    case let .assigned(.canceled(.none, canceled)):
      VisitStatus(text: "Canceled at: \(canceled)", state: .custom(color: .red))
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
        case let .manualVisit(status):
          VisitStatusView(status: .manual(status))
          switch status {
          case .notSent:
            CustomText(text: "Pressing the Check In button will start a new visit. Visits not completed after 24 hours will be removed automatically.")
              .defaultTextColor()
              .padding(.top, 44 + 16)
              .padding([.trailing, .leading], 8)
          case .checkedIn:
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
          case .checkedOut:
            if !visitNote.isEmpty {
              ContentCell(
                title: "Visit note",
                subTitle: visitNote,
                leadingPadding: 16,
                copyTextPressed
              )
              .padding(.top, 16)
            }
          }
        case let .assignedVisit(coordinate, address, metadata, status):
          AppleMapView(coordinate: coordinate.coordinate2D, span: 150)
            .frame(height: 160)
            .padding(.top, 44)
            .onTapGesture(perform: mapTapped)
          VisitStatusView(status: .assigned(status))
          switch status {
          case .notSent, .pickedUp, .entered, .visited:
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
          case .checkedOut, .canceled:
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
    .padding([.bottom], showButtons ? 78 : 0)
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
        PrimaryButton(variant: .normal(title: "Create"), checkInButtonTapped)
          .padding([.trailing, .leading], 58)
      }
    case .manualVisit(.checkedIn):
      RoundedStack {
        PrimaryButton(variant: .normal(title: "Complete"), checkOutButtonTapped)
          .padding([.trailing, .leading], 58)
      }
    case .assignedVisit(_, _, _, .notSent):
      RoundedStack {
        PrimaryButton(variant: .normal(title: "Picked Up"), pickedUpButtonTapped)
          .padding([.leading], 16)
          .padding([.trailing], 2.5)
      }
    case .assignedVisit(_, _, _, .pickedUp),
         .assignedVisit(_, _, _, .entered),
         .assignedVisit(_, _, _, .visited):
      RoundedStack {
        HStack {
          PrimaryButton(variant: .normal(title: "Complete"), checkOutButtonTapped)
            .padding([.leading], 16)
            .padding([.trailing], 2.5)
          PrimaryButton(variant: .destructive(), cancelButtonTapped)
            .padding([.leading], 2.5)
            .padding([.trailing], 16)
        }
      }
    case .manualVisit(status: .checkedOut),
         .assignedVisit(_, _, _, .canceled),
         .assignedVisit(_, _, _, .checkedOut):
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


struct VisitScreen_Previews: PreviewProvider {
  static var previews: some View {
    VisitScreen(
      state: .init(
        title: "Rauscherstraße 5",
        visitNote: "Waiting for client",
        noteFieldFocused: false,
        visitType: .assignedVisit(
          coordinate: Coordinate(latitude: 40.6908, longitude: -74.0459)!,
          address: "Rauscherstraße 5, 1200 Wien, Австрия",
          metadata: [
            .init(key: "Key4", value: "Value4")
          ],
          status: .checkedOut(visited: nil, completed: "5 PM")
        ),
        deviceID: "",
        publishableKey: ""
      ),
      send: { _ in }
    )
    .previewScheme(.light)
  }
}
