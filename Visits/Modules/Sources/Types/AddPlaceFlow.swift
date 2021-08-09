import Utility


public enum AddPlaceFlow: Equatable {
  case choosingCoordinate(GeocodedResult?, [IntegrationEntity])
  case choosingIntegration(Coordinate, Street?, Search, SearchingIntegrationEntities, [IntegrationEntity])
  case addingPlace(Coordinate, Street?, IntegrationEntity, Search, [IntegrationEntity])
}

public enum SearchingIntegrationEntities: Equatable {
  case refreshing
  case notRefreshing
}
