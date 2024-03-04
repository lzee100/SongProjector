//
//  GetCollectionsEndpointUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 24/08/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

actor GetCollectionsEndpointUseCase {
    
    func get() async -> EndPoint {
        guard let user = await GetUserUseCase().get() else { return .clusters }
        var motherChurchEndpoint: EndPoint {
            let contentPackage = ContentPackage(contentPackage: user.contentPackage)
            switch contentPackage {
            case .zwolleDutch: return .universalclusterszwolledutch
            case .zwolleEnglish: return .universalclusterszwolleenglish
            case .zwolleMandarin: return .universalclusterszwollemandarin
            case .pastorsZwolle: return .universalclusterszwollebabychurches
            case .user, .none: return .clusters
            }
        }
        if uploadSecret != nil {
            if user.contentPackageBabyChurchesMotherChurch != nil {
                return .universalclusterszwollebabychurches
            } else {
                return motherChurchEndpoint
            }
        } else {
            return .clusters
        }
    }
    
}
