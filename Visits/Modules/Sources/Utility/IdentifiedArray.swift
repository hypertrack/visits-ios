import IdentifiedCollections

public extension IdentifiedArray {
  subscript(safeId safeId: ID?) -> Element? {
    guard let id = safeId else { return nil}
    return self[id: id]
  }
}
