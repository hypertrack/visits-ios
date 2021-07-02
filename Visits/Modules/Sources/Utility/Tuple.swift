public enum Tuple<A, B> {
  case tuple(A, B)
  
  public var first: A {
    switch self {
    case let .tuple(a, _): return a
    }
  }
  
  public var second: B {
    switch self {
    case let .tuple(_, b): return b
    }
  }
  
  public init(first: A, second: B) { self = .tuple(first, second) }
}

extension Tuple: Equatable where A:Equatable, B:Equatable {}

public func curry<A, B, C>(_ f: @escaping (Tuple<A, B>) -> C) -> (A) -> (B) -> C {
  { a in
    { b in
      f(.init(first: a, second: b))
    }
  }
}

public func uncurry<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (Tuple<A, B>) -> C {
  { t in
    f(t.first)(t.second)
  }
}

public func swap<A, B>(_ t: Tuple<A, B>) -> Tuple<B, A> {
    .init(first: t.second, second: t.first)
}
