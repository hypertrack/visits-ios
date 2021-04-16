import NonEmpty
import SwiftUI
import Views

public struct ProfileScreen: View {
  public struct State {
    public let id: NonEmptyString
    public let name: NonEmptyString?
    public let deviceID: NonEmptyString
    public let metadata: [NonEmptyString: NonEmptyString]
    public let appVersion: NonEmptyString
    
    public init(
      id: NonEmptyString,
      name: NonEmptyString?,
      deviceID: NonEmptyString,
      metadata: [NonEmptyString: NonEmptyString],
      appVersion: NonEmptyString
    ) {
      self.id = id
      self.name = name
      self.deviceID = deviceID
      self.metadata = metadata
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
          TextRow("ID", text: state.id) {
            send(.copyTextPressed($0))
          }
          
          if let name = state.name {
            TextRow("Name", text: name) {
              send(.copyTextPressed($0))
            }
          }
          TextRow("Device ID", text: state.deviceID) {
            send(.copyTextPressed($0))
          }
        }
        
        if !state.metadata.isEmpty {
          Section(header: Text("Profile")) {
            ForEach(metadata(from: state.metadata)) { metadata in
              TextRow(metadata.id, text: metadata.contents) {
                send(.copyTextPressed($0))
              }
            }
          }
        }
        
        Section(header: Text("App")) {
          TextRow("Version", text: state.appVersion) {
            send(.copyTextPressed($0))
          }
        }
      }
      .navigationBarTitle(Text("Profile"), displayMode: .automatic)
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
        id: "Driver 1234",
        name: "First Name",
        deviceID: "Device ID",
        metadata: [
          "AssignedID": "Assigned ID",
          "Public ID": "Public ID"
        ],
        appVersion: "1.2.3"
      )
    )
    .previewScheme(.dark)
  }
}
