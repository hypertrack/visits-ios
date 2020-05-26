infix operator >=> : infixr1
infix operator <=< : infixr1

public func >=> <A, B, C>(
  _ f: @escaping (A) -> B?,
  _ g: @escaping (B) -> C?
  ) -> ((A) -> C?) {

  return { a in
    f(a).flatMap(g)
  }
}

public func >=> <A, B, C>(
  _ f: @escaping (A) -> [B],
  _ g: @escaping (B) -> [C]
  ) -> ((A) -> [C]) {

  return { a in
    f(a).flatMap(g)
  }
}

public func flatMap <A, B, C>(_ lhs: @escaping (B) -> ((A) -> C), _ rhs: @escaping (A) -> B) -> (A) -> C {
  return { a in
    lhs(rhs(a))(a)
  }
}

public func >=> <A, B, C, D>(lhs: @escaping (A) -> ((D) -> B), rhs: @escaping (B) -> ((D) -> C))
  -> (A)
  -> ((D) -> C) {
    return { a in
      flatMap(rhs, lhs(a))
    }
}
