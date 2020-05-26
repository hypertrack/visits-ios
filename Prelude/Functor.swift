infix operator <¢>: infixl4
infix operator ¢>: infixl4
infix operator <¢: infixl4
infix operator <£>: infixl1

public func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
  return { $0.map(f) }
}

// MARK: - Optional

extension Optional {
  public static func <¢> <A>(f: (Wrapped) -> A, x: Optional) -> A? {
    return x.map(f)
  }
}

public func map<A, B>(_ a2b: @escaping (A) -> B) -> (A?) -> B? {
  return { a in
    a2b <¢> a
  }
}
