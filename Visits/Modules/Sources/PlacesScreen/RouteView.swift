import MapKit
import SwiftUI


struct RouteView: View {
  let distance: UInt
  let duration: UInt
  let idleTime: UInt
  
  var body: some View {
    TimelinePieceView {
      HStack {
        Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
          .font(.system(size: 24, weight: .regular))
          .foregroundColor(.accentColor)
          .frame(width: 25, height: 25, alignment: .center)
        
        VStack(alignment: .leading) {
          Text("Traveled\(distance == 0 ? "" : " " + localizedDistance(distance) + " for") \(localizedTime(duration))")
            .font(.callout)
            .foregroundColor(Color(.label))
          if idleTime != 0 {
            Text("Idle for \(localizedTime(idleTime))")
              .font(.callout)
              .foregroundColor(Color(.label))
          }
        }
      }
    }
  }
}

public func localizedDistance(_ distanceMeters: UInt) -> String {
  let measurement = Measurement<UnitLength>(value: Double(distanceMeters), unit: .meters)
  let formatter = MeasurementFormatter()
  formatter.unitOptions = [.naturalScale]
  return formatter.string(from: measurement)
}
