import Foundation



public func getRangeStartFromDate(_ date: Date, _ calendar: Calendar, _ timeZone: TimeZone) -> Date {
    var calendar = calendar
    calendar.timeZone = timeZone
    return calendar.startOfDay(for: date)
}

public func getRangeEndFromDate(_ date: Date, _ calendar: Calendar, _ timeZone: TimeZone) -> Date {
    var calendar = calendar
    calendar.timeZone = timeZone
    return calendar.date(byAdding: .second, value: -1, to: calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: date)!))!
}

public func defaultVisitsDateFrom(currentDate: Date, _ calendar: Calendar, _ timeZone: TimeZone) -> Date {
    return getRangeStartFromDate(calendar.date(byAdding: .day, value: -7, to: currentDate)!, calendar, timeZone)
}

public func defaultVisitsDateTo(currentDate: Date, _ calendar: Calendar, _ timeZone: TimeZone) -> Date {
    return getRangeEndFromDate(currentDate, calendar, timeZone)
}
