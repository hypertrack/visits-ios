import ComposableArchitecture
import LogEnvironment
import Prelude

public func send<State, Action>(_ viewStore: ViewStore<State, Action>) -> (Action) -> Void {
  { a in viewStore.send(a) }
}

public extension Reducer {
  func pullback<GlobalState, GlobalAction, GlobalEnvironment>(
    state toLocalState: Affine<GlobalState, State>,
    action toLocalAction: Prism<GlobalAction, Action>,
    environment toLocalEnvironment: @escaping (GlobalEnvironment) -> Environment
  ) -> Reducer<GlobalState, GlobalAction, GlobalEnvironment> {
    .init { gs, ga, ge in
      guard let ls = toLocalState.extract(from: gs),
            let la = toLocalAction.extract(from: ga)
      else { return .none }
      var mls = ls
      let e = self.run(&mls, la, toLocalEnvironment(ge))
        .map(toLocalAction.embed)
      gs = (gs |> toLocalState.inject(mls))!
      return e
    }
  }
}

public extension Reducer {
  func prettyDebug() -> Reducer {
    self.debug() { _ in
      DebugEnvironment(
        printer: {
          logAction($0)
        }
      )
    }
  }
}

public extension Reducer where Action: Equatable {
  static func toggleReducer(
    _ ls: State,
    _ la: Action,
    _ rs: State,
    _ ra: Action
  ) -> Reducer {
    .init { state, action, _ in
      switch action {
      case la: state = ls
      case ra: state = rs
      default: return .none
      }
      return .none
    }
  }
}

@dynamicMemberLookup
public struct SystemEnvironment<Environment> {
  
  public init(
    environment: Environment,
    date: @escaping () -> Date,
    mainQueue: @escaping () -> AnySchedulerOf<DispatchQueue>,
    uuid: @escaping () -> UUID
  ) {
    self.environment = environment
    self.date = date
    self.mainQueue = mainQueue
    self.uuid = uuid
  }
  
  public var environment: Environment
  public var date: () -> Date
  public var mainQueue: () -> AnySchedulerOf<DispatchQueue>
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
      date: { Date() },
      mainQueue: { DispatchQueue.main.eraseToAnyScheduler() },
      uuid: { UUID() }
    )
  }

  /// Transforms the underlying wrapped environment.
  public func map<NewEnvironment>(
    _ transform: @escaping (Environment) -> NewEnvironment
  ) -> SystemEnvironment<NewEnvironment> {
    .init(
      environment: transform(self.environment),
      date: self.date,
      mainQueue: self.mainQueue,
      uuid: self.uuid
    )
  }
}

extension SystemEnvironment {
  public static func mock(
    environment: Environment,
    date: @escaping () -> Date,
    mainQueue: @escaping () -> AnySchedulerOf<DispatchQueue> = { fatalError() },
    uuid: @escaping () -> UUID
  ) -> Self {
    Self(
      environment: environment,
      date: date,
      mainQueue: { mainQueue().eraseToAnyScheduler() },
      uuid: uuid
    )
  }
}
