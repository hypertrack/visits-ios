import ComposableArchitecture
import Utility


@dynamicMemberLookup
public struct SystemEnvironment<Environment> {
  
  public init(
    environment: Environment,
    date: @escaping () -> Date,
    calendar: @escaping () -> Calendar,
    timeZone: @escaping () -> TimeZone,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    uuid: @escaping () -> UUID
  ) {
    self.environment = environment
    self.date = date
    self.calendar = calendar
    self.timeZone = timeZone
    self.mainQueue = mainQueue
    self.backgroundQueue = backgroundQueue
    self.uuid = uuid
  }
  
  public var environment: Environment
  public var date: () -> Date
  public var calendar: () -> Calendar
  public var timeZone: () -> TimeZone
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var backgroundQueue: AnySchedulerOf<DispatchQueue>
  public var uuid: () -> UUID

  public subscript<Dependency>(
    dynamicMember keyPath: WritableKeyPath<Environment, Dependency>
  ) -> Dependency {
    get { self.environment[keyPath: keyPath] }
    set { self.environment[keyPath: keyPath] = newValue }
  }

  /// Creates a live system environment with the wrapped environment provided.
  ///
  /// - Parameter environment: An environment to be wrapped in the system environment.
  /// - Returns: A new system environment.
  public static func live(environment: Environment) -> Self {
    Self(
      environment: environment,
      date: Date.init,
      calendar: { .current },
      timeZone: { .current },
      mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
      backgroundQueue: DispatchQueue(
        label: "com.hypertrack.visits.background",
        qos: .utility
      )
      .eraseToAnyScheduler(),
      uuid: UUID.init
    )
  }

  /// Transforms the underlying wrapped environment.
  public func map<NewEnvironment>(
    _ transform: @escaping (Environment) -> NewEnvironment
  ) -> SystemEnvironment<NewEnvironment> {
    .init(
      environment: transform(self.environment),
      date: self.date,
      calendar: self.calendar,
      timeZone: self.timeZone,
      mainQueue: self.mainQueue,
      backgroundQueue: self.backgroundQueue,
      uuid: self.uuid
    )
  }

  public func defaultVisitsDatePickerFromTo() -> (Date, Date) {
    let currentDate = self.date()
    let calendar = self.calendar()
    let timezone = self.timeZone()
    return (
      defaultVisitsDateFrom(currentDate: currentDate, calendar, timezone),
      defaultVisitsDateTo(currentDate: currentDate, calendar, timezone)
    )
  }
}

extension SystemEnvironment {
  public static func mock(
    environment: Environment,
    date: @escaping () -> Date,
    calendar: @escaping () -> Calendar,
    timeZone: @escaping () -> TimeZone,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    backgroundQueue: AnySchedulerOf<DispatchQueue>,
    uuid: @escaping () -> UUID
  ) -> Self {
    Self(
      environment: environment,
      date: date,
      calendar: calendar,
      timeZone: timeZone,
      mainQueue: mainQueue,
      backgroundQueue: backgroundQueue,
      uuid: uuid
    )
  }
}
