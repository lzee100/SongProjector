//
//  FetchMusicUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 08/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

class MultiResults: ObservableObject {
    @Published var results: [String : RequesterResult] = [:]
    
    var total: CGFloat {
        return CGFloat(results.count)
    }
    var progress: CGFloat {
        return results.map { $0.value.progress }.reduce(0, +) / total
    }
}

class FetchMusicUseCase: ObservableObject {
    
    var id: String {
        cluster.id
    }
    
    @Published private(set) var progress: RequesterResult = .idle
    
    private let cluster: ClusterCodable
    private let managedObjectContextHandler = ManagedObjectContextHandler<ClusterCodable>()
    
    init(cluster: ClusterCodable) {
        self.cluster = cluster
    }
    
    func fetch() {
        guard progress == .idle else { return }
        progress = .preparation
        let downloadTask = Task {
            let downloadableFiles = self.cluster.hasInstruments
                .filter({ $0.resourcePath == nil })
                .compactMap { URL(string: $0.resourcePathAWS) }
                .compactMap { DownloadObject(remoteURL: $0) }
            
            let downloadFilesUseCase = FileDownloadUseCase(downloadFiles: downloadableFiles)
            do {
                let result = try await downloadFilesUseCase.start()
                switch result {
                case .success:
                    var changeableCluster = self.cluster
                    downloadFilesUseCase.updateFromResults(&changeableCluster)
                    self.saveLocally(changeableCluster)
                case .failed(error: let error):
                    await MainActor.run(body: {
                        self.progress = .finished(.failure(error))
                    })
                }
            } catch {
                await MainActor.run(body: {
                    self.progress = .finished(.failure(error))
                })
            }
        }

    }
    
    private func saveLocally(_ cluster: ClusterCodable) {
        DispatchQueue.main.async {
            self.progress = .saveLocally
        }
        managedObjectContextHandler.save(entities: [cluster]) { result in
            switch result {
            case .success(let result):
                DispatchQueue.main.async {
                    self.progress = .finished(.success(result))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.progress = .finished(.failure(error))
                }
            }
        }
    }
}
