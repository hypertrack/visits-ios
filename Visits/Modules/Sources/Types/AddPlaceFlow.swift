import NonEmpty
import Utility


public enum AddPlaceFlow: Equatable {
  case choosingCoordinate(GeocodedResult?, [IntegrationEntity])
  case choosingAddress(Coordinate, Street?, LocalSearchCompletion?, [LocalSearchCompletion], [IntegrationEntity])
  case confirmingLocation(Coordinate, Street, LocalSearchCompletion, NonEmptyArray<MapPlace>, [LocalSearchCompletion], [IntegrationEntity])
  case choosingIntegration(Coordinate, Address, IntegrationEntity.Search, SearchingIntegrationEntities, [IntegrationEntity])
  case addingPlace(Coordinate, Address, IntegrationEntity, [IntegrationEntity])
}

public extension AddPlaceFlow {
  static let integrationEntitiesLens = Lens<Self, [IntegrationEntity]>(
    get: { s in
      switch s {
      case let .choosingCoordinate(_, ies):             return ies
      case let .choosingAddress(_, _, _, _, ies):       return ies
      case let .confirmingLocation(_, _, _, _, _, ies): return ies
      case let .choosingIntegration(_, _, _, _, ies):   return ies
      case let .addingPlace(_, _, _, ies):              return ies
      }
    },
    set: { ies in
      { s in
        switch s {
        case let .choosingCoordinate(gr, _):                 return .choosingCoordinate(gr, ies)
        case let .choosingAddress(c, st, ls, lss, _):        return .choosingAddress(c, st, ls, lss, ies)
        case let .confirmingLocation(c, s, ls, mps, lss, _): return .confirmingLocation(c, s, ls, mps, lss, ies)
        case let .choosingIntegration(c, a, s, r, _):        return .choosingIntegration(c, a, s, r, ies)
        case let .addingPlace(c, a, ie, _):                  return .addingPlace(c, a, ie, ies)
        }
      }
    }
  )
}

public enum SearchingIntegrationEntities: Equatable {
  case refreshing
  case notRefreshing
}
