import Foundation

public struct VisitsData: Equatable {
    public let from: Date
    public let to: Date
    public var summary: WorkerSummary
    public let visits: [PlaceVisit]

    public init(
        from: Date,
        to: Date,
        summary: WorkerSummary,
        visits: [PlaceVisit]
    ) {
        self.from = from
        self.to = to
        self.summary = summary
        self.visits = visits
    }

    public struct WorkerSummary: Decodable, Equatable {
        public var timeSpentInsideGeofences: Int
        public var totalDriveDistance: Int
        public var visitsNumber: Int
        public var visitedPlacesNumber: Int

        public init(
            timeSpentInsideGeofences: Int,
            totalDriveDistance: Int,
            visitsNumber: Int,
            visitedPlacesNumber: Int
        ) {
            self.timeSpentInsideGeofences = timeSpentInsideGeofences
            self.totalDriveDistance = totalDriveDistance
            self.visitsNumber = visitsNumber
            self.visitedPlacesNumber = visitedPlacesNumber
        }
    }
}

extension VisitsData.WorkerSummary {
    enum CodingKeys: String, CodingKey {
        case timeSpentInsideGeofences = "visit_duration"
        case totalDriveDistance = "tracked_distance"
        case visitsNumber = "visits"
        case visitedPlacesNumber = "geotags"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timeSpentInsideGeofences = try container.decodeIfPresent(Int.self, forKey: .timeSpentInsideGeofences) ?? 0
        totalDriveDistance = try container.decodeIfPresent(Int.self, forKey: .totalDriveDistance) ?? 0
        visitsNumber = try container.decodeIfPresent(Int.self, forKey: .visitsNumber) ?? 0
        visitedPlacesNumber = try container.decodeIfPresent(Int.self, forKey: .visitedPlacesNumber) ?? 0
    }
}
