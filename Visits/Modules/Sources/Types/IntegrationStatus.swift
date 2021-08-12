public enum IntegrationStatus: Equatable {
  case unknown
  case requesting
  case integrated(RefreshingIntegrationEntities)
  case notIntegrated
}

public enum RefreshingIntegrationEntities: Equatable {
  case refreshing(IntegrationSearch)
  case notRefreshing
}
