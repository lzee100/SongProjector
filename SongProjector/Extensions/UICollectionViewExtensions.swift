//
//  UICollectionViewExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/07/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit

extension UICollectionView {
    
    public func register(cell: String) {
        register(nib: cell, identifier: cell)
    }
    
    public func register(cells: [String]) {
        cells.forEach({ register(nib: $0, identifier: $0) })
    }
    
    public func register(nib: String, identifier: String) {
        register(UINib(nibName: nib, bundle: nil), forCellWithReuseIdentifier: identifier)
    }
    
    public func registerHeader(reusableView: String) {
        register(UINib(nibName: reusableView, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: reusableView)
    }
    
    public func registerFooter(reusableView: String) {
        register(UINib(nibName: reusableView, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: reusableView)
    }

}
