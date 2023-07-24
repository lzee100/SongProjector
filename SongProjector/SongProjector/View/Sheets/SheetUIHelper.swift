//
//  SheetUIHelper.swift
//  SongProjector
//
//  Created by Leo van der Zee on 21/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI

struct SheetUIHelper {
    
    @ViewBuilder static func sheet(ratioOnHeight: Bool = false, sheetViewModel: SheetViewModel, isForExternalDisplay: Bool) -> some View {
        switch sheetViewModel.sheetModel.sheet.sheetType {
        case .SheetTitleContent:
            TitleContentViewEditUI(sheetViewModel: sheetViewModel, isForExternalDisplay: isForExternalDisplay).applySheetRatioAndShadow()
        case .SheetTitleImage:
            TitleImageEditViewUI(sheetViewModel: sheetViewModel, isForExternalDisplay: isForExternalDisplay).applySheetRatioAndShadow()
        case .SheetEmpty:
            EmptyViewEditUI(sheetViewModel: sheetViewModel, isForExternalDisplay: isForExternalDisplay).applySheetRatioAndShadow()
        case .SheetPastors:
            PastorsViewEditUI(sheetViewModel: sheetViewModel, isForExternalDisplay: isForExternalDisplay).applySheetRatioAndShadow()
        case .SheetSplit:
            TitleContentViewEditUI(sheetViewModel: sheetViewModel, isForExternalDisplay: isForExternalDisplay).applySheetRatioAndShadow()
        case .SheetActivities:
            GoogleActivitiesViewEditUI(sheetViewModel: sheetViewModel, isForExternalDisplay: isForExternalDisplay).applySheetRatioAndShadow()
        }
    }
}
