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

//    @ViewBuilder static func sheet(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, songServiceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) -> some View {
//        if sheet is SheetTitleContentCodable {
//            Self.sheetTitleContent(ratioOnHeight: ratioOnHeight, songServiceModel: songServiceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
//        } else if sheet is SheetTitleImageCodable {
//            Self.sheetTitleImage(ratioOnHeight: ratioOnHeight, serviceModel: songServiceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
//        } else if sheet is SheetPastors {
//            Self.sheetPastors(ratioOnHeight: ratioOnHeight, serviceModel: songServiceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
//        } else if sheet is SheetEmptyCodable {
//            Self.sheetEmpty(ratioOnHeight: ratioOnHeight, serviceModel: songServiceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
//        } else if sheet is SheetActivitiesCodable {
//            Self.sheetActivities(ratioOnHeight: ratioOnHeight, serviceModel: songServiceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
//        } else if sheet is SheetSplitCodable {
//            Self.sheetTitleContent(ratioOnHeight: ratioOnHeight, songServiceModel: songServiceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
//        }
//    }
//
//    @ViewBuilder static func sheetTitleContent(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, songServiceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) -> some View {
//        TitleContentViewDisplayUI(
//            songServiceModel: songServiceModel,
//            sheet: sheet,
//            isForExternalDisplay: isForExternalDisplay,
//            showSelectionCover: showSelectionCover
//        )
//        .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
//        .shadow(radius: 2)
//    }
//    
//    @ViewBuilder static func sheetTitleImage(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, serviceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) -> some View {
//        TitleImageDisplayViewUI(serviceModel: serviceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
//            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
//            .shadow(radius: 2)
//    }
//    
//    @ViewBuilder static func sheetEmpty(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, serviceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) -> some View {
//        EmptyViewDisplayUI(serviceModel: serviceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
//            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
//            .shadow(radius: 2)
//    }
//    
//    @ViewBuilder static func sheetPastors(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, serviceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) -> some View {
//        PastorsViewDisplayUI(serviceModel: serviceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
//            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
//            .shadow(radius: 2)
//    }
//    
//    @ViewBuilder static func sheetActivities(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, serviceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) -> some View {
//        GoogleActivitiesViewDisplayUI(songServiceModel: serviceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
//            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
//            .shadow(radius: 2)
//    }
//    
//    @ViewBuilder static func sheetTitleContent(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, editSheetOrThemeModel: WrappedStruct<SheetViewModel>, isForExternalDisplay: Bool = false, calculateBibleStudyContentSizeForSheetSize: CGSize) -> some View {
//        TitleContentViewEditUI(
//            editViewModel: editSheetOrThemeModel,
//            sheetSize: calculateBibleStudyContentSizeForSheetSize,
//            isForExternalDisplay: isForExternalDisplay
//        )
//        .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
//        .shadow(radius: 2)
//    }
//    
//    @ViewBuilder static func sheetTitleImage(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, editSheetOrThemeModel: WrappedStruct<SheetViewModel>, isForExternalDisplay: Bool = false) -> some View {
//        TitleImageEditViewUI(editViewModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
//            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
//            .shadow(radius: 2)
//    }
//    
//    @ViewBuilder static func sheetEmpty(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, editSheetOrThemeModel: WrappedStruct<SheetViewModel>, isForExternalDisplay: Bool = false) -> some View {
//        EmptyViewEditUI(editViewModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
//            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
//            .shadow(radius: 2)
//    }
//    
//    @ViewBuilder static func sheetPastors(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, editSheetOrThemeModel: WrappedStruct<SheetViewModel>, isForExternalDisplay: Bool = false) -> some View {
//        PastorsViewEditUI(editViewModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
//            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
//            .shadow(radius: 2)
//    }
//    
//    @ViewBuilder static func sheetActivities(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, editSheetOrThemeModel: WrappedStruct<SheetViewModel>, isForExternalDisplay: Bool = false) -> some View {
//        GoogleActivitiesViewEditUI(editViewModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
//            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
//            .shadow(radius: 2)
//    }
}
