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
    
    @ViewBuilder static func sheet(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>, isForExternalDisplay: Bool) -> some View {
        switch editSheetOrThemeModel.item.sheetType {
        case .SheetTitleContent:
            Self.sheetTitleContent(ratioOnHeight: ratioOnHeight, maxWidth: maxWidth, editSheetOrThemeModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
        case .SheetTitleImage:
            Self.sheetTitleImage(ratioOnHeight: ratioOnHeight, maxWidth: maxWidth, editSheetOrThemeModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
        case .SheetPastors:
            Self.sheetPastors(viewSize: viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth, editSheetOrThemeModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
        case .SheetEmpty:
            Self.sheetEmpty(viewSize: viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth, editSheetOrThemeModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
        case .SheetActivities:
            Self.sheetActivities(viewSize: viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth, editSheetOrThemeModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
        case .SheetSplit:
            Self.sheetTitleContent(viewSize: viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth, editSheetOrThemeModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
        }
    }
    
    @ViewBuilder static func sheet(viewSize: CGSize, ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, songServiceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) -> some View {
        if sheet is SheetTitleContentCodable {
            Self.sheetTitleContent(viewSize: viewSize, ratioOnHeight: ratioOnHeight, songServiceModel: songServiceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
        } else if sheet is SheetTitleImageCodable {
            Self.sheetTitleImage(viewSize: viewSize, ratioOnHeight: ratioOnHeight, serviceModel: songServiceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
        } else if sheet is SheetPastors {
            Self.sheetPastors(viewSize: viewSize, ratioOnHeight: ratioOnHeight, serviceModel: songServiceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
        } else if sheet is SheetEmptyCodable {
            Self.sheetEmpty(viewSize: viewSize, ratioOnHeight: ratioOnHeight, serviceModel: songServiceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
        } else if sheet is SheetActivitiesCodable {
            Self.sheetActivities(viewSize: viewSize, ratioOnHeight: ratioOnHeight, serviceModel: songServiceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
        } else if sheet is SheetSplitCodable {
            Self.sheetTitleContent(ratioOnHeight: ratioOnHeight, songServiceModel: songServiceModel, sheet: sheet, isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
        }
    }

    @ViewBuilder static func sheetTitleContent(ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, songServiceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) -> some View {
        TitleContentViewDisplayUI(
            songServiceModel: songServiceModel,
            sheet: sheet,
            scaleFactor: Self.getScaleFactorFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth),
            isForExternalDisplay: isForExternalDisplay,
            showSelectionCover: showSelectionCover
        )
        .aspectRatio(16 / 9, contentMode: .fit)
        .shadow(radius: 2)
    }
    
    @ViewBuilder static func sheetTitleImage(viewSize: CGSize, ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, serviceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) -> some View {
        TitleImageDisplayViewUI(serviceModel: serviceModel, sheet: sheet, scaleFactor: getScaleFactorFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth), isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
            .frame(
                width: getWidthBasedOn(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth),
                height: getSheetSizeFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth).height
            )
            .shadow(radius: 2)
    }
    
    @ViewBuilder static func sheetEmpty(viewSize: CGSize, ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, serviceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) -> some View {
        EmptyViewDisplayUI(serviceModel: serviceModel, sheet: sheet, scaleFactor: getScaleFactorFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth), isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
            .aspectRatio(16 / 9, contentMode: .fit)
            .shadow(radius: 2)
    }
    
    @ViewBuilder static func sheetPastors(viewSize: CGSize, ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, serviceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) -> some View {
        PastorsViewDisplayUI(serviceModel: serviceModel, sheet: sheet, scaleFactor: getScaleFactorFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth), isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
            .frame(
                width: getWidthBasedOn(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth),
                height: getSheetSizeFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth).height
            )
            .shadow(radius: 2)
    }
    
    @ViewBuilder static func sheetActivities(viewSize: CGSize, ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, serviceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) -> some View {
        GoogleActivitiesViewDisplayUI(songServiceModel: serviceModel, sheet: sheet, scaleFactor: getScaleFactorFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth), isForExternalDisplay: isForExternalDisplay, showSelectionCover: showSelectionCover)
            .frame(
                width: getWidthBasedOn(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth),
                height: getSheetSizeFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth).height
            )
            .shadow(radius: 2)
    }
    
    @ViewBuilder static func sheetTitleContent(viewSize: CGSize, ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>, isForExternalDisplay: Bool = false) -> some View {
        TitleContentViewEditUI(
            editViewModel: editSheetOrThemeModel,
            scaleFactor: Self.getScaleFactorFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth),
            isForExternalDisplay: isForExternalDisplay
        )
        .frame(
            width: getWidthBasedOn(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth),
            height: getSheetSizeFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth).height
        )
        .shadow(radius: 2)
    }
    
    @ViewBuilder static func sheetTitleImage(viewSize: CGSize, ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>, isForExternalDisplay: Bool = false) -> some View {
        TitleImageEditViewUI(editViewModel: editSheetOrThemeModel, scaleFactor: getScaleFactorFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth), isForExternalDisplay: isForExternalDisplay)
            .frame(
                width: getWidthBasedOn(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth),
                height: getSheetSizeFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth).height
            )
            .shadow(radius: 2)
    }
    
    @ViewBuilder static func sheetEmpty(viewSize: CGSize, ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>, isForExternalDisplay: Bool = false) -> some View {
        EmptyViewEditUI(editViewModel: editSheetOrThemeModel, isForExternalDisplay: isForExternalDisplay)
            .frame(
                width: getWidthBasedOn(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth),
                height: getSheetSizeFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth).height
            )
            .shadow(radius: 2)
    }
    
    @ViewBuilder static func sheetPastors(viewSize: CGSize, ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>, isForExternalDisplay: Bool = false) -> some View {
        PastorsViewEditUI(editViewModel: editSheetOrThemeModel, scaleFactor: getScaleFactorFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth), isForExternalDisplay: isForExternalDisplay)
            .frame(
                width: getWidthBasedOn(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth),
                height: getSheetSizeFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth).height
            )
            .shadow(radius: 2)
    }
    
    @ViewBuilder static func sheetActivities(viewSize: CGSize, ratioOnHeight: Bool = false, maxWidth: CGFloat? = nil, editSheetOrThemeModel: WrappedStruct<EditSheetOrThemeViewModel>, isForExternalDisplay: Bool = false) -> some View {
        GoogleActivitiesViewEditUI(editViewModel: editSheetOrThemeModel, scaleFactor: getScaleFactorFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth), isForExternalDisplay: isForExternalDisplay)
            .frame(
                width: getWidthBasedOn(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth),
                height: getSheetSizeFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth).height
            )
            .shadow(radius: 2)
    }
    
    static func getWidthBasedOn(_ viewSize: CGSize, ratioOnHeight: Bool, maxWidth: CGFloat? = nil) -> CGFloat {
        getSheetSizeFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth).width == nil ? getSizeWith(height: getSheetSizeFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth).height).width : getSheetSizeFor(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth).width!
    }
    
    static func getScaleFactorFor(_ viewSize: CGSize, ratioOnHeight: Bool, maxWidth: CGFloat? = nil) -> CGFloat {
        getScaleFactor(width: getWidthBasedOn(viewSize, ratioOnHeight: ratioOnHeight, maxWidth: maxWidth))
    }
    
    private static func getSheetSizeFor(_ containerSize: CGSize, ratioOnHeight: Bool, maxWidth: CGFloat? = nil) -> (width: CGFloat?, height: CGFloat) {
        
        var width: CGFloat {
            if let maxWidth {
                return min(containerSize.width, maxWidth)
            }
            return containerSize.width
        }
        
        if ratioOnHeight {
            return (width: containerSize.height * externalDisplayWindowRatioHeightWidth, height: containerSize.height)
        } else {
            return (width: containerSize.width > containerSize.height ? width : nil,
             height: getSizeWith(width: containerSize.width > containerSize.height ? width : containerSize.width).height
            )
        }
    }
    
    
}
