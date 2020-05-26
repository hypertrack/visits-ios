// Extract
infix operator ?^: infixl8
public func ?^ <Root, Value>(
  source: Root,
  casePath: CasePath<Root, Value>
) -> Value? {
  source |> casePath.extract
}

// Embed
public func .~ <Root, Value>(
  casePath: CasePath<Root, Value>,
  value: Value
) -> (Root) -> Root {
  { _ in value |> casePath.embed }
}


public extension CasePath {
  func tryModify(_ f: @escaping (Value) -> Value) -> (Root) -> Root? {
    { root in
      guard let a = self.extract(from: root) else { return nil }
      return self.embed(f(a))
    }
  }
  
  func isCase(_ root: Root) -> Bool {
    extract(from: root) != nil
  }
  
  func modifyOrUnchanged(
    _ transform: @escaping (Value) -> Value
  ) -> (Root) -> Root {
    { root in
      guard let value = self.extract(from: root) else { return root }
      return self.embed(transform(value))
    }
  }
  
  static func zip <ValueA,ValueB> (
    _ a: CasePath<Root,ValueA>,
    _ b: CasePath<Root,ValueB>
  ) -> CasePath<Root, Either<ValueA,ValueB>> where Value == Either<ValueA, ValueB> {
    CasePath<Root, Either<ValueA, ValueB>>(
      embed: { $0 |> either(a.embed, b.embed) },
      extract: { a.extract(from: $0).map(Either.left) ?? b.extract(from: $0).map(Either.right) }
    )
  }
}

// Try Modify
infix operator %? : infixr6
public func %? <Root, Value>(
  casePath: CasePath<Root, Value>,
  f: @escaping (Value) -> Value
) -> (Root) -> Root? {
  casePath.tryModify(f)
}

// Modify or Unchanged
infix operator %- : infixr6
public func %- <Root, Value>(
  casePath: CasePath<Root, Value>,
  f: @escaping (Value) -> Value
) -> (Root) -> Root {
  casePath.modifyOrUnchanged(f)
}

// Embed or Unchanged
infix operator .- : infixr6
public func .- <Root, Value>(
  casePath: CasePath<Root, Value>,
  value: Value
) -> (Root) -> Root {
  casePath.modifyOrUnchanged(const(value))
}

// Append
public func >>> <Root, Value, AppendedValue> (
  left: CasePath<Root, Value>,
  right: CasePath<Value, AppendedValue>
) -> CasePath<Root, AppendedValue> {
  left.appending(path: right)
}

public extension Optional {
  static var casePath: CasePath<Optional, Wrapped> {
    CasePath<Optional, Wrapped>(
      embed: Optional.some,
      extract: { $0 }
    )
  }
}

