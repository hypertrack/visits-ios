 import Tagged


 public struct MapRegion: Equatable {
  public var center: Coordinate
  public var latitudinalMeters: LatitudinalMeters
  public var longitudinalMeters: LongitudinalMeters
  
  public typealias LatitudinalMeters = Tagged<(MapRegion, latitudinalMeters: ()), UInt>
  public typealias LongitudinalMeters = Tagged<(MapRegion, longitudinalMeters: ()), UInt>
  
  public init(center: Coordinate, latitudinalMeters: MapRegion.LatitudinalMeters, longitudinalMeters: MapRegion.LongitudinalMeters) {
    self.center = center; self.latitudinalMeters = latitudinalMeters; self.longitudinalMeters = longitudinalMeters
  }
}
