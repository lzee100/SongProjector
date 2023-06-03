//
//  BibleStudyTextUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 26/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import UIKit

actor BibleStudyTextUseCase {
    
    enum SheetContent {
        case titleContent(title: String?, content: String)
        case empty
    }
    
    func generateSheetsFromText(_ text: String, parentViewSize: CGSize, theme: ThemeCodable, scaleFactor: CGFloat, cluster: ClusterCodable) async throws -> [SheetViewModel] {
        
        let contentSize = calculateContentsize(parentViewSize: parentViewSize, theme: theme, scaleFactor: scaleFactor)
        let devided = text.components(separatedBy: "\n\n")
        let allTitles = devided.compactMap({ $0.split(separator: "\n").first }).map({ String($0) })
        let onlyScriptures: [String] = devided.compactMap({
            guard $0.count > 1 else { return nil }
            var splitOnReturns = $0.split(separator: "\n")
            splitOnReturns.removeFirst()
            return splitOnReturns.joined(separator: "\n")
        })
        print(contentSize)
        var position: Int = 0
        var sheetContent: [SheetContent] = []
        
        for (index, title) in allTitles.enumerated() {
            let sheets = splitContentIntoSheets((title, onlyScriptures[index]), contentSize: contentSize, theme: theme, scaleFactor: scaleFactor)
            sheetContent += (sheets.map { .titleContent(title: $0.title, content: $0.content)} + [.empty])
        }
        
        return try await makeEditModel(sheetContent, cluster: cluster, position: &position)
    }
    
    func getTextFromSheets(models: [SheetViewModel]) async -> String {
        let bibleVersSheetsSplit = models.map { $0.sheetModel.sheet }.filter { $0.isBibleVers }.split(whereSeparator: { $0 is SheetEmptyCodable })

        let text = bibleVersSheetsSplit.compactMap { Array($0) as? [SheetTitleContentCodable] }.compactMap { sheets in
            var sheetContent = sheets.compactMap { $0.sheetContent }.joined(separator: "")
            sheetContent = sheetContent.replacingOccurrences(of: ("\n\(sheets.first?.title ?? "")"), with: "")
            return (title: sheets.first?.title ?? "", content: sheetContent.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        return text.compactMap({ [$0.title, $0.content].joined(separator: "\n")}).joined(separator: "\n\n")
    }

    private func splitContentIntoSheets(_ titleContent: (title: String, contentWithTitle: String), contentSize: CGSize, theme: ThemeCodable, scaleFactor: CGFloat) -> [(title: String?, content: String)] {
        
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
    
    private func makeEditModel(_ sheetValues: [SheetContent], cluster: ClusterCodable, position: inout Int) async throws -> [SheetViewModel] {
        
        let defaultTheme = try await CreateThemeUseCase().create()

        return try await sheetValues.asyncMap { sheetContent in
            
            func makeModel(sheet: SheetMetaType?, type: SheetType) async throws -> SheetViewModel? {
                guard let sheet else { return nil }
                let model = try await SheetViewModel(cluster: cluster, theme: cluster.theme, defaultTheme: defaultTheme, sheet: sheet, sheetType: type, sheetEditType: .bibleStudy)
                return model
            }
            
            var sheet: SheetMetaType?
            let sheetType: SheetType
            switch sheetContent {
            case .titleContent(title: let title, content: let content):
                var titleContent = SheetTitleContentCodable.makeDefault()
                titleContent?.title = title
                titleContent?.content = content
                titleContent?.isBibleVers = true
                titleContent?.position = position
                sheet = titleContent
                sheetType = .SheetTitleContent
            case .empty:
                var emptySheet = SheetEmptyCodable.makeDefault()
                emptySheet?.isEmptySheet = true
                emptySheet?.position = position
                sheet = emptySheet
                sheetType = .SheetEmpty
            }
            
            position += 1
            return try await makeModel(sheet: sheet, type: sheetType)
        }.compactMap { $0 }
    }
    
    private func calculateContentsize(parentViewSize: CGSize, theme: ThemeCodable, scaleFactor: CGFloat) -> CGSize {
        
        let sheetSize = getSizeWith(width: parentViewSize.width)
        let leadingTrailingMargins: CGFloat = 10 * scaleFactor * 2
        let topBottomMargin: CGFloat = 10 * scaleFactor
        let titleContentPadding: CGFloat = 10 * scaleFactor
        let maxContentWidth = sheetSize.width - leadingTrailingMargins - 10

        let titleHeight = NSAttributedString(
            string: "k",
            attributes: theme.getTitleAttributes(scaleFactor)
        ).height(containerWidth: maxContentWidth)
        
        let contentHeight = sheetSize.height - topBottomMargin - titleHeight - titleContentPadding - topBottomMargin - 10
        
        return CGSize(width: maxContentWidth, height: contentHeight)
        
    }

}
