//
//  FetchTagsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct FetchTagsUseCase {
    private static let useCase = FetchUseCaseAsync<TagCodable, Tag>(endpoint: .tags)
    
    static func fetch() async throws -> FetchUseCaseAsyncTask<TagCodable>.FetchUseCaseAsyncDownloadResult {
        try await useCase.fetch()
    }
}
