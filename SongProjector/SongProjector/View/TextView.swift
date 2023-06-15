//
//  TextView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 29/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct TextView: UIViewRepresentable {

    @Binding var text: String
    @Binding var textStyle: UIFont.TextStyle
    @State var placeholder: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()

        textView.font = UIFont.preferredFont(forTextStyle: textStyle)
        textView.autocapitalizationType = .sentences
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text.isBlanc ? placeholder : text
        uiView.font = UIFont.preferredFont(forTextStyle: textStyle)
        uiView.textColor = text.isBlanc ? UIColor.lightGray : UIColor.blackColor
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator($text, placeholder: placeholder)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        let placeholder: String

        init(_ text: Binding<String>, placeholder: String) {
            self.text = text
            self.placeholder = placeholder
        }

        func textViewDidChange(_ textView: UITextView) {
            self.text.wrappedValue = textView.text
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == UIColor.lightGray {
                textView.text = nil
                textView.textColor = UIColor.black
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = placeholder
                textView.textColor = UIColor.lightGray
            }
        }
    }
}
