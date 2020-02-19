//
//  DeliveriesView.swift
//  Logistics
//
//  Created by rickb on 1/29/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import CoreLocation
import Foundation
import LogisticsKit
import SwiftUI

struct DeliveriesView: View {

	@ObservedObject var driverValue: RefreshableValue<Driver>
	@EnvironmentObject var theme: Theme
	@EnvironmentObject var logisticsManager: HypertrackLogisticsManager
	@Environment(\.presentationMode) var presentationMode
	@Environment(\.displayError) var displayError
	@Environment(\.showingActivity) var showingActivity

	private var driver: Driver { driverValue.currentValue! } // swiftlint:disable:this force_unwrapping
	private var deliveries: [Delivery] { driverValue.currentValue?.deliveries ?? [] }

	var body: some View {
		var itemCount = 0
		return VStack {
			trackingHeader
			List {
				deliverySection(for: .pending, itemCount: &itemCount)
				deliverySection(for: .visited, itemCount: &itemCount)
				deliverySection(for: .completed, itemCount: &itemCount)
			}
			.listStyle(GroupedListStyle())
			.padding(.horizontal, 5)
		}
		.background(theme.background.secondary.sui)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.navigationBarTitle(L10n.DeliveriesView.today.text.font(theme.fonts.body), displayMode: .inline)
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: checkoutButton, trailing: refreshButton)
	}

	init(driverValue: RefreshableValue<Driver>) {
		self.driverValue = driverValue
		UITableView.appearance().separatorInset = .zero
	}
}

private extension DeliveriesView {

	var checkoutButton: some View {
		Button(action: {
			self.logisticsManager.checkout(driverId: self.driver.id)
				.activity(self.showingActivity)
				.error(self.displayError)
				.untilCompletion { _ in
					self.presentationMode.wrappedValue.dismiss()
				}
		}, label: {
			Assets.checkout.image.sui.padding(8)
		})
	}

	var refreshButton: some View {
		Button(action: {
			self.driverValue.refresh().activity(self.showingActivity).error(self.displayError).untilCompletion()
		}, label: {
			Assets.refresh.image.sui.padding(8)
		})
	}

	func deliverySection(for status: Delivery.Status, itemCount: inout Int) -> some View {
		let sectionDeliveries = deliveries.filter { $0.status == status }
		let sectionCount = sectionDeliveries.count
		let section = Group {
			if sectionCount == 0 {
				EmptyView()
			} else {
				Section(header: Group {
					if itemCount == 0 {
						welcomeHeader
					} else {
						EmptyView()
					}
				}) {
					status.title.text
						.modifier(Style(.body, theme))
						.listRowInsets(.init(top: 15, leading: 32, bottom: 15, trailing: 32))

					ForEach(sectionDeliveries) { delivery in
						self.cell(with: delivery)
					}
				}
			}
		}
		itemCount += sectionCount
		return section
	}

	func cell(with delivery: Delivery) -> some View {
		let deliveryValue = logisticsManager.delivery(with: delivery.id, initialValue: delivery)
		return NavigationLink(destination: DeliveryView(deliveryValue: deliveryValue)) {
			DeliveryCell(deliveryValue: deliveryValue)
				.listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
		}
	}

	var trackingHeader: some View {
		let deliveryCount = deliveries.count
		let visited = deliveries.filter { $0.status != .pending }.count
		return [
			logisticsManager.isRunning ? L10n.DeliveriesView.trackingActive : L10n.DeliveriesView.trackingInactive,
			L10n.DeliveryView.visitedDeliveries(visited, deliveryCount)
		].emptyJoined(separator: "\n")
		.text.multilineTextAlignment(.center)
		.modifier(Style(.lightCaption, theme))
		.padding(.horizontal, 50)
		.padding(.vertical, 14)
		.frame(maxWidth: .infinity)
		.background(logisticsManager.isRunning ? theme.background.tracking.sui : theme.background.error.sui)
	}

	var welcomeHeader: some View {
		L10n.DeliveriesView.welcome(driver.name ?? "").text
			.modifier(Style(.headline, theme))
			.foregroundColor(theme.text.primary.sui)
			.padding(.vertical, 20)
			.padding(.horizontal, 16)
	}
}

private extension Delivery.Status {
	var title: String {
		NSLocalizedString("DeliveryStatus.\(rawValue)", comment: "") // swiftlint:disable:this swiftgen_strings
	}
}

private struct DeliveryCell: View {

	@ObservedObject var deliveryValue: RefreshableValue<Delivery>
	@EnvironmentObject private var logisticsManager: HypertrackLogisticsManager
	@EnvironmentObject private var theme: Theme

	private var delivery: Delivery { deliveryValue.currentValue! } // swiftlint:disable:this force_unwrapping

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			HStack(spacing: 12) {
				Assets.circleProfile.image.sui
				VStack(alignment: .leading, spacing: 0) {
					delivery.label.text.modifier(Style(.itemTitle, theme))
					subtitleView
				}
				Spacer()
				if delivery.deliveryPicture.isEmpty == false {
					Assets.camera.image.sui
				}
				if delivery.deliveryNote.isEmpty == false {
					Assets.note.image.sui
				}
				if delivery.enteredAt != nil && delivery.exitedAt == nil {
					Assets.gps.image.sui
				}
			}
		}.listRowInsets(.init(top: 6, leading: 12, bottom: 6, trailing: 12))
	}

	var subtitleView: some View {
		switch delivery.status {
		case .pending:
			return (delivery.address?.lineDisplayString ?? "").text
		case .visited:
			return delivery.visitedString.text
		case .completed:
			return L10n.DeliveriesView.completedAt(DateFormatter.localizedString(from: (delivery.completedAt ?? Date()), dateStyle: .none, timeStyle: .short)).text
		}
	}
}

#if DEBUG
struct DeliveriesView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			DeliveriesView(driverValue: JSONDecoder.logisticsAPI.decodeToRefreshable(Driver.self, name: "driver"))
		}.previewEnvironment()
	}
}
#endif
