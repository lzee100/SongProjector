//
//  DeleteAllClustersSubmitter.swift
//  SongProjector
//
//  Created by Leo van der Zee on 02/03/2024.
//  Copyright © 2024 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth

actor DeleteAllClustersSubmitter: ObservableObject {

    @Published private(set) var isFetching = false
    private let endpoint = "deleteAllClusters"

    enum AuthError: Error {
        case noOauthToken
    }

    func request(userUID: String) async throws {
        guard !isFetching else { return }
        isFetching = true

        guard let token = try await Auth.auth().currentUser?.getIDToken() else {
            isFetching = false
            throw AuthError.noOauthToken
        }

        do {
            let url = URL(string: ChurchBeamConfiguration.environment.cloudFunctionsEndpoint + endpoint)!
            var request = URLRequest(url: url)
            request.addValue(token, forHTTPHeaderField: "Authorization")
            request.addValue(userUID, forHTTPHeaderField: "userUID")

            let (result, error) = try await URLSession.shared.data(for: request)
            let bla = String(data: result, encoding: .utf8)
            print(bla)
            print(error)
            let json = try JSONSerialization.jsonObject(with: result, options: []) as? [String : Any]
            print(json)
            isFetching = false
        } catch {
            isFetching = false
            throw error
        }
        isFetching = false
    }

}
