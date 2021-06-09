// sourcery: functor, apply, applicative, alt, either, bind, monad
extension Array {}

// MARK: - Category Theory
// MARK: Functor

public func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
  { m in m.map(f) }
}

// sourcery:inline:Array.Functor
public func <!> <A, B>(f: @escaping (A) -> B, m: Array<A>) -> Array<B> {
    map(f)(m)
}

public func mapFlipped<A, B>(_ m: Array<A>) -> (@escaping (A) -> B) -> Array<B> {
  { f in map(f)(m) }
}

public func <¡> <A, B>(m: Array<A>, f: @escaping (A) -> B) -> Array<B> {
  mapFlipped(m)(f)
}

public func replaceWithLeft<A, B>(_ b: B) -> (Array<A>) -> Array<B> {
  b |> constant >>> map
}

public func <! <A, B>(a: B, m: Array<A>) -> Array<B> {
  replaceWithLeft(a)(m)
}

public func replaceWithRight<A, B>(_ m: Array<A>) -> (B) -> Array<B> {
  { a in constant(a) <!> m }
}

public func !> <A, B>(m: Array<A>, a: B) -> Array<B> {
  replaceWithRight(m)(a)
}

public func replaceWithVoid<A>(_ m: Array<A>) -> Array<Void> {
  () <! m
}

public func flip<A, B>(_ ef: Array<(A) -> B>) -> (A) -> Array<B> {
  { r in map { $0(r) } <| ef }
}

public func >!< <A, B>(ef: Array<(A) -> B>, r: A) -> Array<B> {
  flip(ef)(r)
}
// sourcery:end

// MARK: Apply

public func apply<A, B>(_ mf: [(A) -> B]) -> ([A]) -> [B] {
  { m in
    zip(mf, m).map { (f, a) in
      f(a)
    }
  }
}

// sourcery:inline:Array.Apply
public func <*> <A, B>(mf: Array<(A) -> B>, m: Array<A>) -> Array<B> {
  apply(mf)(m)
}

public func applyFirst<A, B>(_ m: Array<A>) -> (Array<B>) -> Array<A> {
  { ma in constant <!> m <*> ma }
}

public func <* <A, B>(m: Array<A>, ma: Array<B>) -> Array<A> {
  applyFirst(m)(ma)
}

public func appllySecond<A, B>(_ ma: Array<A>) -> (Array<B>) -> Array<B> {
  { mb in identity <! ma <*> mb }
}

public func *> <A, B>(ea: Array<A>, eb: Array<B>) -> Array<B> {
  appllySecond(ea)(eb)
}
// sourcery:end

// MARK: Applicative

public func pure<A>(_ a: A) -> [A] { [a] }

// sourcery:inline:Array.Applicative
public func when(_ when: Bool) -> (Array<Unit>) -> Array<Unit> {
  { e in when ? e : pure(unit) }
}

public func unless(_ unless: Bool) -> (Array<Unit>) -> Array<Unit> {
  { e in unless ? pure(unit) : e }
}
// sourcery:end

// MARK: Alt

public func alt<A>(_ left: [A]) -> ([A]) -> [A] {
  { right in
    var left = left
    left.append(contentsOf: right)
    return left
  }
}

// sourcery:inline:Array.Alt
public func <|> <A>(left: Array<A>, right: Array<A>) -> Array<A> {
  alt(left)(right)
}
// sourcery:end

// MARK: Either

// sourcery:inline:Array.Either
public func choose<A, B>(_ ma: Array<A>) -> (Array<B>) -> Array<Either<A, B>> {
  { mb in Either.left <!> ma <|> Either.right <!> mb }
}
// sourcery:end

// MARK: Plus

extension Array {
  public static var empty: Array { [] }
}

// MARK: Bind

public func flatMap<A, B>(_ m: [A]) -> ((A) -> [B]) -> [B] {
  { f in m.flatMap(f) }
}

// sourcery:inline:Array.Bind
public func >>- <A, B>(m: Array<A>, a2mb: @escaping (A) -> Array<B>) -> Array<B> {
  flatMap(m)(a2mb)
}

public func flatMapFlipped<A, B>(_ a2m: @escaping (A) -> Array<B>) -> (Array<A>) -> Array<B> {
  flip(flatMap)(a2m)
}

public func -<< <A, B>(a2m: @escaping (A) -> Array<B>, m: Array<A>) -> Array<B> {
  m >>- a2m
}

public func join<A>(mm: Array<Array<A>>) -> Array<A> {
  mm >>- identity
}

public func composeKleisli<A, B, C>(_ a2b: @escaping (A) -> Array<B>) -> (@escaping (B) -> Array<C>) -> (A) -> Array<C> {
  { b2c in { a in a2b(a) >>- b2c } }
}

public func >-> <A, B, C>(a2b: @escaping (A) -> Array<B>, b2c: @escaping (B) -> Array<C>) -> (A) -> Array<C> {
  composeKleisli(a2b)(b2c)
}

public func composeKleisliFlipped<A, B, C>(_ b2c: @escaping (B) -> Array<C>) -> (@escaping (A) -> Array<B>) -> (A) -> Array<C> {
  flip(composeKleisli)(b2c)
}

public func <-< <A, B, C>(b2c: @escaping (B) -> Array<C>, a2b: @escaping (A) -> Array<B>) -> (A) -> Array<C> {
  composeKleisliFlipped(b2c)(a2b)
}

public func ifM<A>(_ cond: Array<Bool>) -> (Array<A>) -> (Array<A>) -> Array<A> {
  { t in { f in cond >>- { $0 ? t : f } } }
}
// sourcery:end


// MARK: Monad

// sourcery:inline:Array.Monad
public func whenM(_ mb: Array<Bool>) -> (Array<Unit>) ->  Array<Unit> {
  { m in mb >>- { b in when(b)(m) } }
}

public func unlessM(_ mb: Array<Bool>) -> (Array<Unit>) ->  Array<Unit> {
  { m in mb >>- { b in unless(b)(m) } }
}
// sourcery:end
