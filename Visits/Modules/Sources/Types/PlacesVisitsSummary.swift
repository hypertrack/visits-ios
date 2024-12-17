import Foundation
import NonEmpty


public struct PlacesVisitsSummary: Equatable {
    public var visits: [Place.Visit]

    public init(visits: [Place.Visit]) {
        self.visits = visits
    }
}
