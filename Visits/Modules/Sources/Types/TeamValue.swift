public enum TeamValue: Equatable {
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
