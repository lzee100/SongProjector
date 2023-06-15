//
//  SyncUniversalCollectionsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth

actor SyncUniversalCollectionsUseCase: ObservableObject {
    
    @Published private(set) var isFetching = false
    
#if DEBUG
    private let endpoint = "http://127.0.0.1:5001/churchbeamtest/us-central1/fetchUniversalClustersWithUID"
#else
    private let endpoint = "https://us-central1-churchbeamtest.cloudfunctions.net/fetchUniversalClustersWithUID"
#endif

    enum AuthError: Error {
        case noOauthToken
    }
    
    func request() async throws {
        guard !isFetching else { return }
        isFetching = true
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            isFetching = false
            throw AuthError.noOauthToken
        }
        do {
            var request = URLRequest(url: URL(string: endpoint)!)
            request.addValue(token, forHTTPHeaderField: "Authorization")
            try await URLSession.shared.data(for: request)
            isFetching = false
        } catch {
            isFetching = false
            throw error
        }
    }

}
