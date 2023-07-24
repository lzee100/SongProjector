//
//  FetchUserUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth

actor FetchUserUseCase {
    
    enum AuthError: Error {
        case noOauthToken
    }
    private let endpoint = "fetchUser"
    private(set) var isFetching = false
    
    func fetch(installTokenId: String) async throws {
        guard !isFetching else { return }
        isFetching = true
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            isFetching = false
            throw AuthError.noOauthToken
        }
        do {
            var request = URLRequest(url: URL(string: ChurchBeamConfiguration.environment.cloudFunctionsEndpoint + endpoint)!)
            request.addValue(token, forHTTPHeaderField: "Authorization")
            request.addValue(installTokenId, forHTTPHeaderField: "installTokenId")
            let (userData, _) = try await URLSession.shared.data(for: request)
                        
            if let user = try? JSONDecoder().decode(UserCodable.self, from: userData) {
                try await SaveUsersUseCase().save(entities: [user])
            }
            isFetching = false
        } catch {
            isFetching = false
            throw error
        }
    }
    
}
