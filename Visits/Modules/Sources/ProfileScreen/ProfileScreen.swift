import NonEmpty
import SwiftUI
import Types
import Utility
import Views

public struct ProfileScreen: View {
  public struct State {
    public let profile: Profile
    public let deviceID: DeviceID
    public let integrationStatus: IntegrationStatus
    public let appVersion: AppVersion
    
    
    public init(
      profile: Profile,
      deviceID: DeviceID,
      integrationStatus: IntegrationStatus,
      appVersion: AppVersion
    ) {
      self.profile = profile
      self.deviceID = deviceID
      self.integrationStatus = integrationStatus
      self.appVersion = appVersion
    }
  }
  
  public enum Action: Equatable {
    case copyTextPressed(NonEmptyString)
  }
  
  let state: State
  let send: (Action) -> Void
  
  public init(
    state: State,
    send: @escaping (Action) -> Void = { _ in }
  ) {
    self.state = state
    self.send = send
  }
  
  public var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Name")) {
          TextRow("Name", text: state.profile.name.rawValue) {
            send(.copyTextPressed($0))
          }
          TextRow("Device ID", text: state.deviceID.rawValue) {
            send(.copyTextPressed($0))
          }
        }
        
        if case let dictionary = dictionary(from: state.profile.metadata), !dictionary.isEmpty {
          Section(header: Text("Profile")) {
            ForEach(dictionary.map { key, value in (key, value) }.sorted(by: <), id: \.0) { (key, value) in
              TextRow(key, text: value) {
                send(.copyTextPressed($0))
              }
            }
          }
        }
        
        Section(header: Text("Integration")) {
          TextRow("Status", text: integrationStatusString(state.integrationStatus)) {
            send(.copyTextPressed($0))
          }
        }
        
        Section(header: Text("App")) {
          TextRow("Version", text: state.appVersion.rawValue) {
            send(.copyTextPressed($0))
          }
        }
      }
      .navigationBarTitle(Text("Profile"), displayMode: .automatic)
    }
  }
}

func integrationStatusString(_ integrationStatus: IntegrationStatus) -> NonEmptyString {
  switch integrationStatus {
  case .unknown:       return "Unknown"
  case .requesting:    return "Updating"
  case .integrated:    return "Integrated"
  case .notIntegrated: return "Not Integrated"
  }
}

func dictionary(from object: JSON.Object) -> [NonEmptyString: NonEmptyString] {
  object.reduce(into: [:]) { (result: inout [NonEmptyString: NonEmptyString], element: (key: String, value: JSON)) in
    let key = element.key
      .capitalized
      .replacingOccurrences(of: "-", with: " ")
      .replacingOccurrences(of: "_", with: " ")
    if let nonEmptyKey = NonEmptyString(rawValue: key) {
      switch element.value {
      case let .string(string):
        if let nonEmptyValue = NonEmptyString(rawValue: string) {
          result[nonEmptyKey] = nonEmptyValue
        }
      case let .number(number):
        if let nonEmptyValue = NonEmptyString(rawValue: String(number)) {
          result[nonEmptyKey] = nonEmptyValue
        }
      case let .bool(bool):
        result[nonEmptyKey] = bool ? "Yes" : "No"
      default:
        break
      }
    }
  }
}

struct TextRow: View {
  let name: NonEmptyString
  let contents: NonEmptyString
  let onCopyAction: (NonEmptyString) -> Void
  
  init(
    _ name: NonEmptyString,
    text: NonEmptyString,
    onCopyAction: @escaping (NonEmptyString) -> Void = { _ in }
  ) {
    self.name = name
    self.contents = text
    self.onCopyAction = onCopyAction
  }
  
  var body: some View {
    HStack {
      Text(name.rawValue)
        .font(.headline)
      Spacer()
      Text(contents.rawValue)
        .font(.callout)
        .lineLimit(1)
        .truncationMode(.tail)
      
      Button {
        onCopyAction(contents)
      } label: {
        Image(systemName: "doc.on.doc")
          .foregroundColor(Color(.secondaryLabel))
      }
    }
  }
}

struct Metadata: Identifiable {
  let id: NonEmptyString
  let contents: NonEmptyString
}

func metadata(from dictionary: [NonEmptyString: NonEmptyString]) -> [Metadata] {
  dictionary.reduce(into: []) { (metadata: inout [Metadata], value: (id: NonEmptyString, contents: NonEmptyString)) in
    metadata.append(Metadata(id: value.id, contents: value.contents))
  }
  .sorted(by: \.id)
}

extension Sequence {
  func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> [Element] {
    return sorted { a, b in
      return a[keyPath: keyPath] < b[keyPath: keyPath]
    }
  }
}

struct ProfileScreen_Previews: PreviewProvider {
  static var previews: some View {
    ProfileScreen(
      state: .init(
        profile: .init(name: "Example", metadata: ["email": "email@example.com", "phone_number": "+123456789", "deivce-info": 123]),
        deviceID: "DeviceID",
        integrationStatus: .requesting,
        appVersion: "1.2.3 (45)"
      )
    )
    .previewScheme(.dark)
  }
}
