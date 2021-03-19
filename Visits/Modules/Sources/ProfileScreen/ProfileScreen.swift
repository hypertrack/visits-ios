import SwiftUI
import Views

public struct ProfileScreen: View {
  public struct State {
    public let id: String
    public let name: String
    public let deviceID: String
    public let metadata: [String: String]
    public let appVersion: String
    
    public init(
      id: String,
      name: String,
      deviceID: String,
      metadata: [String: String],
      appVersion: String
    ) {
      self.id = id
      self.name = name
      self.deviceID = deviceID
      self.metadata = metadata
      self.appVersion = appVersion
    }
  }
  
  
  let state: State
  
  public init(state: State) {
    self.state = state
  }
  
  public var body: some View {
    Navigation(
      title: "Profile",
      leading: {},
      trailing: {}
    ) {
      Form {
        CustomSection(header: "Name") {
          TextRow("ID", text: state.id)
          if !state.name.isEmpty {
            TextRow("Name", text: state.name)
          }
          TextRow("Device ID", text: state.deviceID)
        }
        
        if !state.metadata.isEmpty {
          CustomSection(header: "Profile") {
            ForEach(metadata(from: state.metadata)) { metadata in
              TextRow(metadata.id, text: metadata.contents)
            }
          }
        }
        
        CustomSection(header: "App") {
          TextRow("Version", text: state.appVersion)
        }
      }
      .padding(.top, 44)
      .modifier(AppBackground())
    }
  }
}

struct TextRow: View {
  let name: String
  let contents: String
  
  init(_ name: String, text: String) {
    self.name = name
    self.contents = text
  }
  
  var body: some View {
    HStack {
      CustomText(text: name)
      Spacer()
      CustomText(text: contents)
    }
  }
}

struct Metadata: Identifiable {
  let id: String
  let contents: String
}

func metadata(from dictionary: [String: String]) -> [Metadata] {
  dictionary.reduce(into: []) { (metadata: inout [Metadata], value: (id: String, contents: String)) in
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
