//
//  ArrayPicker.swift
//  Logistics
//
//  Created by rickb on 1/29/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation
import SwiftUI

protocol Nameable {
	var name: String { get }
}

struct ArrayPicker<Object: ObservableObject, Item: Identifiable & Nameable, Content: View>: View {

	@ObservedObject var observe: Object
	@Binding var selectedItem: Item
	let label: Content
	let items: () -> [Item]

	var body: some View {
		Picker(selection: Binding(get: {
			self.selectedItem.id
		}, set: { id in
			if let item = self.items().first(where: { $0.id == id }) {
				self.selectedItem = item
			}
		}), label: label) {
			ForEach(items()) {
				$0.name.text
			}
		}
	}
}
