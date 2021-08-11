public enum IntegrationStatus: Equatable {
  case unknown
  case requesting
  case integrated(RefreshingIntegrationEntities)
  case notIntegrated
}

public enum RefreshingIntegrationEntities: Equatable {
  case refreshing(IntegrationEntity.Search)
  case notRefreshing
}
