public func resultSuccess<S, F>(_ r: Result<S, F>) -> S? {
  switch r {
  case let .success(s): return s
  case     .failure:    return nil
  }
}

public func resultFailure<S, F>(_ r: Result<S, F>) -> F? {
  switch r {
  case     .success:    return nil
  case let .failure(f): return f
  }
}
