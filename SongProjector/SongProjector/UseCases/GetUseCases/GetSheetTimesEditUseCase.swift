//
//  GetSheetTimesEditUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct GetSheetTimesEditUseCase {
    
    enum SheetTimeError: LocalizedError {
        case incorrectNumberOfTimesComparedToSheet
        
        var errorDescription: String? {
            return "Number of times is not equal to the number of sheets."
        }
    }
    
    static func getTimesFrom(_ value: String, sheetViewModels: [SheetViewModel]) throws -> [String] {
        let times = value.split(separator: "\n").map(String.init)
        guard times.count == sheetViewModels.count else {
            throw SheetTimeError.incorrectNumberOfTimesComparedToSheet
        }
        return times
    }
}
