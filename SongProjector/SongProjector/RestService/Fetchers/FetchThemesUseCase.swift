//
//  FetchThemesUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

actor FetchThemesUseCase {
    
    private let useCase: FetchUseCaseAsync<ThemeCodable, Theme>

    init(fetchAll: Bool) {
        useCase = FetchUseCaseAsync<ThemeCodable, Theme>(endpoint: .themes, fetchAll: fetchAll)
    }
    
    @discardableResult
    func fetch() async throws -> [ThemeCodable] {
        try await useCase.fetch()
    }
}
