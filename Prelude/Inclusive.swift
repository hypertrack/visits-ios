public enum Inclusive<A,B> {
  case left(A)
  case center(A,B)
  case right(B)
  
  public func flip() -> Inclusive<B,A> {
    switch self {
    case let .left(a):
      return .right(a)
    case let .center(a, b):
      return .center(b,a)
    case let .right(b):
      return .left(b)
    }
  }
  
  public func fold <T> (
    onLeft: @escaping (A) -> T,
    onCenter: @escaping (A,B) -> T,
    onRight: @escaping (B) -> T
  ) -> T {
    switch self {
    case let .left(a):
      return onLeft(a)
    case let .center(a, b):
      return onCenter(a,b)
    case let .right(b):
      return onRight(b)
    }
  }
}

extension Inclusive: Equatable where A: Equatable, B: Equatable {
  public static func == (lhs: Inclusive, rhs: Inclusive) -> Bool {
    switch (lhs, rhs) {
    case let (.left(lhsValue), .left(rhsValue)):
      return lhsValue == rhsValue
    case let (.center(lhsValueA, lhsValueB), .center(rhsValueA, rhsValueB)):
      return lhsValueA == rhsValueA && lhsValueB == rhsValueB
    case let (.right(lhsValue), .right(rhsValue)):
      return lhsValue == rhsValue
    default:
      return false
    }
  }
}
