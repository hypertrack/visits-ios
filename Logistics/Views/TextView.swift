//
//  TextView.swift
//  Logistics
//
//  Created by rickb on 1/31/20.
//  Copyright © 2020 HyperTrack. All rights reserved.
//

import SwiftUI
import UIKit

struct TextView: UIViewRepresentable {
    @Binding var text: String
	var doneEditing: (() -> Void)?

    func makeUIView(context: Context) -> UITextView {
		let view = UITextView()
		view.isScrollEnabled = true
		view.isEditable = true
		view.isUserInteractionEnabled = true
		view.delegate = context.coordinator
		view.inputAccessoryView = UIToolbar().configure { toolbar in
			toolbar.items = [
				UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
				UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil).configure {
					$0.set { _ in view.resignFirstResponder() }
				}
			]
			toolbar.sizeToFit()
		}
		view.backgroundColor = .white
		view.layer.borderWidth = 1
		return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> TextView.Coordinator {
        Coordinator(self, doneEditing: doneEditing)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        let control: TextView
		let doneEditing: (() -> Void)?

        init(_ control: TextView, doneEditing: (() -> Void)?) {
            self.control = control
            self.doneEditing = doneEditing
        }

        func textViewDidChange(_ textView: UITextView) {
            control.text = textView.text
        }

        func textViewDidEndEditing(_ textView: UITextView) {
			doneEditing?()
		}
    }
}
