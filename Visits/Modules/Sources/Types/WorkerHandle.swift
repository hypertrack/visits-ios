import NonEmpty
import Tagged

public typealias WorkerHandle = Tagged<WorkerHandleTag, NonEmptyString>
public enum WorkerHandleTag {}
