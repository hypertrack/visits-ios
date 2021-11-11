import SwiftUI

// MARK: - DeliveryCell

public struct DeliveryCell: View {
  @Environment(\.colorScheme) var colorScheme
  private let title: String
  private let subTitle: String
  private let onTapAction: () -> Void
  
  public init(title: String, subTitle: String = "", _ onTapAction: @escaping () -> Void = {}) {
    self.title = title
    self.subTitle = subTitle
    self.onTapAction = onTapAction
  }
  
  public var body: some View {
    GeometryReader { geometry in
      Button(action: {
        onTapAction()
      }, label: {
        HStack {
          VStack(alignment: .leading) {
            Text(title)
              .font(.normalHighBold)
              .foregroundColor(colorScheme == .dark ? .white : .gunPowder)
            if subTitle.isEmpty == false {
              Text(subTitle)
                .font(.tinyMedium)
                .foregroundColor(colorScheme == .dark ? .titanWhite : .greySuit)
                .padding(.top, 4)
            }
          }
          Spacer()
          Image(systemName: "chevron.right").foregroundColor(colorScheme == .dark ? .white : .gunPowder)
        }
        .frame(width: geometry.size.width)
      })
    }.frame(height: 50)
  }
}

struct DeliveryCell_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      DeliveryCell(title: "address", subTitle: "subtitle")
        .previewScheme(.light)
      DeliveryCell(title: "address", subTitle: "subtitle")
        .previewScheme(.dark)
    }
    .previewLayout(.sizeThatFits)
    
  }
}

// MARK: - ContentCell

public struct ContentCell: View {
  @Environment(\.colorScheme) var colorScheme
  private let title: String
  private let subTitle: String
  private let leadingPadding: CGFloat
  private let isCopyButtonEnabled: Bool
  private let onCopyAction: (String) -> Void
  
  public init(
    title: String,
    subTitle: String = "",
    leadingPadding: CGFloat = 24.0,
    isCopyButtonEnabled: Bool = true,
    _ onCopyAction: @escaping (String) -> Void = { _ in }
  ) {
    self.title = title
    self.subTitle = subTitle
    self.leadingPadding = leadingPadding
    self.isCopyButtonEnabled = isCopyButtonEnabled
    self.onCopyAction = onCopyAction
  }
  
  public var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(title)
          .font(.headline)
          .foregroundColor(Color(.label))
        if subTitle.isEmpty == false {
          Text(subTitle)
            .font(.subheadline)
            .foregroundColor(Color(.secondaryLabel))
            .padding(.top, 4)
        }
      }
      .padding(.leading, leadingPadding)
      .padding(.top, 8)
      Spacer()
      if isCopyButtonEnabled {
        Button {
          onCopyAction(subTitle)
        } label: {
            Image(systemName: "doc.on.doc")
              .font(.system(size: 24, weight: .light))
              .foregroundColor(Color(.secondaryLabel))
        }
        .padding(.trailing, leadingPadding)
      }
    }
  }
}

struct ContentCell_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ContentCell(title: "address", subTitle: "501 Twin Peaks Blvd, San Francisco, CA 94114 501 Twin Peaks Blvd, San Francisco, CA 94114 ")
        .previewScheme(.light)
      ContentCell(title: "address", subTitle: "501 Twin Peaks Blvd, San Francisco, CA 94114 501 Twin Peaks Blvd, San Francisco, CA 94114 ")
        .previewScheme(.dark)
    }
    .previewLayout(.sizeThatFits)
  }
}

public struct EditContentCell: View {
  @Environment(\.colorScheme) var colorScheme
  
  private let title: String
  @State private var subTitle: String
  private let leadingPadding: CGFloat
  private let onEditAction: (String) -> Void

  public init(
    title: String,
    subTitle: String = "",
    leadingPadding: CGFloat = 24.0,
    _ onEditAction: @escaping (String) -> Void) {
    self.title = title
    self.subTitle = subTitle
    self.leadingPadding = leadingPadding
    self.onEditAction = onEditAction
  }
  
  public var body: some View {
    VStack {
      Text(title)
        .font(.headline)
        .foregroundColor(Color(.label))
      TextField(
              title,
              text: $subTitle
          ) { isEditing in
//              self.isEditing = isEditing
          } onCommit: {
            onEditAction(subTitle)
          }
      .padding(.top, 4)
      .font(.subheadline)
      .autocapitalization(.none)
      .disableAutocorrection(true)
    }
    .padding(.leading, leadingPadding)
    .padding(.top, 8)
  }
}

