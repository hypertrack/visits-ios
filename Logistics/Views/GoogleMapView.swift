//
//  GoogleMapView.swift
//  Logistics
//
//  Created by rickb on 1/31/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation
import GoogleMaps
import SwiftUI

struct GoogleMapView: UIViewRepresentable {

	@Binding var coordinate: CLLocationCoordinate2D

	func makeUIView(context: UIViewRepresentableContext<GoogleMapView>) -> GMSMapView {
		GMSMapView()
	}

	func updateUIView(_ uiView: GMSMapView, context: UIViewRepresentableContext<GoogleMapView>) {
		context.coordinator.update(uiView, coordinate)
		uiView.isUserInteractionEnabled = false
	}

	func makeCoordinator() -> Coordinator {
		Coordinator()
	}

	class Coordinator {
		var marker: GMSMarker?

		func update(_ mapView: GMSMapView, _ coordinate: CLLocationCoordinate2D) {
			let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 16)
			mapView.camera = camera

			marker?.map = nil
			marker = GMSMarker()
			marker?.position = coordinate
			marker?.map = mapView
		}
	}
}

#if DEBUG
struct GoogleMapView_Previews: PreviewProvider {
    static var previews: some View {
		GMSServices.provideAPIKey(googleMapsApiKey)
		let coordinate: Binding<CLLocationCoordinate2D> = .constant(CLLocationCoordinate2D(latitude: 60, longitude: -30))
		return GoogleMapView(coordinate: coordinate)
    }
}
#endif
