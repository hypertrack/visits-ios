public struct LensM<S, T, A, B> {
  private let _get: (S) -> A
  private let _set: (B) -> (S) -> T
  
  public init(get: @escaping (S) -> A, set: @escaping (B) -> (S) -> T) {
    self._get = get
    self._set = set
  }
  
  public func get(from root: S) -> A { _get(root) }
  public func set(_ value: B) -> (S) -> T { _set(value) }
}

public typealias Lens<Root, Value> = LensM<Root, Root, Value, Value>

public extension LensM where S == T, A == B {
  typealias Root = S
  typealias Value = A
}

public extension LensM {
  func modify(_ f: @escaping (A) -> B) -> (S) -> T {
    get >>> f >>> set |> join
  }
  
  func appending<C, D>(_ lens: LensM<A, B, C, D>) -> LensM<S, T, C, D> {
    LensM<S, T, C, D>(
      get: get >>> lens.get,
      set: { d in
        get >>> lens.set(d) >>> set |> join
      }
    )
  }
}

// MARK: - Operators

public func *^ <S, T, A, B>(
  root: S,
  lens: LensM<S, T, A, B>
) -> A {
  lens.get(from: root)
}

public func *< <S, T, A, B>(
  lens: LensM<S, T, A, B>,
  value: B
) -> (S) -> T {
  lens.set(value)
}

public func *~ <S, T, A, B>(
  lens: LensM<S, T, A, B>,
  f: @escaping (A) -> B
) -> (S) -> T {
  lens.modify(f)
}

public func ** <S, T, A, B, C, D> (
  left: LensM<S, T, A, B>,
  right: LensM<A, B, C, D>
) -> LensM<S, T, C, D> {
  left.appending(right)
}

// MARK: - Types

public extension Lens where S == T, A == B, Value == Void {
  static func void() -> Lens<Root, Void> {
    Lens(
      get: constant(()),
      set: constant(identity)
    )
  }
}

public extension Dictionary {
  static func lens(at key: Key) -> Lens<Dictionary, Value?> {
    .init(
      get: { $0[key] },
      set: { value in
        { root in
          var dictionary = root
          dictionary[key] = value
          return dictionary
        }
      }
    )
  }
}

// MARK: - Laws

public enum LensLaw {
  public static func setGet <Root, Value> (lens: Lens<Root, Value>, root: Root, value: Value) -> Bool where Value: Equatable {
    lens.get(from: lens.set(value)(root)) == value
  }

  public static func setGet <Root, X, Y> (lens: Lens<Root, (X, Y)>, root: Root, value: (X, Y)) -> Bool where X: Equatable, Y: Equatable {
    lens.get(from: lens.set(value)(root)) == value
  }

  public static func getSet <S,A> (lens: Lens<S,A>, root: S) -> Bool where S: Equatable {
    lens.set(lens.get(from: root))(root) == root
  }

  public static func setSet <S,A> (lens: Lens<S,A>, root: S, value: A) -> Bool where S: Equatable {
    lens.set(value)(root) == lens.set(value)(lens.set(value)(root))
  }
}
