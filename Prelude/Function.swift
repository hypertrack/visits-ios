// MARK: - Application

infix operator |>: infixl1
public func |> <A, B> (a: A, f: (A) -> B) -> B {
  return f(a)
}

public func |> <A>(a: inout A, f: (inout A) -> Void) -> Void {
  f(&a)
}

infix operator <|: infixr0
public func <| <A, B> (f: (A) -> B, a: A) -> B {
  return f(a)
}

// MARK: - Composition

infix operator >>>: infixr9
public func >>> <A, B, C>(_ a2b: @escaping (A) -> B, _ b2c: @escaping (B) -> C) -> (A) -> C {
  return { a in b2c(a2b(a)) }
}

infix operator <<<: infixr9
public func <<< <A, B, C>(_ b2c: @escaping (B) -> C, _ a2b: @escaping (A) -> B) -> (A) -> C {
  return { a in b2c(a2b(a)) }
}

public func id<A>(_ a: A) -> A {
  return a
}

public func const<A, B>(_ a: A) -> (B) -> A {
  return { _ in a }
}

public func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
  return { b in
    { a in
      f(a)(b)
    }
  }
}
