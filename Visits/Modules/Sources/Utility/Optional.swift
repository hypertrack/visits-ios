// sourcery: functor, apply, applicative, alt, either, bind, monad
extension Optional {}

public func optional<Wrapped, A>(_ a: A) -> (@escaping (Wrapped) -> A) -> (Optional<Wrapped>) -> A {
  { f in
    { o in
      switch o {
      case     .none:    return a
      case let .some(a): return f(a)
      }
    }
  }
}

// MARK: - Category Theory
// MARK: Functor

public func map<A, B>(_ f: @escaping (A) -> B) -> (Optional<A>) -> Optional<B> {
  { m in m.map(f) }
}

// sourcery:inline:Optional.Functor
public func <!> <A, B>(f: @escaping (A) -> B, m: Optional<A>) -> Optional<B> {
    map(f)(m)
}

public func mapFlipped<A, B>(_ m: Optional<A>) -> (@escaping (A) -> B) -> Optional<B> {
  { f in map(f)(m) }
}

public func <¡> <A, B>(m: Optional<A>, f: @escaping (A) -> B) -> Optional<B> {
  mapFlipped(m)(f)
}

public func replaceWithLeft<A, B>(_ b: B) -> (Optional<A>) -> Optional<B> {
  b |> constant >>> map
}

public func <! <A, B>(a: B, m: Optional<A>) -> Optional<B> {
  replaceWithLeft(a)(m)
}

public func replaceWithRight<A, B>(_ m: Optional<A>) -> (B) -> Optional<B> {
  { a in constant(a) <!> m }
}

public func !> <A, B>(m: Optional<A>, a: B) -> Optional<B> {
  replaceWithRight(m)(a)
}

public func replaceWithVoid<A>(_ m: Optional<A>) -> Optional<Void> {
  () <! m
}

public func flip<A, B>(_ ef: Optional<(A) -> B>) -> (A) -> Optional<B> {
  { r in map { $0(r) } <| ef }
}

public func >!< <A, B>(ef: Optional<(A) -> B>, r: A) -> Optional<B> {
  flip(ef)(r)
}
// sourcery:end

// MARK: Apply

public func apply<A, B>(_ mf: Optional<(A) -> B>) -> (Optional<A>) -> Optional<B> {
  { m in
    if let mf = mf, let m = m {
      return .some(mf(m))
    } else {
      return .none
    }
  }
}

// sourcery:inline:Optional.Apply
public func <*> <A, B>(mf: Optional<(A) -> B>, m: Optional<A>) -> Optional<B> {
  apply(mf)(m)
}

public func applyFirst<A, B>(_ m: Optional<A>) -> (Optional<B>) -> Optional<A> {
  { ma in constant <!> m <*> ma }
}

public func <* <A, B>(m: Optional<A>, ma: Optional<B>) -> Optional<A> {
  applyFirst(m)(ma)
}

public func appllySecond<A, B>(_ ma: Optional<A>) -> (Optional<B>) -> Optional<B> {
  { mb in identity <! ma <*> mb }
}

public func *> <A, B>(ea: Optional<A>, eb: Optional<B>) -> Optional<B> {
  appllySecond(ea)(eb)
}
// sourcery:end

// MARK: Applicative

public func pure<A>(_ a: A) -> Optional<A> { .some(a) }

// sourcery:inline:Optional.Applicative
public func when(_ when: Bool) -> (Optional<Unit>) -> Optional<Unit> {
  { e in when ? e : pure(unit) }
}

public func unless(_ unless: Bool) -> (Optional<Unit>) -> Optional<Unit> {
  { e in unless ? pure(unit) : e }
}
// sourcery:end

// MARK: Alt

public func alt<A>(_ left: Optional<A>) -> (Optional<A>) -> Optional<A> {
  { right in left ?? right }
}

// sourcery:inline:Optional.Alt
public func <|> <A>(left: Optional<A>, right: Optional<A>) -> Optional<A> {
  alt(left)(right)
}
// sourcery:end

// MARK: Either

// sourcery:inline:Optional.Either
public func choose<A, B>(_ ma: Optional<A>) -> (Optional<B>) -> Optional<Either<A, B>> {
  { mb in Either.left <!> ma <|> Either.right <!> mb }
}
// sourcery:end

// MARK: Plus

extension Optional {
  public static var empty: Optional { .none }
}

// MARK: Bind

public func flatMap<A, B>(_ m: Optional<A>) -> ((A) -> Optional<B>) -> Optional<B> {
  { f in m.flatMap(f) }
}

// sourcery:inline:Optional.Bind
public func >>- <A, B>(m: Optional<A>, a2mb: @escaping (A) -> Optional<B>) -> Optional<B> {
  flatMap(m)(a2mb)
}

public func flatMapFlipped<A, B>(_ a2m: @escaping (A) -> Optional<B>) -> (Optional<A>) -> Optional<B> {
  flip(flatMap)(a2m)
}

public func -<< <A, B>(a2m: @escaping (A) -> Optional<B>, m: Optional<A>) -> Optional<B> {
  m >>- a2m
}

public func join<A>(mm: Optional<Optional<A>>) -> Optional<A> {
  mm >>- identity
}

public func composeKleisli<A, B, C>(_ a2b: @escaping (A) -> Optional<B>) -> (@escaping (B) -> Optional<C>) -> (A) -> Optional<C> {
  { b2c in { a in a2b(a) >>- b2c } }
}

public func >-> <A, B, C>(a2b: @escaping (A) -> Optional<B>, b2c: @escaping (B) -> Optional<C>) -> (A) -> Optional<C> {
  composeKleisli(a2b)(b2c)
}

public func composeKleisliFlipped<A, B, C>(_ b2c: @escaping (B) -> Optional<C>) -> (@escaping (A) -> Optional<B>) -> (A) -> Optional<C> {
  flip(composeKleisli)(b2c)
}

public func <-< <A, B, C>(b2c: @escaping (B) -> Optional<C>, a2b: @escaping (A) -> Optional<B>) -> (A) -> Optional<C> {
  composeKleisliFlipped(b2c)(a2b)
}

public func ifM<A>(_ cond: Optional<Bool>) -> (Optional<A>) -> (Optional<A>) -> Optional<A> {
  { t in { f in cond >>- { $0 ? t : f } } }
}
// sourcery:end

// MARK: Monad

// sourcery:inline:Optional.Monad
public func whenM(_ mb: Optional<Bool>) -> (Optional<Unit>) ->  Optional<Unit> {
  { m in mb >>- { b in when(b)(m) } }
}

public func unlessM(_ mb: Optional<Bool>) -> (Optional<Unit>) ->  Optional<Unit> {
  { m in mb >>- { b in unless(b)(m) } }
}
// sourcery:end
