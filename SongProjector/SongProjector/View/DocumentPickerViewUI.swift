//
//  DocumentPickerViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers

struct DocumentPickerViewUI: UIViewControllerRepresentable {
    @Binding var fileURL: URL?
    @Binding var showingDocumentPicker: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let types = ["m4a", "mp3", "mp4"].compactMap({ UTType(filenameExtension: $0) })
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No update needed
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerViewUI

        init(_ parent: DocumentPickerViewUI) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.fileURL = urls.first
            parent.showingDocumentPicker = false
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.showingDocumentPicker = false
        }
    }
}

struct ImportSkippers: View {
    @State private var fileURL: URL?
    @Binding var showingDocumentPicker: Bool

    var body: some View {
        VStack {
            Text("Selected File: \(fileURL?.lastPathComponent ?? "None")")

            Button("Import Text File") {
                fileURL = URL(string: "") // Reset fileURL

                let documentPicker = DocumentPickerViewUI(fileURL: $fileURL, showingDocumentPicker: $showingDocumentPicker)
                documentPicker.edgesIgnoringSafeArea(SwiftUI.Edge.Set.all)
            }
        }
        .padding()
    }
}
