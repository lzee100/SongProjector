//
//  FileDeleter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/11/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import FirebaseStorage

let FileDeleter = FleDeleter()

class FleDeleter {
    
    private var isDeleting = false
    private var unsafeDeletableFiles: [String] = []
    
    private var safeDeletableFiles: [String] {
        var safeDeletableFiles: [String]!
        
        concurrentDeleteQueue.sync {
            safeDeletableFiles = self.unsafeDeletableFiles
        }
        return safeDeletableFiles
    }
    
    private let concurrentDeleteQueue =
        DispatchQueue(
            label: "oneThreadDeletableFiles",
            attributes: .concurrent)

    
    func delete(files: [String]) {
        updateDeletableFiles(files)
    }
    
    private func performDelete() {
        guard !isDeleting else { return }
        guard let url = safeDeletableFiles.first else {
            isDeleting = false
            return
        }
        isDeleting = true
        let ref = Storage.storage().reference(forURL: url)
        
        ref.delete { (result) in
            self.removeFirst()
            self.isDeleting = false
            self.performDelete()
        }
    }
    
    private func updateDeletableFiles(_ deletableFiles: [String]) {
        concurrentDeleteQueue.async(flags: .barrier) {
            self.unsafeDeletableFiles.append(contentsOf: deletableFiles)
        }
        self.performDelete()
    }
    
    private func removeFirst() {
        concurrentDeleteQueue.async(flags: .barrier) {
            self.unsafeDeletableFiles.removeFirst()
        }
    }

    
}

