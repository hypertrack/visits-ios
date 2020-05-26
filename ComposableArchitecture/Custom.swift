public func bail<Value, Action>(_ state: Value, _ action: Action) -> Effect<Action, Never> {
  assert(false, "\(action) doesn't make sense in \(state)")
  return .none
}


@dynamicMemberLookup
public struct SystemEnvironment<Environment> {
  
  public init(
    environment: Environment,
    mainQueue: @escaping () -> AnySchedulerOf<DispatchQueue>
  ) {
    self.environment = environment
    self.mainQueue = mainQueue
  }
  
  public var environment: Environment
  public var mainQueue: () -> AnySchedulerOf<DispatchQueue>

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
      mainQueue: { DispatchQueue.main.eraseToAnyScheduler() }
    )
  }

  /// Transforms the underlying wrapped environment.
  public func map<NewEnvironment>(
    _ transform: @escaping (Environment) -> NewEnvironment
  ) -> SystemEnvironment<NewEnvironment> {
    .init(
      environment: transform(self.environment),
      mainQueue: self.mainQueue
    )
  }
}

#if DEBUG
  extension SystemEnvironment {
    public static func mock(
      date: @escaping () -> Date = { fatalError("date dependency is unimplemented.") },
      environment: Environment,
      mainQueue: @escaping () -> AnySchedulerOf<DispatchQueue> = { fatalError() },
      uuid: @escaping () -> UUID = { fatalError("UUID dependency is unimplemented.") }
    ) -> Self {
      Self(
        environment: environment,
        mainQueue: { mainQueue().eraseToAnyScheduler() }
      )
    }
  }
#endif
