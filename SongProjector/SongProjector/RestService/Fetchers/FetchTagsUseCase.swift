//
//  FetchTagsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct FetchTagsUseCase {
    private let useCase = FetchUseCaseAsync<TagCodable, Tag>(endpoint: .tags)
    
    @discardableResult
     func fetch() async throws -> [TagCodable] {
        try await useCase.fetch()
    }
}
