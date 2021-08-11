import NonEmpty
import Tagged


public struct LocalSearchCompletion: Hashable {
  public var title: Title
  public var subtitle: Subtitle?
  
  public init(title: Title, subtitle: Subtitle? = nil) { self.title = title; self.subtitle = subtitle }
  
  public typealias Title    = Tagged<(LocalSearchCompletion, title: ()), NonEmptyString>
  public typealias Subtitle = Tagged<(LocalSearchCompletion, title: ()), NonEmptyString>
}
