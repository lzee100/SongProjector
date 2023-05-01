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
    
//    static func getTextFromSheets(sheets: [SheetMetaType]) -> String {
//        guard sheets.count > 0 else { return "" }
//        var titleContentSheets = sheets
//        titleContentSheets = titleContentSheets.filter({ $0.theme == nil })
//        
//        var totalString = ""
//        var currentTitle = ""
//        var currentScripture = ""
//        
//        repeat {
//            let sheet = titleContentSheets.first
//            
//            if let sheet = sheet as? SheetTitleContentCodable {
//                currentTitle = sheet.title ?? ""
//                currentScripture = [currentScripture, sheet.content ?? ""].joined(separator: " ").trimmingCharacters(in: .whitespaces)
//            } else if sheet is SheetEmptyCodable {
//                currentScripture = currentScripture.replacingOccurrences(of: "\n\(currentTitle)", with: "")
//                var addSpace = false
//                if titleContentSheets.filter({ $0 is SheetEmptyCodable }).count > 1 {
//                    addSpace = true
//                }
//                totalString += currentScripture
//                totalString += addSpace ? "\n\n" : ""
//                currentScripture = ""
//            }
//            titleContentSheets.remove(at: 0)
//            
//        } while titleContentSheets.count > 0
//        
//        return totalString
//    }
//    
//    static func buildBibleSheets(fromText: String, viewSize: CGSize, theme: ThemeCodable) -> [EditSheetOrThemeViewModel] {
//        
//        var position = 0
//        var newSheets: [EditSheetOrThemeViewModel] = []
//        // get sheets
//        
//        let devided = fromText.components(separatedBy: "\n\n")
//        let allTitles = devided.compactMap({ $0.split(separator: "\n").first }).compactMap({ String($0) })
//        let onlyScriptures: [String] = devided.compactMap({
//            guard $0.count > 1 else { return nil }
//            var splitOnReturns = $0.split(separator: "\n")
//            splitOnReturns.removeFirst()
//            return splitOnReturns.joined(separator: "\n")
//        })
//        
//        for (index, title) in allTitles.enumerated() {
//            let sheets = Self.getSheetsFor(viewSize: viewSize, text: onlyScriptures[index], position: &position, title: title, selectedTheme: theme)
//            newSheets.append(contentsOf: sheets)
//            position += 1
//        }
//        
//        newSheets.sort{ $0.position < $1.position }
//        
//        return newSheets
//    }
//
//    private static func getSheetsFor(viewSize: CGSize, text: String, position: inout Int, title: String, selectedTheme: ThemeCodable) -> [EditSheetOrThemeViewModel] {
//        
//        var textWithoutTitle = text
//        if let range = text.range(of: "\n" + title) {
//            textWithoutTitle.removeSubrange(range)
//        }
//        let sheetHeight = UIDevice.current.userInterfaceIdiom == .pad ? getSizeWith(height: viewSize.height).height : getSizeWith(height: nil, width: viewSize.width).height
//        let topBottomMargin: CGFloat = 3 * 10 * getScaleFactor(width: viewSize.width) // superview top to title top, title bottom to tv top, tv bottom to superview bottom
//        let textViewHeight = sheetHeight - topBottomMargin
//        var words = textWithoutTitle.words
//        var currentSheetText: [String] = []
//        var sheetTexts: [String ] = []
//        var sheets: [EditSheetOrThemeViewModel] = []
//        
//        let width: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? getSizeWith(height: viewSize.height).width : getSizeWith(height: nil, width: viewSize.width).width
//        let scaleFactor = getScaleFactor(width: width)
//        let attributes = selectedTheme.getLyricsAttributes(scaleFactor)
//        let font = (attributes[.font] as? UIFont) ?? UIFont.normal
//        let textViewPaddings: CGFloat = 2 * 10 * scaleFactor
//        
//        func isLessThanHeightTextViewFor(sheetNumber: Int) -> Bool {
//            let subTitle = sheetNumber == 0 ? "" : "\n" + title
//            let title = sheetNumber == 0 ? title + "\n" : ""
//            let nextSheetText = ([title] + currentSheetText + [String(words.first ?? "")] + [subTitle]).joined(separator: " ")
//            return nextSheetText.height(withConstrainedWidth: width - textViewPaddings, font: font) < textViewHeight
//        }
//        
//        repeat {
//            
//            repeat {
//                if let word = words.first {
//                    currentSheetText.append(String(word))
//                    words.removeFirst()
//                }
//            } while isLessThanHeightTextViewFor(sheetNumber: sheetTexts.count) && words.count > 0
//            
//            if sheetTexts.count == 0 {
//                sheetTexts.append(title + "\n" + currentSheetText.joined(separator: " "))
//            } else {
//                sheetTexts.append(currentSheetText.joined(separator: " ") + "\n" + title)
//            }
//            currentSheetText = []
//            
//        } while words.count > 0
//        
//        for sheetText in sheetTexts {
//            var newSheet = EditSheetOrThemeViewModel(editMode: .sheet(nil, sheetType: .SheetTitleContent), isUniversal: uploadSecret != nil)
//            newSheet?.isBibleVers = true
//            newSheet?.title = title
//            newSheet?.sheetContent = sheetText
//            newSheet?.position = position
//            if let newSheet {
//                sheets.append(newSheet)
//                position += 1
//            }
//        }
//        var sheet = EditSheetOrThemeViewModel(editMode: .sheet(nil, sheetType: .SheetEmpty), isUniversal: uploadSecret != nil)
//        sheet?.position = position
//        if let sheet {
//            sheets.append(sheet)
//            position += 1
//        }
//        
//        return sheets
//    }
    
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
