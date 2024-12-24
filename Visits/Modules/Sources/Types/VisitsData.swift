import Foundation

public struct VisitsData: Equatable {
    public let from: Date
    public let to: Date
    public let visits: [PlaceVisit]

    public init(
        from: Date,
        to: Date,
        visits: [PlaceVisit]
    ) {
        self.from = from
        self.to = to
        self.visits = visits
    }
}
