import Foundation

public struct VisitsData: Equatable {
    public let from: Date
    public let to: Date
    public let visits: [Place.Visit]

    public init(
        from: Date,
        to: Date,
        visits: [Place.Visit]
    ) {
        self.from = from
        self.to = to
        self.visits = visits
    }
}
