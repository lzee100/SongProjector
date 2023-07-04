//
//  EntitySelectionModel.swift
//  SongProjector
//
//  Created by Leo van der Zee on 03/07/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct SelectionModel<T> where T: Identifiable {
    
    var mandatoryItems: [T]
    
    var items: [T] = []
    private(set) var selectedItems: [T]
    
    init(mandatoryItems: [T] = [], selectedItems: [T] = []) {
        self.mandatoryItems = mandatoryItems
        self.selectedItems = selectedItems
    }
    
    mutating func didSelect(_ item: T) {
        if selectedItems.contains(where: { $0.id == item.id }) {
            selectedItems.removeAll(where: { $0.id == item.id })
        } else {
            selectedItems.append(item)
        }
    }
}
