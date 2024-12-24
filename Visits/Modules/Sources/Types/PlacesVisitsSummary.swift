import Foundation
import NonEmpty


public struct PlacesVisitsSummary: Equatable {
    public var visits: [PlaceVisit]

    public init(visits: [PlaceVisit]) {
        self.visits = visits
    }
}
