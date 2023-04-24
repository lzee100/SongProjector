//
//  SheetTypesMenu.swift
//  SongProjector
//
//  Created by Leo van der Zee on 27/09/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import UIKit

struct SheetTypeMenu {
    
    
    static func createMenu(delegate: SheetPickerMenuControllerDelegate, showLyricsOption: Bool, checkCustomSheets: @escaping (() -> Void), hasThemeSelected: (@escaping () -> Bool)) -> UIMenu {
        
        var menuActions: [UIMenu] = []

        if showLyricsOption {
            let song = UIAction(title: AppText.SheetsMenu.lyrics) { (_) in
                delegate.didSelectOption(option: .lyrics)
            }
            let songMenu = UIMenu(title: "Song", options: .displayInline, children: [song])
            menuActions.append(songMenu)
        }

        let sheetTitleContent = UIAction(title: AppText.SheetsMenu.sheetTitleText) { (_) in
            delegate.didSelectOption(option: .SheetTitleContent)
        }
        let sheetTitleImage = UIAction(title: AppText.SheetsMenu.sheetTitleImage) { (_) in
            delegate.didSelectOption(option: .SheetTitleImage)
        }
        let sheetPastors = UIAction(title: AppText.SheetsMenu.sheetPastors) { (_) in
            delegate.didSelectOption(option: .SheetPastors)
        }
        let sheetEmpty = UIAction(title: AppText.SheetsMenu.sheetEmpty) { (_) in
            delegate.didSelectOption(option: .SheetEmpty)
        }
        let sheetSplit = UIAction(title: AppText.SheetsMenu.sheetSplit) { (_) in
            delegate.didSelectOption(option: .SheetSplit)
        }
        let sheetActivities = UIAction(title: AppText.SheetsMenu.sheetActivity) { (_) in
            delegate.didSelectOption(option: .SheetActivities)
        }
        let customSheetsMenu = UIMenu(title: "Custom sheets", options: .displayInline, children: [sheetTitleContent, sheetTitleImage, sheetPastors, sheetEmpty, sheetSplit, sheetActivities])
        let bible = UIAction(title: AppText.SheetsMenu.bibleStudyGen) { (_) in
            if hasThemeSelected() {
                checkCustomSheets()
            }
        }
        let bibleMenu = UIMenu(title: "Bible", options: .displayInline, children: [bible])
        menuActions.append(contentsOf: [customSheetsMenu, bibleMenu])
        
        let menu = UIMenu(
            title: AppText.SheetPickerMenu.whichSheet,
          children: menuActions)
        
        return menu
        
    }
    
    
}
