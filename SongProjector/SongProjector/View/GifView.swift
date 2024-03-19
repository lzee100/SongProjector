//
//  GifView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 19/03/2024.
//  Copyright © 2024 iozee. All rights reserved.
//

import UIKit
import SwiftUI
import WebKit

struct GIFView: UIViewRepresentable {

    private var location: URL

    init(location: URL) {
        self.location = location
    }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        let data = try! Data(contentsOf: location)
        view.load(
            data,
            mimeType: "image/gif",
            characterEncodingName: "UTF-8",
            baseURL: location.deletingLastPathComponent()
        )
        view.scrollView.isScrollEnabled = false
        view.isOpaque = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.reload()
    }

}
