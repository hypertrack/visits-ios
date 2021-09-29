public extension Set {
  static func insert(_ newMember: Element) -> (Self) -> Self {
    { set in
      var set = set
      set.insert(newMember)
      return set
    }
  }

  func updated(with new: Set<Element>) -> Set<Element> {
    var updated = new
    self.forEach { updated.insert($0) }
    return updated
  }
}
