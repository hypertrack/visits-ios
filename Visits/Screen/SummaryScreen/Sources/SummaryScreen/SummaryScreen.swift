import CoreLocation
import MapKit
import SwiftUI
import Views

public struct SummaryScreen: View {
  public struct State {
    public let trackedDuration: UInt
    public let driveDistance: UInt
    public let driveDuration: UInt
    public let walkSteps: UInt
    public let walkDuration: UInt
    public let stopDuration: UInt
    
    public init(
      trackedDuration: UInt,
      driveDistance: UInt,
      driveDuration: UInt,
      walkSteps: UInt,
      walkDuration: UInt,
      stopDuration: UInt
    ) {
      self.trackedDuration = trackedDuration
      self.driveDistance = driveDistance
      self.driveDuration = driveDuration
      self.walkSteps = walkSteps
      self.walkDuration = walkDuration
      self.stopDuration = stopDuration
    }
  }
  
  let state: State
  
  public init(state: State) {
    self.state = state
  }
  
  public var body: some View {
    Navigation(
      title: "Today",
      leading: {},
      trailing: {}) {
      ZStack {
        VStack {
          HStack {
            Image(systemName: "clock.fill")
              .frame(width: 15, height: 15)
            Spacer()
          }
          HStack {
            Image(systemName: "car.fill")
              .frame(width: 15, height: 15)
              .padding(.top, paddingBetweenRows)
            Spacer()
          }
          HStack {
            Image(systemName: "figure.walk")
              .frame(width: 15, height: 15)
              .padding(.top, paddingBetweenRows)
            Spacer()
          }
          HStack {
            Image(systemName: "stop.fill")
              .frame(width: 15, height: 15)
              .padding(.top, paddingBetweenRows)
            Spacer()
          }
          Spacer()
        }
        VStack {
          HStack {
            CustomText(text: "Tracked Duration")
            Spacer()
            CustomText(text: localizedTime(state.trackedDuration))
          }
          .frame(height: 15)
          HStack {
            CustomText(text: "Drives")
            Spacer()
            CustomText(text: localizedTime(state.driveDuration))
          }
          .frame(height: 15)
          .padding(.top, paddingBetweenRows)
          HStack {
            CustomText(text: "Walks")
            Spacer()
            CustomText(text: localizedTime(state.walkDuration))
          }
          .frame(height: 15)
          .padding(.top, paddingBetweenRows)
          HStack {
            CustomText(text: "Stops")
            Spacer()
            CustomText(text: localizedTime(state.stopDuration))
          }
          .frame(height: 15)
          .padding(.top, paddingBetweenRows)
          Spacer()
        }
        .padding(.leading, 30)
        VStack {
          CustomText(text: "")
            .frame(height: 15)
          CustomText(text: localizedDistance(state.driveDistance))
            .frame(height: 15)
            .padding(.top, paddingBetweenRows)
          CustomText(text: "\(state.walkSteps) steps")
            .frame(height: 15)
            .padding(.top, paddingBetweenRows)
          Spacer()
        }
      }
      .padding()
      .padding(.top, 44)
      .modifier(AppBackground())
      
    }
  }
}

func localizedTime(_ time: UInt) -> String {
  let formatter = DateComponentsFormatter()
  formatter.allowedUnits = [.hour, .minute]
  formatter.unitsStyle = .short
  return formatter.string(from: TimeInterval(time))!
}

func localizedDistance(_ distanceMeters: UInt) -> String {
  let formatter = MKDistanceFormatter()
  formatter.unitStyle = .abbreviated
  return formatter.string(fromDistance: CLLocationDistance(distanceMeters))
}

let paddingBetweenRows: CGFloat = 15
