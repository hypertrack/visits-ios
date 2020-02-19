//
//  NavigationBackButton.swift
//  Logistics
//
//  Created by rickb on 1/29/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation
import SwiftUI

struct NavigationBackButton<V: View, T: View>: ViewModifier {

	@Binding var presentationMode: PresentationMode
	let backButton: V
	let trailing: T

	private var backNavigationItem: some View {
		if self.presentationMode.isPresented {
			return Button(action: {
				self.presentationMode.dismiss()
			}, label: {
				backButton
			}).any
		} else {
			return EmptyView().any
		}
	}

	func body(content: Content) -> some View {
		content
			.navigationBarBackButtonHidden(true)
			.navigationBarItems(leading: backNavigationItem, trailing: trailing)
	}
}

extension View {

	func navigationBackButton<V: View, T: View>(_ presentationMode: Binding<PresentationMode>, _ backButton: V, trailing: T) -> some View {
		modifier(NavigationBackButton(presentationMode: presentationMode, backButton: backButton, trailing: trailing))
	}

	func navigationBackButton<V: View>(_ presentationMode: Binding<PresentationMode>, _ backButton: V) -> some View {
		modifier(NavigationBackButton(presentationMode: presentationMode, backButton: backButton, trailing: EmptyView()))
	}
}
