//
//  SyncUniversalCollectionsUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth

enum ContentPackage: String, CaseIterable, Identifiable {
    var id: String {
        return self.displayName
    }
    
    static let key = "contentPackage"
    static let keyContentPackageBabyChurchesMotherChurch = "contentPackageBabyChurchesMotherChurch"
    
    static let zwolleContent = [zwolleDutch, zwolleEnglish, zwolleMandarin]
    
    case zwolleDutch
    case zwolleEnglish
    case zwolleMandarin
    case pastorsZwolle
    case user // created by user
    
    init?(contentPackage: String?) {
        if let result = ContentPackage.allCases.first(where: { $0.rawValue == contentPackage }) {
            print(result)
            self = result
        } else {
            return nil
        }
    }
    
    var displayName: String {
        switch self {
        case .zwolleDutch: return AppText.Settings.contentPackageZwolleDutch
        case .zwolleEnglish: return AppText.Settings.contentPackageZwolleEnglish
        case .zwolleMandarin: return AppText.Settings.contentPackageZwolleMandarin
        case .pastorsZwolle: return AppText.Settings.contentPackagePastorsZwolle
        case .user: return "" // will not be used for display
        }
    }
}

actor SyncUniversalCollectionsUseCase: ObservableObject {
    
    @Published private(set) var isFetching = false
    private let endpoint = "fetchUniversalClustersWithUID"
    
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
            let url = URL(string: ChurchBeamConfiguration.environment.cloudFunctionsEndpoint + endpoint)!
            var request = URLRequest(url: url)
            request.addValue(token, forHTTPHeaderField: "Authorization")
            
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
