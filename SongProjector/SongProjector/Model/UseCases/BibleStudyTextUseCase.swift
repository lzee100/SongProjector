//
//  BibleStudyTextUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 26/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import UIKit

struct BibleStudyTextUseCase {
    
    static func generateSheetsFromText(_ text: String, contentSize: CGSize, theme: ThemeCodable, scaleFactor: CGFloat, cluster: ClusterCodable) -> [EditSheetOrThemeViewModel] {
        
        let devided = text.components(separatedBy: "\n\n")
        let allTitles = devided.compactMap({ $0.split(separator: "\n").first }).compactMap({ String($0) })
        let onlyScriptures: [String] = devided.compactMap({
            guard $0.count > 1 else { return nil }
            var splitOnReturns = $0.split(separator: "\n")
            splitOnReturns.removeFirst()
            return splitOnReturns.joined(separator: "\n")
        })
        
        var sheetContent: [(title: String?, content: String)] = []
        
        for (index, title) in allTitles.enumerated() {
            let sheets = Self.splitContentIntoSheets((title, onlyScriptures[index]), contentSize: contentSize, theme: theme, scaleFactor: scaleFactor)
            sheetContent += sheets
        }
        
        return makeEditModel(sheetContent, cluster: cluster)
    }
    
    private static func splitContentIntoSheets(_ titleContent: (title: String, contentWithTitle: String), contentSize: CGSize, theme: ThemeCodable, scaleFactor: CGFloat) -> [(title: String?, content: String)] {
                
        let (title, contentWithTitle) = titleContent
        var content = contentWithTitle
        if let range = contentWithTitle.range(of: "\n" + title) {
            content.removeSubrange(range)
        }
        
        var contentWords = content.split(separator: " ")
        var currentContentString = ""
        var contentStrings: [String] = []
        
        repeat {
            if let word = contentWords.first {
                let wordAfterThisOne = contentWords[safe: 1]
                let subtitle = contentStrings.count == 0 ? "" : "\n" + title
                let words = [word, wordAfterThisOne].compactMap { $0 }.joined(separator: " ")
                
                if NSAttributedString(string: currentContentString + " " + words + subtitle, attributes: theme.getLyricsAttributes(scaleFactor)).height(containerWidth: contentSize.width) < contentSize.height {
                    currentContentString += " " + word
                    if contentWords.count == 1 {
                        contentStrings.append(currentContentString + " " + subtitle)
                    }
                } else if contentStrings.count == 0, NSAttributedString(string: currentContentString + " " + contentWords.joined(separator: " "), attributes: theme.getLyricsAttributes(scaleFactor)).height(containerWidth: contentSize.width) < contentSize.height {
                    currentContentString += " " + contentWords.joined(separator: " ")
                    contentStrings.append(currentContentString)
                    contentWords = [""]
                } else {
                    contentStrings.append(currentContentString + " " + subtitle)
                    currentContentString = String(word)
                }
                contentWords.removeFirst()
            }
        } while contentWords.count > 0
        
        var titleContentStrings: [(title: String?, content: String)] = []
        for (index, content) in contentStrings.enumerated() {
            if index == 0 {
                titleContentStrings.append((title, content))
            } else {
                titleContentStrings.append((nil, content))
            }
        }
        return titleContentStrings
    }
    
    private static func makeEditModel(_ sheetValues: [(title: String?, content: String)], cluster: ClusterCodable) -> [EditSheetOrThemeViewModel] {
        
        sheetValues.compactMap { titleContent in
            var sheet = SheetTitleContentCodable.makeDefault()
            sheet?.title = titleContent.title
            sheet?.content = titleContent.content
            
            guard let sheet, let model = EditSheetOrThemeViewModel(editMode: .sheet((cluster, sheet), sheetType: .SheetTitleContent), isUniversal: uploadSecret != nil) else {
                return nil
            }
            return model
        }
    }

}
