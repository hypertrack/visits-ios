import Foundation
import NonEmpty
import Tagged
import Types


public typealias APIOrderID = Tagged<APIOrderIDTag, NonEmptyString>
public enum APIOrderIDTag {}

public struct APIOrder: Equatable {
  public enum Source: Equatable { case order, trip }
  
  public typealias Name     = Tagged<(APIOrder, name: ()),     NonEmptyString>
  public typealias Contents = Tagged<(APIOrder, contents: ()), NonEmptyString>
  
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

public enum VisitStatus: Equatable {
  case entered(Date)
  case visited(Date, Date)
}

public struct ResendVerificationSuccess: Equatable {
  public init() {}
}

public struct SignUpSuccess: Equatable {
  public init() {}
}

public enum ResendVerificationError: Equatable {
  case alreadyVerified
  case error(CognitoError)
}

public enum VerificationError: Equatable {
  case alreadyVerified
  case error(CognitoError)
}
