//
//  SongServiceDataSource.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/11/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import UIKit

class SongServiceCollectionViewDataSource: UICollectionViewDiffableDataSource<SongObject, VSheet> {
    
    static func snapshot() -> NSDiffableDataSourceSnapshot<SongObject, VSheet> {
        NSDiffableDataSourceSnapshot<SongObject, VSheet>()
    }
    
}
