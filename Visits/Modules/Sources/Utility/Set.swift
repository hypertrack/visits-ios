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

public extension Set where Element: Identifiable {
  func updatedById(with new: Set<Element>) -> Set<Element> {
    var updated = new
    self.forEach { element in
        if !updated.contains(where: { $0.id == element.id }) {
          updated.insert(element)
        }
    }
    return updated
  }
}
