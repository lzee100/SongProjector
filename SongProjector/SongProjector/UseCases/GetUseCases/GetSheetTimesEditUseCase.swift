//
//  GetSheetTimesEditUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct GetSheetTimesEditUseCase {
    
    static func getTimesFrom(_ value: String, sheetViewModels: [SheetViewModel]) -> [String] {
        let times = value.split(separator: "\n").map(String.init)
        return times
    }
}
