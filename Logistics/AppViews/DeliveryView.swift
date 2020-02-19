//
//  DeliveryView.swift
//  Logistics
//
//  Created by rickb on 1/31/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import CoreLocation
import Foundation
import struct Kingfisher.KFImage
import LogisticsKit
import MapKit
import SwiftUI

struct DeliveryView: View {

	@ObservedObject private var deliveryValue: RefreshableValue<Delivery>
	@EnvironmentObject var theme: Theme
	@EnvironmentObject var logisticsManager: HypertrackLogisticsManager
	@Environment(\.presentationMode) var presentationMode
	@Environment(\.displayError) var displayError
	@Environment(\.showingActivity) var showingActivity

	@State private var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
	@State private var deliveryNote = ""
	@State private var markingComplete = false
	@State private var pickingImage = false

	private var delivery: Delivery { deliveryValue.currentValue! } // swiftlint:disable:this force_unwrapping
	private let columnWidth: CGFloat = 48

	var body: some View {
		VStack(spacing: 0) {
			ScrollView {
				DeliveryMapView(delivery: delivery).frame(height: 160)
				VStack(spacing: 0) {
					visitedHeader
					completedHeader
				}.offset(x: 0, y: -8) // don't have the slightest idea why map view has some white space at bottom
				locationView
				customerNoteView
				itemsView
				deliveryNoteView
				deliveryPictureView
			}
			.frame(maxWidth: .infinity)
			.background(theme.background.secondary.sui)

			markCompletedButton
		}
		.navigationBarTitle(delivery.label.text.font(theme.fonts.body), displayMode: .inline)
		.navigationBackButton(self.presentationMode, Assets.backButton.image.sui.padding(8))
		.sheet(isPresented: $pickingImage) {
			ImagePickerView(isPresented: self.$pickingImage) { image in
				let deliveryId = self.delivery.id
				let image = image.fit(to: CGSize(width: 800, height: 800), aspect: .fit) ?? UIImage()
				self.logisticsManager.uploadDelivery(image: image, with: deliveryId)
					.activity(self.showingActivity)
					.error(self.displayError)
					.untilCompletion()
			}
		}
		.onReceive(deliveryValue.$result) { result in
			self.deliveryNote = result.value?.deliveryNote ?? ""
		}
	}

	init(deliveryValue: RefreshableValue<Delivery>) {
		self.deliveryValue = deliveryValue
	}
}

private extension DeliveryView {

	var visitedHeader: some View {
		guard delivery.status != .pending else {
			return EmptyView().any
		}
		let title = (delivery.status == .visited ? L10n.DeliveryView.lastVisit : L10n.DeliveryView.visited)
		let times = delivery.visitedString
		return "\(title): \(times)"
			.text.multilineTextAlignment(.center)
			.modifier(Style(.lightCaption, theme))
			.padding(.horizontal, 50)
			.padding(.vertical, 14)
			.frame(maxWidth: .infinity)
			.background(theme.background.visit.sui)
			.any
	}

	var completedHeader: some View {
		guard let date = delivery.completedAt, delivery.status == .completed else {
			return EmptyView().any
		}
		return "\(L10n.DeliveryView.completedAt): \(date.shortTime)"
			.text.multilineTextAlignment(.center)
			.modifier(Style(.lightCaption, theme))
			.padding(.horizontal, 50)
			.padding(.vertical, 14)
			.frame(maxWidth: .infinity)
			.background(theme.background.complete.sui)
			.any
	}

	func section<T: View>(icon: ImageAsset, text: String, inset: Bool = true, content: () -> T) -> some View {
		var content: AnyView = content().any
		if inset {
			content = content.offset(x: columnWidth, y: 0).padding(.trailing, columnWidth + 20).any
		}
		return VStack(alignment: .leading, spacing: 10) {
			HStack(spacing: 0) {
				icon.image.sui.frame(width: columnWidth)
				text.text.modifier(Style(.itemHeader, theme))
				Spacer()
			}
			content
		}
		.frame(maxWidth: .infinity)
		.padding(.horizontal, 20)
		.padding(.vertical, 10)
	}

	var locationView: some View {
		guard let address = delivery.address else {
			return EmptyView().any
		}
		return section(icon: Assets.location, text: L10n.DeliveryView.location) {
			address.displayString.text
		}
		.onTapGesture {
			var urlComponents = URLComponents()
			urlComponents.scheme = "https"
			urlComponents.host = "maps.apple.com"
			urlComponents.path = "/"
			urlComponents.queryItems = [
				address.street, address.city, address.state, address.postalCode
			].emptyJoined(separator: " ").map {
				URLQueryItem(name: "q", value: $0)
			}.flatMap { [$0] }

			if let url = urlComponents.url {
				UIApplication.shared.open(url, options: [:], completionHandler: nil)
			}
		}
		.any
	}

	var customerNoteView: some View {
		guard let note = delivery.customerNote else {
			return EmptyView().any
		}
		return section(icon: Assets.importantNote, text: L10n.DeliveryView.customerNote) {
			note.text
		}.any
	}

	var itemsView: some View {
		guard let items = delivery.items, items.isEmpty == false else {
			return EmptyView().any
		}
		return section(icon: Assets.package, text: L10n.DeliveryView.items, inset: false) {
			VStack(alignment: .leading) {
				ForEach(0..<items.count) { i in
					HStack {
						Assets.info.image.sui.frame(width: self.columnWidth)
						(items[i].itemSku ?? "").text.modifier(Style(.itemSubtitle, self.theme))
						Spacer()
						L10n.DeliveryView.scan.text
						Assets.next.image.sui
					}
				}
			}
		}.any
	}

	var deliveryNoteView: some View {
		section(icon: Assets.note, text: L10n.DeliveryView.deliveryNote) {
			TextView(text: $deliveryNote) {
				guard self.deliveryNote.emptyNil != self.delivery.deliveryNote else { return }
				self.logisticsManager.updateDelivery(with: self.delivery.id, note: self.deliveryNote, picture: nil)
					.activity(self.showingActivity)
					.error(self.displayError)
					.untilCompletion()
			}.frame(height: 114)
		}.any
	}

	var deliveryPictureView: some View {
		section(icon: Assets.camera, text: L10n.DeliveryView.deliveryPicture) {
			VStack {
				deliveryPictureImage
				Button(action: {
					self.pickingImage = true
				}, label: {
					(delivery.deliveryPicture.isEmpty == false ? L10n.DeliveryView.replacePicture : L10n.DeliveryView.takePicture).text.modifier(Style(.primaryButton, theme))
				})
				.buttonStyle(ButtonStyle(.secondary, theme))
			}
		}.any
	}

	var removeImageButton: some View {
		Button(action: {
			self.logisticsManager.updateDelivery(with: self.delivery.id, note: nil, picture: "")
				.activity(self.showingActivity)
				.error(self.displayError)
				.untilCompletion()
		}, label: {
			Assets.closeX.image.sui.padding(8)
		})
	}

	var deliveryPictureImage: some View {
		guard let url = delivery.deliveryPicture.flatMap({ URL(string: $0) }) else {
			return EmptyView().any
		}
		return KFImage(url)
			.resizable()
			.scaledToFit()
			.overlay(removeImageButton, alignment: .topTrailing)
			.any
	}

	var markCompletedButton: some View {
		VStack {
			if delivery.status != .completed {
				Button(action: {
					self.logisticsManager.markDeliveryAsCompleted(self.delivery)
						.activity(self.$markingComplete)
						.error(self.displayError)
						.untilCompletion()
				}, label: {
					if markingComplete {
						ActivityIndicator(style: .medium, color: .white, animating: $markingComplete)
					} else if self.delivery.status != .completed {
						L10n.DeliveryView.markCompleted.text.modifier(Style(.primaryButton, theme))
					}
				})
				.buttonStyle(ButtonStyle(.primary, theme))
				.padding(.horizontal, 15)
				.padding(.vertical, 12)
			} else {
				EmptyView()
			}
		}
	}
}

private struct DeliveryMapView: View {

	let delivery: Delivery
	@State private var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
	private static let geocoder = CLGeocoder()

	var body: some View {
		GoogleMapView(coordinate: $coordinate)
		.onAppear {
			Self.geocoder.cancelGeocode()
			if let address = self.delivery.address?.geocodeString {
				Self.geocoder.geocodeAddressString(address) { placemarks, _ in
					if let placemark = placemarks?.first, let coordinate = placemark.location?.coordinate {
						self.coordinate = coordinate
					}
				}
			}
		}
	}
}

extension Delivery.Address {

	var geocodeString: String {
		[street, postalCode, city, country].emptyJoined(separator: " ")
	}

	var displayString: String {
		[
			street,
			[[city, state].emptyJoined(separator: ","), postalCode].emptyJoined(separator: " ")
		].emptyJoined(separator: "\n")
	}

	var lineDisplayString: String {
		[street, postalCode, city].emptyJoined(separator: ", ")
	}
}

extension Delivery {

	var visitedString: String {
		[enteredAt?.shortTime, exitedAt?.shortTime].emptyJoined(separator: " - ")
	}
}

extension Date {

	var shortTime: String {
		DateFormatter.localizedString(from: self, dateStyle: .none, timeStyle: .short)
	}
}

#if DEBUG
import GoogleMaps

struct DeliveryView_Previews: PreviewProvider {
	static var previews: some View {
		GMSServices.provideAPIKey(googleMapsApiKey)
		return NavigationView {
			DeliveryView(deliveryValue: JSONDecoder.logisticsAPI.decodeToRefreshable(name: "delivery")).previewEnvironment()
		}.previewEnvironment()
		//.previewLayout(.fixed(width: 375, height: 1200))
	}
}
#endif
