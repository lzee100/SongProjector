//
//  SongServiceDataSource.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/11/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import UIKit

enum SongServiceDataObject: Hashable {
    case cluster(cluster: VCluster)
    case sheet(sheet: VSheet)
    
    var cluster: VCluster? {
        switch self {
        case .cluster(cluster: let cluster): return cluster
        default: return nil
        }
    }
    var sheet: VSheet? {
        switch self {
        case .sheet(sheet: let sheet): return sheet
        default: return nil
        }
    }
}

class SongServiceDataSource: UITableViewDiffableDataSource<SongObject, VSheet> {
    
    static func snapshot() -> NSDiffableDataSourceSnapshot<SongObject, VSheet> {
        NSDiffableDataSourceSnapshot<SongObject, VSheet>()
    }
    
}
