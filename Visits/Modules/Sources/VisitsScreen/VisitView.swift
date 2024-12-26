import NonEmpty
import PlacesScreen
import SwiftUI
import Types

public struct VisitView: View {
  let visit: PlaceVisit
  let onClick: () -> Void

  public init(
    onClick: @escaping () -> Void,
    visit: PlaceVisit
    ) {
    self.onClick = onClick
    self.visit = visit
  }

  public var body: some View {
    Button(action: {
      onClick()
    }) {
      VStack {
        let address = visit.address?.rawValue
        if address != nil {
          Text(address!)
            .font(.headline)
            .foregroundColor(Color(.label))
            .padding(.leading, 8)
        }
        HStack {
          Text(entryExitTime(entry: visit.entry.rawValue, exit: visit.exit?.rawValue))
            .font(.callout)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(Color(.label))
          Spacer()
          if visit.duration != 0 {
            Text(localizedTime(visit.duration, style: .full))
              .font(.subheadline)
              .fixedSize(horizontal: false, vertical: true)
              .foregroundColor(Color(.secondaryLabel))
            Spacer()
          }
          if visit.route != nil {
            Text("\(localizedDistance(visit.route!.distance.rawValue)), \(localizedTime(visit.route!.duration.rawValue, style: .full))")
              .font(.subheadline)
              .fixedSize(horizontal: false, vertical: true)
              .foregroundColor(Color(.secondaryLabel))
          }
        }
      }.clipShape(RoundedRectangle(cornerRadius: 8))
    }
  }
}

public func entryExitTime(entry: Date, exit: Date?) -> String {
  let enteredToday = today(entry)
  let entryDate = DateFormatter.stringDate(entry)
  let entryTime = DateFormatter.stringTime(entry)
  let todayString = "Today"
  let entryOrToday = enteredToday ? todayString : entryDate
  if let exit = exit {
    let exitedToday = today(exit)
    let exitDate = DateFormatter.stringDate(exit)
    let exitTime = DateFormatter.stringTime(exit)
    let exitOrToday = exitedToday ? todayString : exitDate
    let sameDayVisit = Calendar.current.isDate(entry, equalTo: exit, toGranularity: .day)
    return entryOrToday + ", " + entryTime + " - " + (sameDayVisit ? "" : exitOrToday + ", ") + exitTime
  } else {
    return entryOrToday + ", " + entryTime + " - " + "Now"
  }
}
