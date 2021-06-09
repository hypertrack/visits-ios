public struct AffineM<S, T, A, B> {
  private let _extract: (S) -> A?
  private let _inject: (B) -> (S) -> T?
  
  public init(
    extract: @escaping (S) -> A?,
    inject: @escaping (B) -> (S) -> T?
  ) {
    self._extract = extract
    self._inject = inject
  }
  
  public func extract(from root: S) -> A? { _extract(root) }
  public func inject(_ value: B) -> (S) -> T? { _inject(value) }
}

public typealias Affine<Root, Value> = AffineM<Root, Root, Value, Value>

public extension AffineM where S == T, A == B {
  typealias Root = S
  typealias Value = A
}

public extension AffineM {
  func tryModify(_ f: @escaping (A) -> B) -> (S) -> T? {
    { s in extract(from: s).map(f).flatMap { b in inject(b)(s) } }
  }
  
  func appending<C, D>(_ affine: AffineM<A, B, C, D>) -> AffineM<S, T, C, D> {
    AffineM<S, T, C, D>(
      extract: extract >-> affine.extract,
      inject: { d in
                { s in
                  (extract(from: s) >>- affine.inject(d)) >>- { b in self.inject(b)(s) }
                }
              }
    )
  }
}

public extension LensM {
  func toAffine() -> AffineM<S, T, A, B> {
    AffineM<S, T, A, B>(extract: get, inject: set)
  }
  
  func appending<C, D>(_ affine: AffineM<A, B, C, D>) -> AffineM<S, T, C, D> {
    toAffine().appending(affine)
  }
  
  func appending<C, D>(_ prism: PrismM<A, B, C, D>) -> AffineM<S, T, C, D> {
    toAffine().appending(prism.toAffine())
  }
}

public extension PrismM {
  func toAffine() -> AffineM<S, T, A, B> {
    AffineM<S, T, A, B>(extract: extract, inject: constant >>> self.tryModify)
  }
  
  func appending<C, D>(_ affine: AffineM<A, B, C, D>) -> AffineM<S, T, C, D> {
    toAffine().appending(affine)
  }
  
  func appending<C, D>(_ lens: LensM<A, B, C, D>) -> AffineM<S, T, C, D> {
    toAffine().appending(lens.toAffine())
  }
}

// MARK: - Operators

public func *^? <S, T, A, B>(
  root: S,
  affine: AffineM<S, T, A, B>
) -> A? {
  affine.extract(from: root)
}

public func *<? <S, T, A, B>(
  affine: AffineM<S, T, A, B>,
  value: B
) -> (S) -> T? {
  affine.inject(value)
}

public func *~? <S, T, A, B>(
  affine: AffineM<S, T, A, B>,
  f: @escaping (A) -> B
) -> (S) -> T? {
  affine.tryModify(f)
}

public func ** <S, T, A, B, C, D>(
  left: AffineM<S, T, A, B>,
  right: AffineM<A, B, C ,D>
) -> AffineM<S, T, C, D> {
  left.appending(right)
}

public func ** <S, T, A, B, C, D>(
  lens: LensM<S, T, A, B>,
  affine: AffineM<A, B, C ,D>
) -> AffineM<S, T, C, D> {
  lens.appending(affine)
}

public func ** <Root, Value, AppendedValue>(
  writableKeyPath: WritableKeyPath<Root, Value>,
  affine: Affine<Value, AppendedValue>
) -> Affine<Root, AppendedValue> {
  writableKeyPath.lens().appending(affine)
}

public func ** <S, T, A, B, C, D>(
  lens: LensM<S, T, A, B>,
  prism: PrismM<A, B, C ,D>
) -> AffineM<S, T, C, D> {
  lens.appending(prism)
}

public func ** <Root, Value, AppendedValue>(
  writableKeyPath: WritableKeyPath<Root, Value>,
  prism: Prism<Value, AppendedValue>
) -> Affine<Root, AppendedValue> {
  writableKeyPath.lens().appending(prism)
}

public func ** <S, T, A, B, C, D>(
  prism: PrismM<S, T, A, B>,
  affine: AffineM<A, B, C ,D>
) -> AffineM<S, T, C, D> {
  prism.appending(affine)
}

public func ** <S, T, A, B, C, D>(
  prism: PrismM<S, T, A, B>,
  lens: LensM<A, B, C ,D>
) -> AffineM<S, T, C, D> {
  prism.appending(lens)
}

public func ** <Root, Value, AppendedValue>(
  prism: Prism<Root, Value>,
  writableKeyPath: WritableKeyPath<Value, AppendedValue>
) -> Affine<Root, AppendedValue> {
  prism.appending(writableKeyPath.lens())
}
