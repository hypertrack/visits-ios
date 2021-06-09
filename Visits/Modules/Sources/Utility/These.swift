public enum These<A, B> {
  case this(A)
  case that(B)
  case both(A, B)
}

public func these<A, B, C>(
  _ l: @escaping (A) -> C
) -> (@escaping (B) -> C) -> (@escaping (A) -> (B) -> C) -> (These<A, B>) -> C {
  { r in
    { lr in
      { t in
        switch t {
        case let .this(a):    return l(a)
        case let .that(b):    return r(b)
        case let .both(a, b): return lr(a)(b)
        }
      }
    }
  }
}

public func thisOrBoth<A, B>(
  _ a: A
) -> (B?) -> These<A, B> {
  { b in
    switch b {
    case .none:        return .this(a)
    case let .some(b): return .both(a, b)
    }
  }
}

public func thatOrBoth<A, B>(
  _ b: B
) -> (A?) -> These<A, B> {
  { a in
    switch a {
    case .none:        return .that(b)
    case let .some(a): return .both(a, b)
    }
  }
}

public func maybeThese<A, B>(
  _ a: A?
) -> (B?) -> These<A, B>? {
  { b in
    switch (a, b) {
    case     (.none,    .none):    return nil
    case let (.some(a), .none):    return .this(a)
    case let (.none,    .some(b)): return .that(b)
    case let (.some(a), .some(b)): return .both(a, b)
    }
  }
}

public func fromThese<A, B>(
  _ a: A
) -> (B) -> (These<A, B>) -> (A, B) {
  { b in
    { t in
      switch t {
      case let .this(a):    return (a, b)
      case let .that(b):    return (a, b)
      case let .both(a, b): return (a, b)
      }
    }
  }
}

public func theseLeft<A, B>(_ t: These<A, B>) -> A? {
  switch t {
  case .that:                         return nil
  case let .this(a), let .both(a, _): return a
  }
}

public func theseRight<A, B>(_ t: These<A, B>) -> B? {
  switch t {
  case .this:                         return nil
  case let .that(b), let .both(_, b): return b
  }
}

public func addThis<A, B>(_ a: A) -> (These<A, B>) -> These<A, B> {
  { t in
    switch t {
    case     .this:       return .this(a)
    case let .that(b):    return .both(a, b)
    case let .both(_, b): return .both(a, b)
    }
  }
}

public func addThat<A, B>(_ b: B) -> (These<A, B>) -> These<A, B> {
  { t in
    switch t {
    case let .this(a):    return .both(a, b)
    case     .that:       return .that(b)
    case let .both(a, _): return .both(a, b)
    }
  }
}

public func removeThis<A, B>(_ t: These<A, B>) -> These<A, B>? {
  switch t {
  case     .this:       return nil
  case     .that:       return t
  case let .both(_, b): return .that(b)
  }
}

public func removeThat<A, B>(_ t: These<A, B>) -> These<A, B>? {
  switch t {
  case     .this:       return t
  case     .that:       return nil
  case let .both(a, _): return .this(a)
  }
}

// MARK: - Equatable

extension These: Equatable where A: Equatable, B: Equatable {}

// MARK: - Comparable

extension These: Comparable where A: Comparable, B: Comparable {}

// MARK: - Codable

extension These: Codable where A: Codable, B: Codable {
  enum CodingKeys: CodingKey {
    case this, that, both
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let key = container.allKeys.first
    
    switch key {
    case .none:
      throw DecodingError.dataCorrupted(
        DecodingError.Context(
          codingPath: container.codingPath,
          debugDescription: "Unable to decode These"
        )
      )
    case .some(.this):
      let a = try container.decode(A.self, forKey: .this)
      self = .this(a)
    case .some(.that):
      let b = try container.decode(B.self, forKey: .that)
      self = .that(b)
    case .some(.both):
      var nestedContainer = try container.nestedUnkeyedContainer(forKey: .both)
      let a = try nestedContainer.decode(A.self)
      let b = try nestedContainer.decode(B.self)
      self = .both(a, b)
    }
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    switch self {
    case let .this(a):
      try container.encode(a, forKey: .this)
    case let .that(b):
      try container.encode(b, forKey: .that)
    case let .both(a, b):
      var nestedContainer = container.nestedUnkeyedContainer(forKey: .both)
      try nestedContainer.encode(a)
      try nestedContainer.encode(b)
    }
  }
}

// MARK: - Hashable

extension These: Hashable where A: Hashable, B: Hashable {}
