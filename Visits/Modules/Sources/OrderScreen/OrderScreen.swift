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
    case pickedUpButtonTapped
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
    case     .none:    return "Order @ \(DateFormatter.stringDate(state.createdAt))"
    case let .some(a): return a.rawValue
    }
  }
  
  var orderNote: String {
    state.orderNote?.string ?? ""
  }
  
  var metadata: [Metadata] {
    state.metadata
      .map({ $0 })
      .sorted(by: \.key)
      .map { (name: Order.Name, contents: Order.Contents) in
      Metadata(key: "\(name)", value: "\(contents)")
    }
  }
  
  var status: OrderStatus {
    switch state.geotagSent {
    case .notSent:
      return .notSent
    case .pickedUp:
      return .pickedUp
    case let .entered(entry):
      return .entered(DateFormatter.stringDate(entry))
    case let .visited(entry, exit):
      return .visited("\(DateFormatter.stringDate(entry)) — \(DateFormatter.stringDate(exit))")
    case let .checkedOut(visited, checkedOutDate):
      return .checkedOut(visited: visited.map(visitedString(_:)), completed: DateFormatter.stringDate(checkedOutDate))
    case let .cancelled(visited, cancelledDate):
      return .canceled(visited: visited.map(visitedString(_:)), canceled: DateFormatter.stringDate(cancelledDate))
    }
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
          status: status,
          showButtons: !finished,
          orderNote: orderNote,
          deleveryNoteBinding: Binding(
            get: { orderNote },
            set: { send(.noteFieldChanged($0)) }
          ),
          noteFieldFocused: state.noteFieldFocused,
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
          status: status,
          cancelButtonTapped: { send(.cancelButtonTapped) },
          checkOutButtonTapped: { send(.checkOutButtonTapped) },
          pickedUpButtonTapped: { send(.pickedUpButtonTapped) }
        )
        .padding(.bottom, -10)
      }
      .modifier(AppBackground())
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

struct StatusView: View {
  let status: OrderScreen.OrderStatus

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

struct InformationView: View {
  let coordinate: Coordinate
  let address: String
  let metadata: [OrderScreen.Metadata]
  let status: OrderScreen.OrderStatus
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
        StatusView(status: status)
        switch status {
        case .notSent, .pickedUp, .entered, .visited:
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
        case .checkedOut, .canceled:
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
  let status: OrderScreen.OrderStatus
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

extension DateFormatter {
  static func stringDate(_ date: Date) -> String {
    let dateFormat = DateFormatter()
    dateFormat.locale = Locale(identifier: "en_US_POSIX")
    dateFormat.dateFormat = "h:mm a"
    return dateFormat.string(from: date)
  }
}

extension Sequence {
  func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
    return sorted { a, b in
      return a[keyPath: keyPath] < b[keyPath: keyPath]
    }
  }
}

func visitedString(_ visited: Order.Geotag.Visited) -> String {
  switch visited {
  case let .entered(entry): return DateFormatter.stringDate(entry)
  case let .visited(entry, exit): return "\(DateFormatter.stringDate(entry)) — \(DateFormatter.stringDate(exit))"
  }
}

struct OrderScreen_Previews: PreviewProvider {
  static var previews: some View {
    OrderScreen(
      state: Order(
        id: Order.ID(rawValue: "ID7"),
        createdAt: Calendar.current.date(bySettingHour: 9, minute: 40, second: 0, of: Date())!,
        source: .trip,
        location: Coordinate(latitude: 37.778655, longitude: -122.422231)!,
        geotagSent: .entered(Date()),
        noteFieldFocused: false,
        address: .init(
          street: Street(rawValue: "333 Fulton St"),
          fullAddress: FullAddress(rawValue: "333 Fulton St, San Francisco, CA  94102, United States")
        )
      ),
      send: { _ in }
    )
    .previewScheme(.light)
  }
}
