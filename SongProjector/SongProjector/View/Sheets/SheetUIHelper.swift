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
    
    @ViewBuilder static func sheet(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>, isForExternalDisplay: Bool, calculateBibleStudyContentSizeForSheetSize: CGSize = .zero) -> some View {
        switch editSheetOrThemeModel.item.sheetType {
        case .SheetTitleContent:
            Self.sheetTitleContent(ratioOnHeight: ratioOnHeight, maxWidth: maxWidth, editSheetOrThemeModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay, calculateBibleStudyContentSizeForSheetSize: calculateBibleStudyContentSizeForSheetSize)
        case .SheetTitleImage:
            Self.sheetTitleImage(ratioOnHeight: ratioOnHeight, maxWidth: maxWidth, editSheetOrThemeModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
        case .SheetPastors:
            Self.sheetPastors(ratioOnHeight: ratioOnHeight, maxWidth: maxWidth, editSheetOrThemeModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
        case .SheetEmpty:
            Self.sheetEmpty(ratioOnHeight: ratioOnHeight, maxWidth: maxWidth, editSheetOrThemeModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
        case .SheetActivities:
            Self.sheetActivities(ratioOnHeight: ratioOnHeight, maxWidth: maxWidth, editSheetOrThemeModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
        case .SheetSplit:
            Self.sheetTitleContent(ratioOnHeight: ratioOnHeight, maxWidth: maxWidth, editSheetOrThemeModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay, calculateBibleStudyContentSizeForSheetSize: calculateBibleStudyContentSizeForSheetSize)
        }
    }
    
    @ViewBuilder static func sheet(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, songServiceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) -> some View {
        if sheet is SheetTitleContentCodable {
            Self.sheetTitleContent(ratioOnHeight: ratioOnHeight, songServiceModel: songServiceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
        } else if sheet is SheetTitleImageCodable {
            Self.sheetTitleImage(ratioOnHeight: ratioOnHeight, serviceModel: songServiceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
        } else if sheet is SheetPastors {
            Self.sheetPastors(ratioOnHeight: ratioOnHeight, serviceModel: songServiceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
        } else if sheet is SheetEmptyCodable {
            Self.sheetEmpty(ratioOnHeight: ratioOnHeight, serviceModel: songServiceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
        } else if sheet is SheetActivitiesCodable {
            Self.sheetActivities(ratioOnHeight: ratioOnHeight, serviceModel: songServiceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
        } else if sheet is SheetSplitCodable {
            Self.sheetTitleContent(ratioOnHeight: ratioOnHeight, songServiceModel: songServiceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
        }
    }

    @ViewBuilder static func sheetTitleContent(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, songServiceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) -> some View {
        TitleContentViewDisplayUI(
            songServiceModel: songServiceModel,
            sheet: sheet,
            isForExternalDisplay: isForExternalDisplay,
            showSelectionCover: showSelectionCover
        )
        .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
        .shadow(radius: 2)
    }
    
    @ViewBuilder static func sheetTitleImage(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, serviceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) -> some View {
        TitleImageDisplayViewUI(serviceModel: serviceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
            .shadow(radius: 2)
    }
    
    @ViewBuilder static func sheetEmpty(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, serviceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) -> some View {
        EmptyViewDisplayUI(serviceModel: serviceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
            .shadow(radius: 2)
    }
    
    @ViewBuilder static func sheetPastors(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, serviceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) -> some View {
        PastorsViewDisplayUI(serviceModel: serviceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
            .shadow(radius: 2)
    }
    
    @ViewBuilder static func sheetActivities(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, serviceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) -> some View {
        GoogleActivitiesViewDisplayUI(songServiceModel: serviceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
            .shadow(radius: 2)
    }
    
    @ViewBuilder static func sheetTitleContent(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>, isForExternalDisplay: Bool = false, calculateBibleStudyContentSizeForSheetSize: CGSize) -> some View {
        TitleContentViewEditUI(
            editViewModel: editSheetOrThemeModel,
            sheetSize: calculateBibleStudyContentSizeForSheetSize,
            isForExternalDisplay: isForExternalDisplay
        )
        .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
        .shadow(radius: 2)
    }
    
    @ViewBuilder static func sheetTitleImage(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>, isForExternalDisplay: Bool = false) -> some View {
        TitleImageEditViewUI(editViewModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
            .shadow(radius: 2)
    }
    
    @ViewBuilder static func sheetEmpty(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>, isForExternalDisplay: Bool = false) -> some View {
        EmptyViewEditUI(editViewModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
            .shadow(radius: 2)
    }
    
    @ViewBuilder static func sheetPastors(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>, isForExternalDisplay: Bool = false) -> some View {
        PastorsViewEditUI(editViewModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
            .shadow(radius: 2)
    }
    
    @ViewBuilder static func sheetActivities(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>, isForExternalDisplay: Bool = false) -> some View {
        GoogleActivitiesViewEditUI(editViewModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
            .shadow(radius: 2)
    }
}
