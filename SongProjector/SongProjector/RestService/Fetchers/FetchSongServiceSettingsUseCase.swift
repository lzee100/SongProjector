//
//  FetchSongServiceSettingsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct FetchSongServiceSettingsUseCase {
    private static let useCase = FetchUseCaseAsync<SongServiceSettingsCodable, SongServiceSettings>(endpoint: .songservicesettings)
    
    static func fetch() async throws -> FetchUseCaseAsyncTask<SongServiceSettingsCodable>.FetchUseCaseAsyncDownloadResult {
        try await useCase.fetch()
    }
}
