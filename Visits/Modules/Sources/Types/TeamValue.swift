import Tagged
import NonEmpty

public enum TeamValue: Equatable, Identifiable {
    public var id: WorkerHandle {
        switch self {
            case .l2Manager(let l2Manager): return l2Manager.workerHandle
            case .l1Manager(let l1Manager): return l1Manager.workerHandle
            case .l0Worker(let l0Worker): return l0Worker.workerHandle
            case .noTeamData: return WorkerHandle(rawValue: "illegal value")
        }
    }
    
    case l2Manager(L2Manager)
    case l1Manager(L1Manager)
    case l0Worker(L0Worker)
    case noTeamData

    public struct L0Worker: Equatable {
        public var name: String?
        public var workerHandle: WorkerHandle

        public init(name: String?, workerHandle: WorkerHandle) {
            self.name = name
            self.workerHandle = workerHandle
        }
    }

    public struct L1Manager: Equatable {
        public var name: String?
        public var workerHandle: WorkerHandle
        public var subordinates: [TeamValue]

        public init(name: String?, workerHandle: WorkerHandle, subordinates: [TeamValue]) {
            self.name = name
            self.workerHandle = workerHandle
            self.subordinates = subordinates
        }
    }

    public struct L2Manager: Equatable {
        public var workerHandle: WorkerHandle
        public var subordinates: [TeamValue]

        public init(workerHandle: WorkerHandle, subordinates: [TeamValue]) {
            self.workerHandle = workerHandle
            self.subordinates = subordinates
        }
    }
}
