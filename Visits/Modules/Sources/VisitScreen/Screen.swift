import ComposableArchitecture
import NonEmpty
import SwiftUI
import Types
import Views


public struct VisitScreen: View {
  public struct State: Equatable {
    
    public var title: String
    public var visitNote: String
    public var noteFieldFocused: Bool
    public var coordinate: Coordinate
    public var address: String
    public var metadata: [Metadata]
    public var status: VisitStatus
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
    
    public enum VisitStatus: Equatable {
      case notSent
      case pickedUp
      case entered(String)
      case visited(String)
      case checkedOut(visited: String?, completed: String)
      case canceled(visited: String?, canceled: String)
    }
    
    public var finished: Bool {
      switch status {
      case .checkedOut,
           .canceled:
        return true
      default:
        return false
      }
    }
    
    public init(
      title: String,
      visitNote: String,
      noteFieldFocused: Bool,
      coordinate: Coordinate,
      address: String,
      metadata: [Metadata],
      status: VisitStatus,
      deviceID: String,
      publishableKey: String
    ) {
      self.title = title
      self.visitNote = visitNote
      self.noteFieldFocused = noteFieldFocused
      self.coordinate = coordinate
      self.address = address
      self.metadata = metadata
      self.status = status
      self.deviceID = deviceID
      self.publishableKey = publishableKey
    }
  }
  
  public enum Action: Equatable {
    case backButtonTapped
    case cancelButtonTapped
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
        BackButton { send(.backButtonTapped) }
      },
      trailing: { EmptyView() }
    ) {
      ZStack {
        VisitInformationView(
          coordinate: state.coordinate,
          address: state.address,
          metadata: state.metadata,
          status: state.status,
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
          status: state.status,
          cancelButtonTapped: { send(.cancelButtonTapped) },
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
                send(.backButtonTapped)
              }
            }
          )
      )
    }
  }
}

struct VisitStatusView: View {
  let status: VisitScreen.State.VisitStatus

  var body: some View {
    switch status {
    case .notSent,
         .pickedUp:
      EmptyView()
    case let .entered(time),
         let .visited(time):
      VisitStatus(text: "Visited: \(time)", state: .visited)
    case let .checkedOut(.some(visited), completed):
      VisitStatus(text: "Visited: \(visited)", state: .visited)
      VisitStatus(text: "Marked Complete at: \(completed)", state: .completed)
    case let .checkedOut(.none, completed):
      VisitStatus(text: "Marked Complete at: \(completed)", state: .completed)
    case let .canceled(.some(visited), canceled):
      VisitStatus(text: "Visited: \(visited)", state: .visited)
      VisitStatus(text: "Marked Canceled at: \(canceled)", state: .custom(color: .red))
    case let .canceled(.none, canceled):
      VisitStatus(text: "Marked Canceled at: \(canceled)", state: .custom(color: .red))
    }
  }
}

struct VisitInformationView: View {
  let coordinate: Coordinate
  let address: String
  let metadata: [VisitScreen.State.Metadata]
  let status: VisitScreen.State.VisitStatus
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
        AppleMapView(coordinate: coordinate.coordinate2D, span: 150)
          .frame(height: 160)
          .padding(.top, 44)
          .onTapGesture(perform: mapTapped)
        VisitStatusView(status: status)
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
    .frame(maxWidth: .infinity)
    .padding([.bottom], showButtons ? CGFloat(78) : 0)
  }
}


struct VisitButtonView: View {
  let status: VisitScreen.State.VisitStatus
  let cancelButtonTapped: () -> Void
  let checkOutButtonTapped: () -> Void
  let pickedUpButtonTapped: () -> Void
  
  var body: some View {
    switch status {
    case .notSent:
      RoundedStack {
        PrimaryButton(variant: .normal(title: "On my way"), pickedUpButtonTapped)
          .padding([.leading], 16)
          .padding([.trailing], 2.5)
      }
    case .pickedUp,
         .entered,
         .visited:
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
    case .canceled,
         .checkedOut:
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
        coordinate: Coordinate(latitude: 40.6908, longitude: -74.0459)!,
        address: "Rauscherstraße 5, 1200 Wien, Австрия",
        metadata: [.init(key: "Key4", value: "Value4")],
        status: .checkedOut(visited: nil, completed: "5 PM"),
        deviceID: "",
        publishableKey: ""
      ),
      send: { _ in }
    )
    .previewScheme(.light)
  }
}
