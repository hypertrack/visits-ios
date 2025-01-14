import Foundation

public struct TeamWorkerData: Equatable {
    public var from: Date
    public let name: String?
    public var selectedVisit: PlaceVisit?
    public var to: Date
    public var visits: VisitsData?
    public let workerHandle: WorkerHandle

    public init(
        from: Date,
        name: String?,
        selectedVisit: PlaceVisit?,
        to: Date,
        visits: VisitsData?,
        workerHandle: WorkerHandle
    ) {
        self.from = from
        self.name = name
        self.selectedVisit = selectedVisit
        self.to = to
        self.visits = visits
        self.workerHandle = workerHandle
    }
}
