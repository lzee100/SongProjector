//
//  GenerateLyricsSheetContentUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct GenerateLyricsSheetContentUseCase {
    
    static func getTitle(from text: String) -> String {
        let start = text.index(text.startIndex, offsetBy: 0)
        guard let end = text.range(of: "\n\n") else { return "" }
        let cleanString = text.replacingOccurrences(of: "\n\n", with: "", options: .caseInsensitive, range: start..<end.upperBound)
        if let rangeTitle = cleanString.range(of: "\n"){
            let rangeSheetTitle = start..<rangeTitle.lowerBound
            return String(cleanString[rangeSheetTitle])
        }
        return ""
    }
    
    static func buildSheets(fromText: String, cluster: ClusterCodable) -> [EditSheetOrThemeViewModel] {
        
        var contentToDevide = fromText + "\n\n"
        
        // get title
        if let range = contentToDevide.range(of: "\n\n") {
            let start = contentToDevide.index(contentToDevide.startIndex, offsetBy: 0)
            let rangeRemove = start..<range.upperBound
            contentToDevide.removeSubrange(rangeRemove)
        }
        
        var position = 0
        var newSheets: [SheetTitleContentCodable] = []
        // get sheets
        while let range = contentToDevide.range(of: "\n\n") {
            
            // get content
            let start = contentToDevide.index(contentToDevide.startIndex, offsetBy: 0)
            let rangeSheet = start..<range.lowerBound
            let rangeRemove = start..<range.upperBound
            
            let sheetLyrics = String(contentToDevide[rangeSheet])
            var sheetTitle: String = ""
            
            // get title
            if let rangeTitle = contentToDevide.range(of: "\n"), position == 0 {
                let rangeSheetTitle = start..<rangeTitle.lowerBound
                sheetTitle = String(contentToDevide[rangeSheetTitle])
            }
            
            if let newSheet = SheetTitleContentCodable.makeDefault(position: position, title: sheetTitle, content: sheetLyrics) {
                newSheets.append(newSheet)
                position += 1
            }
            
            contentToDevide.removeSubrange(rangeRemove)
        }
                
        return newSheets.compactMap { EditSheetOrThemeViewModel(editMode: .sheet((cluster, $0), sheetType: $0.sheetType), isUniversal: uploadSecret != nil) }
    }

}
