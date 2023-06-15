//
//  FetchNeedsUpdateUniversalClustersUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 14/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth

actor FetchNeedsUpdateUniversalClustersUseCase {
    
    enum AuthError: Error {
        case noOauthToken
    }
    
#if DEBUG
    private let endpoint = URL(string: "http://127.0.0.1:5001/churchbeamtest/us-central1/hasNewUniversalClusters")!
#else
    private let endpoint = URL(string: "https://us-central1-churchbeamtest.cloudfunctions.net/hasNewUniversalClusters")!
#endif
    
    private(set) var isFetching = false

    func fetch() async throws -> Bool {
        guard !isFetching else { return false }
        isFetching = true
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            isFetching = false
            throw AuthError.noOauthToken
        }
        do {
            var request = URLRequest(url: endpoint)
            request.addValue(token, forHTTPHeaderField: "Authorization")
            let (needsToken, _) = try await URLSession.shared.data(for: request)
            
            guard let json = try JSONSerialization.jsonObject(with: needsToken, options: []) as? [String : Bool] else {
                isFetching = false
                return false
            }

            isFetching = false
            return json["hasNewUniversalClusters"] ?? false
        } catch {
            isFetching = false
            throw error
        }
    }
    
}
