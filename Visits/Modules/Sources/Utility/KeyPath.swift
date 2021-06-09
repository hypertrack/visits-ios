// MARK: - Lens

public func *^ <Root, Value>(
  root: Root,
  keyPath: KeyPath<Root, Value>
) -> Value {
  root[keyPath: keyPath]
}

public func *< <Root, Value>(
  writableKeyPath: WritableKeyPath<Root, Value>,
  value: Value
) -> (Root) -> Root {
  writableKeyPath.lens().set(value)
}

public prefix func ^ <Root,Value> (
  writableKeyPath: WritableKeyPath<Root,Value>
) -> Lens<Root,Value> {
  writableKeyPath.lens()
}

public extension WritableKeyPath {
  func lens() -> Lens<Root,Value> {
    Lens<Root,Value>.init(
      get: { $0[keyPath: self] },
      set: { part in
        { whole in
          var m = whole
          m[keyPath: self] = part
          return m
        }
    })
  }
}
