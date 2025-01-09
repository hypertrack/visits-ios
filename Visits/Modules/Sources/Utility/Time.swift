import Foundation

public func defaultVisitsDateFrom(currentDate: Date, _ calendar: Calendar, _ timeZone: TimeZone) -> Date {
    var calendar = calendar
    calendar.timeZone = timeZone
    return calendar.startOfDay(for: calendar.date(byAdding: .day, value: -7, to: currentDate)!)
}

public func defaultVisitsDateTo(currentDate: Date, _ calendar: Calendar, _ timeZone: TimeZone) -> Date {
    var calendar = calendar
    calendar.timeZone = timeZone
    return calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: currentDate)!)
}
