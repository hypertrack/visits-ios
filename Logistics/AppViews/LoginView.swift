//
//  ContentView.swift
//  Logistics
//
//  Created by rickb on 1/24/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import LogisticsKit
import SwiftUI

struct LoginView: View {

	@ObservedObject var drivers: RefreshableValue<[Driver]>
	@ObservedObject var driver = DriverSelection()
	@ObservedObject var checkInStatus = CheckinStatus()
	@EnvironmentObject var theme: Theme
	@EnvironmentObject var logisticsManager: HypertrackLogisticsManager
	@Environment(\.displayError) var displayError
	@Environment(\.showingActivity) var showingActivity

	var body: some View {
		VStack(spacing: 0) {
			GeometryReader { geometry in
				VStack(spacing: 0) {
					self.headerView(geometry)
					self.footerView(geometry)
				}
			}
			deliveriesNavigationLink
		}
		.onReceive(drivers.$result) { result in
			self.displayError.wrappedValue = result.error
			self.showingActivity.wrappedValue = result.isLoading
		}
		.background(theme.background.primary.sui)
		.edgesIgnoringSafeArea(.all)
	}

	init(drivers: RefreshableValue<[Driver]>) {
		self.drivers = drivers
	}
}

private extension LoginView {

	var deliveriesNavigationLink: some View {
		guard let driver = driver.item.value else { return EmptyView().any }

		let driverValue = logisticsManager.driver(with: driver.id)
		return NavigationLink(destination: DeliveriesView(driverValue: driverValue), isActive: $checkInStatus.checkedIn) {
			EmptyView()
		}.any
	}

    func headerView(_ geometry: GeometryProxy) -> some View {
		VStack(spacing: 0) {
			Spacer()
			VStack(spacing: 40) {
				Assets.checkTruck.image.sui
				L10n.LoginView.title.text.modifier(Style(.title, theme))
			}
			Spacer()
		}
		.frame(maxWidth: .infinity)
		.background(theme.background.primary.sui)
	}

	func footerView(_ geometry: GeometryProxy) -> some View {
		VStack(spacing: 0) {
			VStack(spacing: driver.isSelecting ? 8 : 40) {
				selectDriverButton
				if driver.isSelecting {
					driverPicker
				}
				checkInButton
			}
			.padding(.horizontal, 28)
			.padding(.top, 32)
			.padding(.bottom, 32)
		}
		.frame(maxWidth: .infinity)
		.padding(.bottom, geometry.safeAreaInsets.bottom)
		.background(theme.background.secondary.sui)
	}

	var selectDriverButton: some View {
		Button(action: {
			if self.drivers.currentValue?.isEmpty == false {
				self.driver.isSelecting.toggle()
			}
		}, label: {
			HStack(spacing: 12) {
				Assets.smallRoundedProfile.image.sui
				selectedDriverLabel
				Spacer()
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.padding(.horizontal, 12)
			.contentShape(Rectangle())
		})
		.buttonStyle(ButtonStyle(.picker, theme))
	}

	var selectedDriverLabel: some View {
		let style: Style.Style = driver.item.value != nil ? .body : .placeholder
		let label = driver.item.value?.name ?? L10n.LoginView.selectDriverId
		return label.text.modifier(Style(style, theme))
	}

	var driverPicker: some View {
		ArrayPicker(observe: drivers, selectedItem: $driver.item, label: EmptyView()) {
			[DriverSelection.Item(value: nil)] + (self.drivers.currentValue ?? []).map { DriverSelection.Item(value: $0) }
		}
		.labelsHidden()
		.pickerStyle(WheelPickerStyle())
		.frame(height: 128)
		.clipped()
	}

	var checkInButton: some View {
		Button(action: {
			if let driverId = self.driver.item.value?.id {
				self.logisticsManager.appCheckin(with: driverId)
					.activity(self.$checkInStatus.checkingIn)
					.error(self.displayError)
					.handleEvents(receiveOutput: { _ in
						self.checkInStatus.checkedIn = true
					})
					.untilCompletion()
			}
		}, label: {
			Group {
				if checkInStatus.checkingIn {
					ActivityIndicator(style: .medium, color: .white, animating: $checkInStatus.checkingIn)
				} else {
					L10n.LoginView.checkin.text.modifier(Style(.primaryButton, theme))
				}
			}
		})
		.buttonStyle(ButtonStyle(.primary, theme, isEnabled: driver.item.value != nil))
	}
}

final class DriverSelection: ObservableObject {

	@Published var isSelecting = false
	@Published var item = Item(value: nil)

	struct Item: Identifiable, Nameable {
		let value: Driver?
		var id: String { value?.id ?? "" }
		var name: String { value?.name ?? "" }
	}
}

final class CheckinStatus: ObservableObject {

	enum State {
		case selectingDriver, checkingIn, checkedIn
	}

	@Published var state: State = .selectingDriver

	var checkingIn: Bool {
		get { state == .checkingIn }
		set {
			if checkedIn == false {
				state = newValue ? .checkingIn : .selectingDriver
			}
		}
	}
	var checkedIn: Bool {
		get { state == .checkedIn }
		set { state = newValue ? .checkedIn : .selectingDriver }
	}
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
	static var previews: some View {
		LoginView.preview()
	}
}

extension LoginView {
	static func preview() -> some View {
		let loginView = LoginView(drivers: JSONDecoder.logisticsAPI.decodeToRefreshable(name: "all_drivers"))
		loginView.driver.isSelecting = false
		loginView.checkInStatus.checkingIn = false
		return NavigationView {
			loginView
		}.previewEnvironment()
	}
}
#endif
