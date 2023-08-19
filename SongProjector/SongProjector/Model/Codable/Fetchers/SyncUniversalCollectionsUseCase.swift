//
//  SyncUniversalCollectionsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth

enum MotherChurch: String, CaseIterable, Identifiable {
    var id: String {
        return self.displayName
    }
    
    static let key = "region"

    case zwolleDutch
    case zwolleEnglish
    case zwolleMandarin
    case tempe
    
    var displayName: String {
        switch self {
        case .zwolleDutch: return AppText.Settings.MotherChurchZwolleDutch
        case .zwolleEnglish: return AppText.Settings.MotherChurchZwolleEnglish
        case .zwolleMandarin: return AppText.Settings.MotherChurchZwolleMandarin
        case .tempe: return AppText.Settings.MotherChurchTempe
        }
    }
}

actor SyncUniversalCollectionsUseCase: ObservableObject {
    
    @Published private(set) var isFetching = false
    private let endpoint = "fetchUniversalClustersWithUID"
    private let motherChurch: MotherChurch
    init(motherChurch: MotherChurch = .zwolleDutch) {
        self.motherChurch = motherChurch
    }
    
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
            var url = URL(string: ChurchBeamConfiguration.environment.cloudFunctionsEndpoint + endpoint)!
            url.append(queryItems: [URLQueryItem(name: MotherChurch.key, value: motherChurch.rawValue)])
            var request = URLRequest(url: url)
            request.addValue(token, forHTTPHeaderField: "Authorization")
            request.setValue(motherChurch.rawValue, forHTTPHeaderField: MotherChurch.key)
            
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
