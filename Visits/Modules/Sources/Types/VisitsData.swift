import Foundation

public struct VisitsData: Equatable {
    public let from: Date
    public let to: Date
    public let summary: WorkerSummary
    public var visits: [PlaceVisit]
    public let workerHandle: WorkerHandle

    public init(
        from: Date,
        to: Date,
        summary: WorkerSummary,
        visits: [PlaceVisit],
        workerHandle: WorkerHandle
    ) {
        self.from = from
        self.to = to
        self.summary = summary
        self.visits = visits
        self.workerHandle = workerHandle
    }

    public struct WorkerSummary: Equatable {
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

