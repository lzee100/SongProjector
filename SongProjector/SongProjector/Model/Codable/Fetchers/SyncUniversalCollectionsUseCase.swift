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
    
    private let endpoint = "https://us-central1-churchbeam-7a169.cloudfunctions.net/fetchUniversalClustersWithUID"

//#if DEBUG
//    private let endpoint = "http://localhost:5000/churchbeamtest/us-central1/fetchUniversalClustersWithUID"
//#else
//    private let endpoint = "https://us-central1-churchbeam-7a169.cloudfunctions.net/fetchUniversalClustersWithUID"
//#endif

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
            let (result, error) = try await URLSession.shared.data(for: request)
            print(error)
            let json = try JSONSerialization.jsonObject(with: result, options: []) as? [String : Any]
            print(json)
            isFetching = false
        } catch {
            isFetching = false
            throw error 
        }
    }

}