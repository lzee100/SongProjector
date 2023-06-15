//
//  FetchSongServiceSettingsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

actor FetchSongServiceSettingsUseCase {
    private let useCase = FetchUseCaseAsync<SongServiceSettingsCodable, SongServiceSettings>(endpoint: .songservicesettings)
    
    @discardableResult
    func fetch() async throws -> [SongServiceSettingsCodable] {
        try await useCase.fetch()
    }
}
