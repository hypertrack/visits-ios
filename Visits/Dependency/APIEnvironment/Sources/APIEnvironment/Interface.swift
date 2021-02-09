import ComposableArchitecture
import Coordinate
import Credentials
import DeviceID
import History
import NonEmpty
import Prelude
import PublishableKey
import Tagged
import Visit

public typealias APIVisitID = Tagged<APIVisitIDTag, NonEmptyString>
public enum APIVisitIDTag {}

public enum APIError: Equatable, Error { case unknown }

public enum VisitStatus: Equatable {
  case entered(Date)
  case visited(Date, Date)
}

public struct APIVisit: Equatable {
  public enum Source: Equatable { case trip, geofence }
  
  public typealias Name     = Tagged<(APIVisit, name: ()),     NonEmptyString>
  public typealias Contents = Tagged<(APIVisit, contents: ()), NonEmptyString>
  
  public let centroid: Coordinate
  public let createdAt: Date
  public let metadata: [Name: Contents]
  public let source: Source
  public let visitStatus: VisitStatus?
  
  public init(
    centroid: Coordinate,
    createdAt: Date,
    metadata: [Name: Contents],
    source: Source,
    visited: VisitStatus?
  ) {
    self.centroid = centroid
    self.createdAt = createdAt
    self.metadata = metadata
    self.source = source
    self.visitStatus = visited
  }
}

public struct APIEnvironment {
  public var getHistory: (PublishableKey, DeviceID, Date) -> Effect<Result<History, APIError>, Never>
  public var getVisits: (PublishableKey, DeviceID) -> Effect<Result<[APIVisitID: APIVisit], APIError>, Never>
  public var reverseGeocode: ([Coordinate]) -> Effect<[(Coordinate, These<AssignedVisit.Street, AssignedVisit.FullAddress>?)], Never>
  public var signIn: (Email, Password) -> Effect<Result<PublishableKey, APIError>, Never>
  
  public init(
    getHistory: @escaping (PublishableKey, DeviceID, Date) -> Effect<Result<History, APIError>, Never>,
    getVisits: @escaping (PublishableKey, DeviceID) -> Effect<Result<[APIVisitID: APIVisit], APIError>, Never>,
    reverseGeocode: @escaping ([Coordinate]) -> Effect<[(Coordinate, These<AssignedVisit.Street, AssignedVisit.FullAddress>?)], Never>,
    signIn: @escaping (Email, Password) -> Effect<Result<PublishableKey, APIError>, Never>
  ) {
    self.getHistory = getHistory
    self.getVisits = getVisits
    self.reverseGeocode = reverseGeocode
    self.signIn = signIn
  }
}
