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
    private let endpoint = "hasNewUniversalClusters"
    private let universalClusterVersionKey = "universalClusterVersion"
    private(set) var isFetching = false
    
    func fetch() async throws -> Bool {
        guard !isFetching else { return false }
        isFetching = true
        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            isFetching = false
            throw AuthError.noOauthToken
        }
        guard let user = await GetUserUseCase().get() else {
            isFetching = false
            return false
        }
        do {
            var url = URL(string: ChurchBeamConfiguration.environment.cloudFunctionsEndpoint + endpoint)!
            url.append(queryItems: [URLQueryItem(name: universalClusterVersionKey, value: ChurchBeamConfiguration.universalClusterVersion)])
            var request = URLRequest(url: url)
            request.addValue(token, forHTTPHeaderField: "Authorization")
            let (needsToken, _) = try await URLSession.shared.data(for: request)
            
            let json = try JSONSerialization.jsonObject(with: needsToken, options: []) as? [String : Any]
            print(json)
            guard let json = try JSONSerialization.jsonObject(with: needsToken, options: []) as? [String : Bool] else {
                isFetching = false
                return false
            }

            isFetching = false
            return json["hasNewUniversalClusters"] ?? false
        } catch {
            isFetching = false
            print(error)
            throw error
        }
    }
    
}
