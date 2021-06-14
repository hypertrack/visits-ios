// sourcery: functor, apply, applicative, alt, either, bind, monad
// sourcery: generic = "E, _"
public enum Either<L, R> {
  case left(L)
  case right(R)
}

public func either<L, R, A>(
  _ l2a: @escaping (L) -> A
) -> (@escaping (R) -> A) -> (Either<L, R>) -> A {
  { r2a in
    { e in
      switch e {
      case let .left(l):  return l2a(l)
      case let .right(r): return r2a(r)
      }
    }
  }
}

public func isLeft<L, R>(_ e: Either<L, R>) -> Bool {
  e |> either(constant(true))(constant(false))
}

public func isRight<L, R>(_ e: Either<L, R>) -> Bool {
  e |> either(constant(false))(constant(true))
}

public func note<A, B>(_ a: (A)) -> (Optional<B>) -> Either<A, B> {
  optional(.left(a))(Either.right)
}

public func eitherLeft<L, R>(_ e: Either<L, R>) -> L? {
  e |> either(Optional.some)(constant(.none))
}

public func eitherRight<L, R>(_ e: Either<L, R>) -> R? {
  e |> either(constant(.none))(Optional.some)
}

// MARK: - Category Theory
// MARK: Functor

public func map<E, A, B>(_ f: @escaping (A) -> B) -> (Either<E, A>) -> Either<E, B> {
  { either in
    switch either {
    case let .left(l):
      return .left(l)
    case let .right(r):
      return .right(f(r))
    }
  }
}

// sourcery:inline:Either.Functor
public func <!> <E, A, B>(f: @escaping (A) -> B, m: Either<E, A>) -> Either<E, B> {
    map(f)(m)
}

public func mapFlipped<E, A, B>(_ m: Either<E, A>) -> (@escaping (A) -> B) -> Either<E, B> {
  { f in map(f)(m) }
}

public func <¡> <E, A, B>(m: Either<E, A>, f: @escaping (A) -> B) -> Either<E, B> {
  mapFlipped(m)(f)
}

public func replaceWithLeft<E, A, B>(_ b: B) -> (Either<E, A>) -> Either<E, B> {
  b |> constant >>> map
}

public func <! <E, A, B>(a: B, m: Either<E, A>) -> Either<E, B> {
  replaceWithLeft(a)(m)
}

public func replaceWithRight<E, A, B>(_ m: Either<E, A>) -> (B) -> Either<E, B> {
  { a in constant(a) <!> m }
}

public func !> <E, A, B>(m: Either<E, A>, a: B) -> Either<E, B> {
  replaceWithRight(m)(a)
}

public func replaceWithVoid<E, A>(_ m: Either<E, A>) -> Either<E, Void> {
  () <! m
}

public func flip<E, A, B>(_ ef: Either<E, (A) -> B>) -> (A) -> Either<E, B> {
  { r in map { $0(r) } <| ef }
}

public func >!< <E, A, B>(ef: Either<E, (A) -> B>, r: A) -> Either<E, B> {
  flip(ef)(r)
}
// sourcery:end

// MARK: Apply

public func apply<E, A, B>(_ ef: Either<E, (A) -> B>) -> (Either<E, A>) -> Either<E, B> {
  { e in
    switch ef {
    case let .left(l):  return .left(l)
    case let .right(f): return f <!> e
    }
  }
}

// sourcery:inline:Either.Apply
public func <*> <E, A, B>(mf: Either<E, (A) -> B>, m: Either<E, A>) -> Either<E, B> {
  apply(mf)(m)
}

public func applyFirst<E, A, B>(_ m: Either<E, A>) -> (Either<E, B>) -> Either<E, A> {
  { ma in constant <!> m <*> ma }
}

public func <* <E, A, B>(m: Either<E, A>, ma: Either<E, B>) -> Either<E, A> {
  applyFirst(m)(ma)
}

public func appllySecond<E, A, B>(_ ma: Either<E, A>) -> (Either<E, B>) -> Either<E, B> {
  { mb in identity <! ma <*> mb }
}

public func *> <E, A, B>(ea: Either<E, A>, eb: Either<E, B>) -> Either<E, B> {
  appllySecond(ea)(eb)
}
// sourcery:end

// MARK: Applicative

public func pure<E, A>(_ a: A) -> Either<E, A> { .right(a) }

// sourcery:inline:Either.Applicative
public func when<E>(_ when: Bool) -> (Either<E, Terminal>) -> Either<E, Terminal> {
  { e in when ? e : pure(unit) }
}

public func unless<E>(_ unless: Bool) -> (Either<E, Terminal>) -> Either<E, Terminal> {
  { e in unless ? pure(unit) : e }
}
// sourcery:end

// MARK: Alt

public func alt<E, A>(_ left: Either<E, A>) -> (Either<E, A>) -> Either<E, A> {
  { right in
    switch (left, right) {
    case let (.left, r): return r
    case let (l    , _): return l
    }
  }
}

// sourcery:inline:Either.Alt
public func <|> <E, A>(left: Either<E, A>, right: Either<E, A>) -> Either<E, A> {
  alt(left)(right)
}
// sourcery:end

// MARK: Either

// sourcery:inline:Either.Either
public func choose<E, A, B>(_ ma: Either<E, A>) -> (Either<E, B>) -> Either<E, Either<A, B>> {
  { mb in Either.left <!> ma <|> Either.right <!> mb }
}
// sourcery:end

// MARK: Bind

public func flatMap<E, A, B>(_ m: Either<E, A>) -> (@escaping (A) -> Either<E, B>) -> Either<E, B> {
  { f in m |> either(Either.left)(f) }
}

// sourcery:inline:Either.Bind
public func >>- <E, A, B>(m: Either<E, A>, a2mb: @escaping (A) -> Either<E, B>) -> Either<E, B> {
  flatMap(m)(a2mb)
}

public func flatMapFlipped<E, A, B>(_ a2m: @escaping (A) -> Either<E, B>) -> (Either<E, A>) -> Either<E, B> {
  flip(flatMap)(a2m)
}

public func -<< <E, A, B>(a2m: @escaping (A) -> Either<E, B>, m: Either<E, A>) -> Either<E, B> {
  m >>- a2m
}

public func join<E, A>(mm: Either<E, Either<E, A>>) -> Either<E, A> {
  mm >>- identity
}

public func composeKleisli<E, A, B, C>(_ a2b: @escaping (A) -> Either<E, B>) -> (@escaping (B) -> Either<E, C>) -> (A) -> Either<E, C> {
  { b2c in { a in a2b(a) >>- b2c } }
}

public func >-> <E, A, B, C>(a2b: @escaping (A) -> Either<E, B>, b2c: @escaping (B) -> Either<E, C>) -> (A) -> Either<E, C> {
  composeKleisli(a2b)(b2c)
}

public func composeKleisliFlipped<E, A, B, C>(_ b2c: @escaping (B) -> Either<E, C>) -> (@escaping (A) -> Either<E, B>) -> (A) -> Either<E, C> {
  flip(composeKleisli)(b2c)
}

public func <-< <E, A, B, C>(b2c: @escaping (B) -> Either<E, C>, a2b: @escaping (A) -> Either<E, B>) -> (A) -> Either<E, C> {
  composeKleisliFlipped(b2c)(a2b)
}

public func ifM<E, A>(_ cond: Either<E, Bool>) -> (Either<E, A>) -> (Either<E, A>) -> Either<E, A> {
  { t in { f in cond >>- { $0 ? t : f } } }
}
// sourcery:end


// MARK: Monad

// sourcery:inline:Either.Monad
public func whenM<E>(_ mb: Either<E, Bool>) -> (Either<E, Terminal>) ->  Either<E, Terminal> {
  { m in mb >>- { b in when(b)(m) } }
}

public func unlessM<E>(_ mb: Either<E, Bool>) -> (Either<E, Terminal>) ->  Either<E, Terminal> {
  { m in mb >>- { b in unless(b)(m) } }
}
// sourcery:end

// MARK: Extend

public func extend<E, A, B>(_ ef: @escaping (Either<E, A>) -> B) -> (Either<E, A>) -> Either<E, B> {
  { m in
    switch m {
    case let .left(y): return .left(y)
    case     .right:   return .right(ef(m))
    }
  }
}

// MARK: - Equatable

extension Either: Equatable where L: Equatable, R: Equatable {}

// MARK: - Comparable

extension Either: Comparable where L: Comparable, R: Comparable {}

// MARK: - Codable

extension Either: Codable where L: Codable, R: Codable {
  public init(from decoder: Decoder) throws {
    do {
      self = try .right(.init(from: decoder))
    } catch {
      self = try .left(.init(from: decoder))
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    switch self {
    case let .left(l):
      try l.encode(to: encoder)
    case let .right(r):
      try r.encode(to: encoder)
    }
  }
}

// MARK: - Error

extension Either: Error where L: Error {}

// MARK: - Hashable

extension Either: Hashable where L: Hashable, R: Hashable {}
