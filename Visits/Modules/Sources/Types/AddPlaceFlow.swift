public enum AddPlaceFlow: Equatable {
  case choosingCoordinate(Coordinate?, [IntegrationEntity])
  case choosingIntegration(Coordinate, Search, SearchingIntegrationEntities, [IntegrationEntity])
  case addingPlace(Coordinate, IntegrationEntity, Search, [IntegrationEntity])
}


public enum SearchingIntegrationEntities: Equatable {
  case refreshing
  case notRefreshing
}
