import Foundation

// MARK: - Action

public enum VisitsAction: Equatable {
    case updateVisits(from: Date, to: Date, WorkerHandle)
    case visitsUpdated(VisitsData)
    case selectVisit(PlaceVisit?)
}
