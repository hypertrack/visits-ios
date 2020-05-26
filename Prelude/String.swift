extension String {
  public func clean() -> String {
    components(separatedBy: .whitespacesAndNewlines)
      .joined()
  }
}
