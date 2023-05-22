//
//  FetchUsersUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 19/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct FetchUsersUseCase {
    private static let useCase = FetchUseCaseAsync<UserCodable, User>(endpoint: .users)
    
    static func fetch() async throws -> [UserCodable] {
        try await useCase.fetch()
    }
}
