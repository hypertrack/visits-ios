import APIEnvironment
import Combine
import ComposableArchitecture
import Foundation
import LogEnvironment
import NonEmpty
import Tagged
import Types
import Utility

let keyL1 = "l1_manager"
let keyL2 = "l2_manager"

func getTeam(_ token: Token.Value, _ wh: WorkerHandle) -> Effect<Result<TeamValue?, APIError<Token.Expired>>, Never> {
    return getWorker(token, wh).map { result in
        result.map { worker in
            WorkerHierarchyMetadata.parse(metadata: worker.profile)
        }
    }.flatMap { (result: Result<WorkerHierarchyMetadata?, APIError<Token.Expired>>) -> Effect<Result<TeamValue?, APIError<Token.Expired>>, Never> in
        switch result {
        case let .failure(f):
            return Effect<Result<TeamValue?, APIError<Token.Expired>>, Never>(value: .failure(f))
        case let .success(hierarchy):
            switch hierarchy {
            case .noHierarchyData:
                return Effect(value: .success(nil as TeamValue?))
            case .l2Manager:
                return getL2ManagerTeam(token, wh).map { teamResult in
                    teamResult.map {
                        $0 as TeamValue?
                    }
                }
            case .l1Manager:
                return getL1ManagerTeam(token, wh, "").map { teamResult in
                    teamResult.map {
                        $0 as TeamValue?
                    }
                }
            case .l0Worker:
                return Effect(value: .success(nil as TeamValue?))
            case .none:
                return Effect<Result<TeamValue?, APIError<Token.Expired>>, Never>(value: .success(nil as TeamValue?))
            }
        }
    }.eraseToEffect()
}

enum WorkerHierarchyMetadata {
    case noHierarchyData
    case l2Manager
    // param is l2Manager
    case l1Manager(WorkerHandle?)
    // params are l1Manager, l2Manager
    case l0Worker(WorkerHandle?, WorkerHandle?)
}

extension WorkerHierarchyMetadata {
    static func parse(metadata: JSON.Object?) -> WorkerHierarchyMetadata {
        guard let metadata = metadata else {
            return .noHierarchyData
        }
        let level = metadata["employee_level"]
        let l1Manager = metadata[keyL1]
        let l2Manager = metadata[keyL2]

        if let levelValue = level, case let JSON.string(level) = levelValue
        //    let l1ManagerValue = l1Manager, case let JSON.string(l1Manager) = l1ManagerValue,
        //    let l2ManagerValue = l2Manager, case let JSON.string(l2Manager) = l2ManagerValue
        {
            switch level {
            case "l0":
                let l1ManagerWh: WorkerHandle?, l2ManagerWh: WorkerHandle?

                if let l1ManagerValue = l1Manager,
                   case let JSON.string(l1ManagerString) = l1ManagerValue,
                   let l1ManagerNonEmptyString = NonEmptyString(rawValue: l1ManagerString)
                {
                    l1ManagerWh = WorkerHandle(rawValue: l1ManagerNonEmptyString)
                } else {
                    l1ManagerWh = nil
                }
                if let l2ManagerValue = l2Manager,
                   case let JSON.string(l2ManagerString) = l2ManagerValue,
                   let l2ManagerNonEmptyString = NonEmptyString(rawValue: l2ManagerString)
                {
                    l2ManagerWh = WorkerHandle(rawValue: l2ManagerNonEmptyString)
                } else {
                    l2ManagerWh = nil
                }

                return .l0Worker(l1ManagerWh, l2ManagerWh)
            case "l1":
                let l2ManagerWh: WorkerHandle?
                if let l2ManagerValue = l2Manager,
                   case let JSON.string(l2ManagerString) = l2ManagerValue,
                   let l2ManagerNonEmptyString = NonEmptyString(rawValue: l2ManagerString)
                {
                    l2ManagerWh = WorkerHandle(rawValue: l2ManagerNonEmptyString)
                } else {
                    l2ManagerWh = nil
                }

                return .l1Manager(l2ManagerWh)
            case "l2":
                return .l2Manager
            default:
                // todo fail here
                return .noHierarchyData
            }
        } else {
            // todo fail here if non-null
            return .noHierarchyData
        }
    }
}

func getL2ManagerTeam(_ token: Token.Value, _ managerWorkerHandle: WorkerHandle) -> Effect<Result<TeamValue, APIError<Token.Expired>>, Never> {
    let profileFilter = JSON.object(
        [
            keyL2: JSON.string(managerWorkerHandle.rawValue.rawValue),
        ]
    )
    return getWorkers(token, profileFilter: profileFilter, paginationToken: nil)
        .map { result in
            result.map { workers in
                workers.compactMap { worker in
                    let hierarchy = WorkerHierarchyMetadata.parse(metadata: worker.profile)
                    switch hierarchy {
                    // todo log error
                    case .noHierarchyData, .l2Manager:
                        return nil
                    case .l1Manager, .l0Worker:
                        return (worker.workerHandle, hierarchy, worker.name)
                    }
                }
            }.map {
                createL2Manager(managerWorkerHandle, $0)
            }
        }
}

func getL1ManagerTeam(_ token: Token.Value, _ managerWorkerHandle: WorkerHandle, _ managerName: String?) -> Effect<Result<TeamValue, APIError<Token.Expired>>, Never> {
    let profileFilter = JSON.object(
        [
            keyL1: JSON.string(managerWorkerHandle.rawValue.rawValue),
        ]
    )
    return getWorkers(token, profileFilter: profileFilter, paginationToken: nil)
        .map { result in
            result.map { workers in
                workers.compactMap { worker in
                    let hierarchy = WorkerHierarchyMetadata.parse(metadata: worker.profile)
                    switch hierarchy {
                    // todo log error
                    case .noHierarchyData, .l1Manager, .l2Manager:
                        return nil
                    case .l0Worker:
                        return (worker.workerHandle, hierarchy, worker.name)
                    }
                }
            }.map {
                createL1Manager(managerName, managerWorkerHandle, $0)
            }
        }
}

func createL2Manager(
    _ managerWorkerHandle: WorkerHandle,
    _ workers: [(WorkerHandle, WorkerHierarchyMetadata, String?)]
) -> TeamValue {
    return .l2Manager(
        .init(
            workerHandle: managerWorkerHandle,
            subordinates: workers.compactMap { (workerHandle: WorkerHandle, hierarchyData: WorkerHierarchyMetadata, name: String?) in
                switch hierarchyData {
                case let .l0Worker(l1, l2):
                    if(l2 == managerWorkerHandle && l1 == nil) {
                        return TeamValue.l0Worker(.init(
                            name: name,
                            workerHandle: workerHandle
                        ))
                    } else {
                        return nil
                    }
                case let .l1Manager(l2):
                    if(l2 == managerWorkerHandle) {
                        return createL1Manager(name, workerHandle, workers)
                    } else {
                        return nil
                    }
                case .l2Manager, .noHierarchyData:
                    return nil
                }
            }
        )
    )
}

func createL1Manager(
    _ managerName: String?,
    _ managerWorkerHandle: WorkerHandle,
    _ workers: [(WorkerHandle, WorkerHierarchyMetadata, String?)]
) -> TeamValue {
    return TeamValue.l1Manager(
        .init(
            name: managerName,
            workerHandle: managerWorkerHandle,
            subordinates: workers.compactMap { (workerHandle: WorkerHandle, hierarchyData: WorkerHierarchyMetadata, name: String?) in
                switch hierarchyData {
                case let .l0Worker(l1, _):
                    if(l1 == managerWorkerHandle) {
                        return TeamValue.l0Worker(.init(
                            name: name,
                            workerHandle: workerHandle
                        ))
                    } else {
                        return nil
                    }
                case .l1Manager, .l2Manager, .noHierarchyData:
                    return nil
                }
            }
        )
    )
}
