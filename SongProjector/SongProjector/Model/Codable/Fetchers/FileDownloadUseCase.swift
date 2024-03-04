//
//  FileDownloadUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

actor FileDownloadUseCase<T: FileTransferable> {
    
    func startDownloadingFor(_ entity: T, downloadObjects: [DownloadObject] = []) async throws -> T {
        let fetchers = (entity.downloadObjects + downloadObjects).compactMap { $0 as? DownloadObject }.map { FileFetcher(downloadObject: $0) }
        
        do {
            let results = try await downloadFilesFor(fetchers)
            return try updateCollectionFor(entity, with: results.compactMap { $0 as? DownloadObject })
        } catch {
            print("No file for: \(entity.title ?? "-")")
            throw error
        }
    }
    
    private func downloadFilesFor(_ fetchers: [FileFetcher]) async throws -> [TransferObject] {
        try await withThrowingTaskGroup(of: TransferObject.self) { group in
            
            var results: [TransferObject] = []
            results.reserveCapacity(fetchers.count)
            
            for fetcher in fetchers {
                group.addTask {
                    try await fetcher.startTransfer()
                }
            }
            
            for try await (result) in group {
                results.append(result)
            }
            
            return results
        }
    }
    
    private func updateCollectionFor(_ entity: T, with results: [TransferObject]) throws -> T {
        var changeableEntity = entity
        try changeableEntity.setTransferObjects(results)
        return changeableEntity
    }
}

