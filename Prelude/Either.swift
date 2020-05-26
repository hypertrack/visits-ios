public enum Either<L, R> {
  case left(L)
  case right(R)
}

extension Either {
  public func either<A>(_ l2a: (L) throws -> A, _ r2a: (R) -> A) rethrows -> A {
    switch self {
    case let .left(l):
      return try l2a(l)
    case let .right(r):
      return r2a(r)
    }
  }

  public var left: L? {
    return either(Optional.some, const(.none))
  }

  public var right: R? {
    return either(const(.none), Optional.some)
  }

  public var isLeft: Bool {
    return either(const(true), const(false))
  }

  public var isRight: Bool {
    return either(const(false), const(true))
  }
}

extension Either where L == R {
  public var any: L {
    switch self {
    case let .left(left):
      return left
    case let .right(right):
      return right
    }
  }
}

public func either<A, B, C>(_ a2c: @escaping (A) -> C, _ b2c: @escaping (B) -> C) -> (Either<A, B>) -> C {
  return { ab in
    ab.either(a2c, b2c)
  }
}

extension Either where L == Error {
  public static func wrap<A>(_ f: @escaping (A) throws -> R) -> (A) -> Either {
    return { a in
      do {
        return .right(try f(a))
      } catch let error {
        return .left(error)
      }
    }
  }

  public static func wrap(_ f: @escaping () throws -> R) -> Either {
    do {
      return .right(try f())
    } catch let error {
      return .left(error)
    }
  }

  public func unwrap() throws -> R {
    return try either({ throw $0 }, id)
  }
}

extension Either where L: Error {
  public func unwrap() throws -> R {
    return try either({ throw $0 }, id)
  }
}

public func unwrap<R>(_ either: Either<Error, R>) throws -> R {
  return try either.unwrap()
}

public func unwrap<L: Error, R>(_ either: Either<L, R>) throws -> R {
  return try either.unwrap()
}

// MARK: - Functor
extension Either {
  public func map<A>(_ r2a: (R) -> A) -> Either<L, A> {
    switch self {
    case let .left(l):
      return .left(l)
    case let .right(r):
      return .right(r2a(r))
    }
  }

  public static func <¢> <A>(r2a: (R) -> A, lr: Either) -> Either<L, A> {
    return lr.map(r2a)
  }
}

public func map<A, B, C>(_ b2c: @escaping (B) -> C) -> (Either<A, B>) -> Either<A, C> {
  return { ab in
    b2c <¢> ab
  }
}

// MARK: - Bifunctor
extension Either {
  public func bimap<A, B>(_ l2a: (L) -> A, _ r2b: (R) -> B) -> Either<A, B> {
    switch self {
    case let .left(l):
      return .left(l2a(l))
    case let .right(r):
      return .right(r2b(r))
    }
  }
}

public func bimap<A, B, C, D>(_ a2b: @escaping (A) -> B, _ c2d: @escaping (C) -> D)
  -> (Either<A, C>)
  -> Either<B, D> {
    return { ac in
      ac.bimap(a2b, c2d)
    }
}

// MARK: - Bind/Monad
extension Either {
  public func flatMap<A>(_ r2a: (R) -> Either<L, A>) -> Either<L, A> {
    return either(Either<L, A>.left, r2a)
  }
}

public func flatMap <L, R, A>(_ r2a: @escaping (R) -> Either<L, A>) -> (Either<L, R>) -> Either<L, A> {
  return { lr in
    lr.flatMap(r2a)
  }
}

public func >=> <E, A, B, C>(f: @escaping (A) -> Either<E, B>, g: @escaping (B) -> Either<E, C>) -> (A) -> Either<E, C> {
  return f >>> flatMap(g)
}

// MARK: - Eq/Equatable
extension Either: Equatable where L: Equatable, R: Equatable {
  public static func == (lhs: Either, rhs: Either) -> Bool {
    switch (lhs, rhs) {
    case let (.left(lhs), .left(rhs)):
      return lhs == rhs
    case let (.right(lhs), .right(rhs)):
      return lhs == rhs
    default:
      return false
    }
  }
}

// MARK: - Ord/Comparable
extension Either: Comparable where L: Comparable, R: Comparable {
  public static func < (lhs: Either, rhs: Either) -> Bool {
    switch (lhs, rhs) {
    case let (.left(lhs), .left(rhs)):
      return lhs < rhs
    case let (.right(lhs), .right(rhs)):
      return lhs < rhs
    case (.left, .right):
      return true
    case (.right, .left):
      return false
    }
  }
}

// MARK: - Codable
extension Either: Decodable where L: Decodable, R: Decodable {
  public init(from decoder: Decoder) throws {
    do {
      self = try .right(.init(from: decoder))
    } catch {
      self = try .left(.init(from: decoder))
    }
  }
}

extension Either: Encodable where L: Encodable, R: Encodable {
  public func encode(to encoder: Encoder) throws {
    switch self {
    case let .left(l):
      try l.encode(to: encoder)
    case let .right(r):
      try r.encode(to: encoder)
    }
  }
}
