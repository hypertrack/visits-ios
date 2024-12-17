import NonEmpty
import SwiftUI


public struct VisitView: View {
  let id: NonEmptyString
  let entry: Date
  let exit: Date?
  let duration: UInt
  let copy: (NonEmptyString) -> Void
    
    public init(
        id: NonEmptyString,
        entry: Date,
        exit: Date?,
        duration: UInt,
        copy: @escaping (NonEmptyString) -> Void
    ) {
        self.id = id
        self.entry = entry
        self.exit = exit
        self.duration = duration
        self.copy = copy
    }
  
  public var body: some View {
    TimelinePieceView {
      HStack {
        Image(systemName: "mappin")
          .font(.system(size: 24, weight: .regular))
          .foregroundColor(.accentColor)
          .frame(width: 25, height: 25, alignment: .center)
        VStack(alignment: .leading) {
          Text(entryExitTime(entry: entry, exit: exit))
            .font(.callout)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(Color(.label))
          if duration != 0 {
            Text(localizedTime(duration, style: .full))
              .font(.subheadline)
              .fixedSize(horizontal: false, vertical: true)
              .foregroundColor(Color(.secondaryLabel))
          }
        }
        Spacer()
        Button {
          copy(id)
        } label: {
          Image(systemName: "doc.on.doc")
            .font(.system(size: 24, weight: .light))
            .foregroundColor(Color(.secondaryLabel))
        }
      }
    }
  }
}

func entryExitTime(entry: Date, exit: Date?) -> String {
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

func today(_ date: Date) -> Bool {
  Calendar.current.isDate(date, equalTo: Date(), toGranularity: .day)
}


struct VisitView_Previews: PreviewProvider {
  static var previews: some View {
    VisitView(
      id: "1",
      entry: Date() + (-200000),
      exit: Date(),
      duration: 20000,
      copy: { _ in }
    )
  }
}
