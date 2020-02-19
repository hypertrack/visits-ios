//
//  ImagePickerView.swift
//  Logistics
//
//  Created by rickb on 2/2/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct ImagePickerView: UIViewControllerRepresentable {
	@Binding var isPresented: Bool
	let imagePicked: (UIImage) -> Void

	func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerView>) -> UIImagePickerController {
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
		imagePicker.allowsEditing = false
		imagePicker.delegate = context.coordinator
		return imagePicker
	}

	func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerView>) {
	}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

		var parent: ImagePickerView

		init(_ parent: ImagePickerView) {
			self.parent = parent
		}

		func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
			guard let image = info[.originalImage] as? UIImage else {
				return
			}
			parent.imagePicked(image)
			parent.isPresented = false
		}

		func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			parent.isPresented = false
		}
	}
}
