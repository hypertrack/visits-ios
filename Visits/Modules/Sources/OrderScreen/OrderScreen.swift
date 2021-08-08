import ComposableArchitecture
import NonEmpty
import SwiftUI
import Types
import Views


public struct OrderScreen: View {
  public struct Metadata: Hashable {
    public let key: String
    public let value: String
    
    public init(key: String, value: String) {
      self.key = key
      self.value = value
    }
  }
  
  public enum OrderStatus: Equatable {
    case notSent
    case pickedUp
    case entered(String)
    case visited(String)
    case checkedOut(visited: String?, completed: String)
    case canceled(visited: String?, canceled: String)
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
    case tappedOutsideFocusedTextField
  }
  
  @Environment(\.colorScheme) var colorScheme
  @GestureState private var dragOffset = CGSize.zero
  let state: Order
  let send: (Action) -> Void
  
  public init(
    state: Order,
    send: @escaping (Action) -> Void
  ) {
    self.state = state
    self.send = send
  }
  
  var title: String {
    switch state.address.anyAddressStreetBias {
    case     .none:    return "Order @ \(DateFormatter.stringTime(state.createdAt))"
    case let .some(a): return a.rawValue
    }
  }
  
  var orderNote: String {
    state.note?.string ?? ""
  }
  
  var noteFieldFocused: Bool {
    switch state.status {
    case .ongoing(.focused): return true
    default:                 return false
    }
  }
  
  var metadata: [Metadata] {
    state.metadata
      .map({ $0 })
      .sorted(by: \.key)
      .map { (name: Order.Name, contents: Order.Contents) in
      Metadata(key: "\(name)", value: "\(contents)")
    }
  }
  
  public var finished: Bool {
    switch state.status {
    case .completed, .cancelled, .disabled:
      return true
    default:
      return false
    }
  }
  
  public var body: some View {
    Navigation(
      title: title,
      leading: {
        BackButton { send(.backButtonTapped) }
      },
      trailing: { EmptyView() }
    ) {
      ZStack {
        InformationView(
          coordinate: state.location,
          address: state.address.anyAddressStreetBias?.rawValue ?? "",
          metadata: metadata,
          status: state.status,
          visited: state.visited,
          showButtons: !finished,
          orderNote: orderNote,
          deleveryNoteBinding: Binding(
            get: { orderNote },
            set: { send(.noteFieldChanged($0)) }
          ),
          noteFieldFocused: noteFieldFocused,
          orderNoteWantsToBecomeFocused: { send(.noteTapped) },
          orderNoteEnterButtonPressed: { send(.noteEnterKeyboardButtonTapped) },
          mapTapped: { send(.mapTapped) },
          copyTextPressed: {
            if let na = NonEmptyString(rawValue: $0) {
              send(.copyTextPressed(na))
            }
          }
        )
        ButtonView(
          status: state.status,
          cancelButtonTapped: { send(.cancelButtonTapped) },
          checkOutButtonTapped: { send(.checkOutButtonTapped) }
        )
        .padding(.bottom, -10)
      }
      .modifier(AppBackground())
      .onTapGesture {
        if noteFieldFocused {
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

struct StatusView: View {
  let status: Order.Status
  let visited: Order.Visited?

  var body: some View {
    switch visited {
    case .none:
      EmptyView()
    case let .entered(entry):
      VisitStatus(text: "Visited: \(DateFormatter.stringTime(entry))", state: .visited)
    case let .visited(entry, exit):
      VisitStatus(text: "Visited: \(DateFormatter.stringTime(entry)) — \(DateFormatter.stringTime(exit))", state: .visited)
    }
    
    switch status {
    case .ongoing, .completing, .cancelling:
      EmptyView()
    case let .completed(time):
      VisitStatus(text: "Marked Complete at: \(DateFormatter.stringTime(time))", state: .completed)
    case .cancelled:
      VisitStatus(text: "Marked Canceled", state: .custom(color: .red))
    case .disabled:
      VisitStatus(text: "Snoozed", state: .custom(color: .gray))
    }
  }
}

struct InformationView: View {
  let coordinate: Coordinate
  let address: String
  let metadata: [OrderScreen.Metadata]
  let status: Order.Status
  let visited: Order.Visited?
  let showButtons: Bool
  let orderNote: String
  @Binding var deleveryNoteBinding: String
  let noteFieldFocused: Bool
  let orderNoteWantsToBecomeFocused: () -> Void
  let orderNoteEnterButtonPressed: () -> Void
  let mapTapped: () -> Void
  let copyTextPressed: (String) -> Void
  
  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        AppleMapView(coordinate: coordinate.coordinate2D, span: 150)
          .frame(height: 160)
          .padding(.top, 44)
          .onTapGesture(perform: mapTapped)
        StatusView(status: status, visited: visited)
        switch status {
        case .ongoing:
          TextFieldBlock(
            text: $deleveryNoteBinding,
            name: "Order note",
            errorText: "",
            focused: noteFieldFocused,
            textContentType: .addressCityAndState,
            returnKeyType: .default,
            enablesReturnKeyAutomatically: true,
            wantsToBecomeFocused: orderNoteWantsToBecomeFocused,
            enterButtonPressed: orderNoteEnterButtonPressed
          )
          .padding([.top, .trailing, .leading], 16)
        default:
          if !orderNote.isEmpty {
            ContentCell(
              title: "Order note",
              subTitle: orderNote,
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


struct ButtonView: View {
  let status: Order.Status
  let cancelButtonTapped: () -> Void
  let checkOutButtonTapped: () -> Void
  
  enum Status {
    init(status: Order.Status) {
      switch status {
      case .ongoing:    self = .showingButtons(.ongoing)
      case .completing: self = .showingButtons(.completing)
      case .completed:  self = .hidingButtons(.completed)
      case .cancelling: self = .showingButtons(.cancelling)
      case .cancelled:  self = .hidingButtons(.cancelled)
      case .disabled:   self = .hidingButtons(.disabled)
      }
    }
    
    case showingButtons(ShowingButtons)
    case hidingButtons(HidingButtons)
    
    enum ShowingButtons { case ongoing, completing, cancelling }
    enum HidingButtons { case completed, cancelled, disabled }
  }
  
  var body: some View {
    switch Status(status: status) {
    case let .showingButtons(showing):
      RoundedStack {
        HStack {
          PrimaryButton(
            variant: showing == .ongoing ? .normal(title: "Complete") : .disabled(title: "Complete"),
            showActivityIndicator: showing == .completing,
            checkOutButtonTapped
          )
            .padding([.leading], 16)
            .padding([.trailing], 2.5)
          PrimaryButton(
            variant: showing == .ongoing ? .destructive() : .disabled(title: "Cancel"),
            showActivityIndicator: showing == .cancelling,
            cancelButtonTapped
          )
            .padding([.leading], 2.5)
            .padding([.trailing], 16)
        }
      }
    case .hidingButtons:
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

struct OrderScreen_Previews: PreviewProvider {
  static var previews: some View {
    OrderScreen(
      state: Order(
        id: Order.ID(rawValue: "ID7"),
        tripID: "Blah",
        createdAt: Calendar.current.date(bySettingHour: 9, minute: 40, second: 0, of: Date())!,
        location: Coordinate(latitude: 37.778655, longitude: -122.422231)!,
        address: .init(
          street: Street(rawValue: "333 Fulton St"),
          fullAddress: FullAddress(rawValue: "333 Fulton St, San Francisco, CA  94102, United States")
        ),
        status: .ongoing(.unfocused),
        note: "Returning"
      ),
      send: { _ in }
    )
    .previewScheme(.light)
  }
}
