//
//  FetchTagsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct FetchTagsUseCase {
    private let useCase: FetchUseCaseAsync<TagCodable, Tag>

    init(fetchAll: Bool = false) {
        useCase = FetchUseCaseAsync<TagCodable, Tag>(endpoint: .tags, fetchAll: fetchAll)
    }
    @discardableResult
    func fetch() async throws -> [TagCodable] {
        try await useCase.fetch()
    }
}
