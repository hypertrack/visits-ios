public struct PropertyPath<Root, Value> {
  public let get: (Root) -> Value
  public let set: (Value) -> (Root) -> Root
  
  public init(
    get: @escaping (Root) -> Value,
    set: @escaping (Value) -> (Root) -> Root
  ) {
    self.get = get
    self.set = set
  }
}

// Get
infix operator .^: infixl8
public func .^ <Root, Value>(
  root: Root,
  propertyPath: PropertyPath<Root, Value>
) -> Value {
  root |> propertyPath.get
}

public func .^ <Root, Value>(
  root: Root,
  keyPath: KeyPath<Root, Value>
) -> Value {
  root[keyPath: keyPath]
}

// Set
infix operator .~: infixr6
public func .~ <Root, Value>(
  propertyPath: PropertyPath<Root, Value>,
  value: Value
) -> (Root) -> Root {
  propertyPath.set(value)
}

public func .~ <Root, Value>(
  writableKeyPath: WritableKeyPath<Root, Value>,
  value: Value
) -> (Root) -> Root {
  writableKeyPath.propertyPath().set(value)
}


public extension PropertyPath {
  func modify(_ f: @escaping (Value) -> Value) -> (Root) -> Root {
    { root in self.set(f(self.get(root)))(root) }
  }
  
  func appending <AppendedValue> (
    _ propertyPath: PropertyPath<Value, AppendedValue>
  ) -> PropertyPath<Root, AppendedValue> {
    PropertyPath<Root, AppendedValue>.init(
      get: { propertyPath.get(self.get($0)) },
      set: { value in
        { root in
          self.set(propertyPath.set(value)(self.get(root)))(root)
        }
    })
  }
}

// Modify
infix operator %~: infixr6
public func %~ <Root, Value>(
  propertyPath: PropertyPath<Root, Value>,
  f: @escaping (Value) -> Value
) -> (Root) -> Root {
  propertyPath.modify(f)
}

public func %~ <Root, Value>(
  writableKeyPath: WritableKeyPath<Root, Value>,
  f: @escaping (Value) -> Value
) -> (Root) -> Root {
  writableKeyPath.propertyPath().modify(f)
}

// Append
public func >>> <Root, Value, AppendedValue> (
  left: PropertyPath<Root, Value>,
  right: PropertyPath<Value, AppendedValue>
) -> PropertyPath<Root, AppendedValue> {
  left.appending(right)
}


public extension WritableKeyPath {
  func propertyPath() -> PropertyPath<Root,Value> {
    PropertyPath<Root,Value>.init(
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

// Lift WritableKeyPath to PropertyPath
prefix operator ^
public prefix func ^ <Root,Value> (
  writableKeyPath: WritableKeyPath<Root,Value>
) -> PropertyPath<Root,Value> {
  writableKeyPath.propertyPath()
}
