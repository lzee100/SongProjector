//
//  GenerateLyricsSheetContentUseCase.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation

struct GenerateLyricsSheetContentUseCase {
    
    private enum Bound {
        case lowerBound
        case upperBound
    }
    
    func getTitle(from text: String) -> String {
        let contentToDevide = text.split(separator: "\n\n").map(String.init)
        return contentToDevide.first ?? ""
    }
        
    func buildSheetsModels(from text: String, cluster: ClusterCodable) async throws -> [SheetViewModel] {
                
        let contentToDevide = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var sheetContent = contentToDevide.split(separator: "\n\n", omittingEmptySubsequences: false).map(String.init)
        guard sheetContent.filter({ !$0.isBlanc }).count > 0 else { return [] }
        sheetContent.removeFirst() // removes the title
        
        var models: [SheetViewModel] = []
        for (index, content) in sheetContent.enumerated() {
            if var newSheet = SheetTitleContentCodable.makeDefault(position: index, title: nil, content: content) {
                let defaultTheme = try await CreateThemeUseCase().create()
                let model = try await SheetViewModel(
                    cluster: cluster,
                    theme: cluster.theme,
                    defaultTheme: defaultTheme,
                    sheet: newSheet,
                    sheetType: newSheet.sheetType,
                    sheetEditType: .lyrics
                )
                models.append(model)
            }
        }
        return models
    }
    
    func getTextFrom(cluster: ClusterCodable, models: [SheetViewModel]) -> String {
                
        let titleAndContent = [cluster.title] + models.map { $0.sheetModel.content }
        
        return titleAndContent.compactMap { $0 }.joined(separator: "\n\n")
    }
}
