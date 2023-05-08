//
//  Endpoints.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import CoreData

enum EndPoint: String {
    case admin
    case churches
    case clusters
    case songserviceplaydate
    case songservicesettings
    case tags
    case themes
    case universalclusters
    case universalupdatedat
    case users
    
    var lastUpdatedAt: Date? {
        switch self {
        case .admin:
            let entity: Admin? = DataFetcher().getLastUpdated(moc: newMOCBackground)
            return entity?.updatedAt?.date
        case .churches:
            let entity: Church? = DataFetcher().getLastUpdated(moc: newMOCBackground)
            return entity?.updatedAt?.date
        case .clusters:
            let entity: Cluster? = DataFetcher().getLastUpdated(moc: newMOCBackground)
            return entity?.updatedAt?.date
        case .songserviceplaydate:
            let entity: SongServicePlayDate? = DataFetcher().getLastUpdated(moc: newMOCBackground)
            return entity?.updatedAt?.date
        case .songservicesettings:
            let entity: SongServiceSettings? = DataFetcher().getLastUpdated(moc: newMOCBackground)
            return entity?.updatedAt?.date
        case .tags:
            let entity: Tag? = DataFetcher().getLastUpdated(moc: newMOCBackground)
            return entity?.updatedAt?.date
        case .themes:
            let entity: Theme? = DataFetcher().getLastUpdated(moc: newMOCBackground)
            return entity?.updatedAt?.date
        case .universalclusters:
            let entity: Cluster? = DataFetcher().getLastUpdated(moc: newMOCBackground)
            return entity?.updatedAt?.date
        case .universalupdatedat:
            let entity: UniversalUpdatedAtEntity? = DataFetcher().getLastUpdated(moc: newMOCBackground)
            return entity?.updatedAt?.date
        case .users:
            let entity: User? = DataFetcher().getLastUpdated(moc: newMOCBackground)
            return entity?.updatedAt?.date
        }
    }
}
