public struct Path<Root, Value> {
  public let extract: (Root) -> Value?
  public let inject: (Value) -> (Root) -> Root?
  
  public init(
    extract: @escaping (Root) -> Value?,
    inject: @escaping (Value) -> (Root) -> Root?
  ) {
    self.extract = extract
    self.inject = inject
  }
}

// Extract
public func ?^ <Root, Value>(source: Root, path: Path<Root, Value>) -> Value? {
  source |> path.extract
}

// Inject
infix operator ?~: infixr6
public func ?~ <Root, Value>(path: Path<Root, Value>, value: Value) -> (Root) -> Root? {
  { root in root |> path.inject(value) }
}

public extension Path {
  func tryModify(_ f: @escaping (Value) -> Value) -> (Root) -> Root? {
    { r in self.extract(r).map(f).flatMap { v in self.inject(v)(r) } }
  }
  
  func hasValue(_ root: Root) -> Bool { extract(root) != nil }
  
  func appending <AppendedValue> (
    _ path: Path<Value, AppendedValue>
  ) -> Path<Root, AppendedValue> {
    .init(
      extract: { root in self.extract(root).flatMap(path.extract) },
      inject: { appendedValue in
        { root in
          self.extract(root)
            .flatMap { a in path.inject(appendedValue)(a) }
            .flatMap { b in self.inject(b)(root) }
        }
      }
    )
  }
  
  func modifyOrUnchanged(_ f: @escaping (Value) -> Value) -> (Root) -> Root {
    { r in self.tryModify(f)(r) ?? r }
  }
  
  static func zip <ValueA, ValueB> (
    _ pathA: Path<Root, ValueA>,
    _ pathB: Path<Root, ValueB>
  ) -> Path<Root, Inclusive<ValueA, ValueB>> where Value == Inclusive<ValueA, ValueB> {
    Path<Root, Inclusive<ValueA,ValueB>>(
      extract: { root in
        switch (pathA.extract(root), pathB.extract(root)) {
        case let (.some(aValue), .some(bValue)):
          return .some(.center(aValue, bValue))
        case let (.some(aValue), .none):
          return .some(.left(aValue))
        case let (.none, .some(bValue)):
          return .some(.right(bValue))
        case (.none, .none):
          return .none
        }
    },
      inject: { inclusive in
        { root in
          switch inclusive {
          case let .left(value):
            return pathA.inject(value)(root)
          case let .right(value):
            return pathB.inject(value)(root)
          case let .center(aValue, bValue):
            return Optional.some(root)
              .flatMap(pathA.inject(aValue))
              .flatMap(pathB.inject(bValue))
          }
        }
    })
  }
}

// Try Modify
public func %? <Root, Value>(
  path: Path<Root, Value>,
  f: @escaping (Value) -> Value
) -> (Root) -> Root? {
  path.tryModify(f)
}

// Modify or Unchanged
public func %- <Root, Value>(
  path: Path<Root, Value>,
  f: @escaping (Value) -> Value
) -> (Root) -> Root {
  path.modifyOrUnchanged(f)
}

// Inject or Unchanged
public func .- <Root, Value>(
  path: Path<Root, Value>,
  value: Value
) -> (Root) -> Root {
  path.modifyOrUnchanged(const(value))
}

// Append
public func >>> <Root, Value, AppendedValue> (
  lhs: Path<Root, Value>,
  rhs: Path<Value, AppendedValue>
) -> Path<Root, AppendedValue> {
  lhs.appending(rhs)
}

// PropertyPath
public extension PropertyPath {
  func toPath() -> Path<Root, Value> {
    .init(
      extract: self.get,
      inject: self.set
    )
  }
  
  func appending <AppendedValue> (
    _ path: Path<Value, AppendedValue>
  ) -> Path<Root, AppendedValue> {
    toPath().appending(path)
  }
  
  func appending <AppendedValue> (
    _ casePath: CasePath<Value, AppendedValue>
  ) -> Path<Root, AppendedValue> {
    toPath().appending(casePath.toPath())
  }
}

public func >>> <Root, Value, AppendedValue> (
  propertyPath: PropertyPath<Root, Value>,
  path: Path<Value, AppendedValue>
) -> Path<Root, AppendedValue> {
  propertyPath.appending(path)
}

public func >>> <Root, Value, AppendedValue> (
  writableKeyPath: WritableKeyPath<Root, Value>,
  path: Path<Value, AppendedValue>
) -> Path<Root, AppendedValue> {
  writableKeyPath.propertyPath().appending(path)
}

public func >>> <Root, Value, AppendedValue> (
  propertyPath: PropertyPath<Root, Value>,
  casePath: CasePath<Value, AppendedValue>
) -> Path<Root, AppendedValue> {
  propertyPath.appending(casePath)
}

public func >>> <Root, Value, AppendedValue> (
  writableKeyPath: WritableKeyPath<Root, Value>,
  casePath: CasePath<Value, AppendedValue>
) -> Path<Root, AppendedValue> {
  writableKeyPath.propertyPath().appending(casePath)
}

// CasePath
public extension CasePath {
  func toPath() -> Path<Root, Value> {
    Path<Root, Value>.init(
      extract: self.extract,
      inject: const >>> self.tryModify
    )
  }
  
  func appending <AppendedValue> (
    _ path: Path<Value, AppendedValue>
  ) -> Path<Root, AppendedValue> {
    toPath().appending(path)
  }
  
  func appending <AppendedValue> (
    _ propertyPath: PropertyPath<Value, AppendedValue>
  ) -> Path<Root, AppendedValue> {
    toPath().appending(propertyPath.toPath())
  }
}

public func >>> <Root, Value, AppendedValue> (
  casePath: CasePath<Root, Value>,
  path: Path<Value, AppendedValue>
) -> Path<Root, AppendedValue> {
  casePath.appending(path)
}

public func >>> <Root, Value, AppendedValue> (
  casePath: CasePath<Root, Value>,
  propertyPath: PropertyPath<Value, AppendedValue>
) -> Path<Root, AppendedValue> {
  casePath.appending(propertyPath)
}

public func >>> <Root, Value, AppendedValue> (
  casePath: CasePath<Root, Value>,
  writableKeyPath: WritableKeyPath<Value, AppendedValue>
) -> Path<Root, AppendedValue> {
  casePath.appending(writableKeyPath.propertyPath())
}
