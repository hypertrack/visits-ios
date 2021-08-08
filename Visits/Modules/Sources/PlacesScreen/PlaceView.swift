import SwiftUI
import Views


struct PlaceView: View {
  let placeAndTime: PlacesSection.PlaceAndTime
  
  var body: some View {
    HStack {
      Image(systemName: "mappin.circle")
        .font(.title)
        .foregroundColor(.accentColor)
        .padding(.trailing, 10)
      VStack {
        if placeAndTime.time != nil || placeAndTime.place.numberOfVisits != 0 {
          HStack {
            if let time = placeAndTime.time {
              Text(time)
                .font(.caption)
                .foregroundColor(Color(.secondaryLabel))
            }
            Spacer()
            if case let count = placeAndTime.place.numberOfVisits, count != 0 {
              HStack {
                Spacer()
                Text("Visited \(count) \(count == 1 ? "time" : "times")")
                  .font(.caption)
                  .foregroundColor(Color(.secondaryLabel))
              }
            }
          }
        }
        if let place = placeAndTime.place.name,
           let address = placeAndTime.place.address.anyAddressStreetBias?.rawValue {
          PrimaryRow(place.rawValue)
            .padding(.bottom, -3)
          SecondaryRow(address)
        } else {
          PrimaryRow(
            placeAndTime.place.name?.rawValue ??
              (placeAndTime.place.address.anyAddressStreetBias?.rawValue ??
                placeAndTime.place.fallbackTitle.rawValue)
          )
        }
      }
    }
    .padding(.vertical, 10)
  }
}


struct PlaceView_Previews: PreviewProvider {
  static var previews: some View {
    PlaceView(
      placeAndTime: .init(
        place: placePreviewSample,
        time: "09:45 AM"
      )
    )
  }
}
