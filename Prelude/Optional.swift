public func optional<A, B>(_ default: @autoclosure @escaping () -> B) -> (@escaping (A) -> B) -> (A?) -> B {
  return { a2b in
    { a in
      a.map(a2b) ?? `default`()
    }
  }
}

public func coalesce<A>(with default: @autoclosure @escaping () -> A) -> (A?) -> A {
  return optional(`default`()) <| id
}


extension Optional {
  public func `do`(_ f: (Wrapped) -> Void) {
    if let x = self { f(x) }
  }
}
