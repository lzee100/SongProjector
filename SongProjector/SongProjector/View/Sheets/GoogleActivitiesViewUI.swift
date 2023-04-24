//
//  GoogleActivitiesViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 19/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct GoogleActivitiesViewEditUI: View {
    
    @State private var activityRowHeight: CGFloat = 1
    private let isForExternalDisplay: Bool
    private let scaleFactor: CGFloat
    
    @ObservedObject private var editViewModel: WrappedStruct<EditSheetOrThemeViewModel>
    
    init(editViewModel: WrappedStruct<EditSheetOrThemeViewModel>, scaleFactor: CGFloat, isForExternalDisplay: Bool) {
        self.editViewModel = editViewModel
        self.scaleFactor = scaleFactor
        self.isForExternalDisplay = isForExternalDisplay
    }
    
    var body: some View {
        Group {
            GeometryReader { proxy in
                VStack {
                    if !hasNoTitle {
                        HStack {
                            Text(getTitleAttributedString(text: editViewModel.item.title))
                                .modifier(SheetTitleEditUIModifier(scaleFactor: scaleFactor, editViewModel: editViewModel))
                                .lineLimit(1)
                            if editViewModel.item.displayTime {
                                Spacer()
                                Text(getTitleAttributedString(text: Date().time))
                                    .modifier(SheetTitleEditUIModifier(scaleFactor: scaleFactor, editViewModel: editViewModel))
                                    .lineLimit(1)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    getActivitiesRow(sheetProxy: proxy)
                        .padding(EdgeInsets(
                            top: getScaledValue(10),
                            leading: getScaledValue(10),
                            bottom: 0,
                            trailing: getScaledValue(10))
                        )
                    
                    Spacer()
                }
            }
        }
        .background(.gray)
        .setBackgroundImage(isForExternalDisplay: isForExternalDisplay, editModel: editViewModel)
        .modifier(SheetBackgroundColorAndOpacityEditModifier(editViewModel: editViewModel))
        .cornerRadius(10)
        .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
        .ignoresSafeArea()
        .shadow(radius: 6)
        .onChange(of: activityRowHeight) { newValue in
            print(newValue)
        }
    }
    
    @ViewBuilder func getActivitiesRow(sheetProxy: GeometryProxy) -> some View {
        GeometryReader { proxy in
                VStack(spacing: 0) {
                    if googleActivities.count > 0 {
                        HStack {
                            Text(getContentAttributedString(Date().toString("d MMMM hh:mm")))
                            Text(getContentAttributedString("Geweldige activiteiten hier"))
                            Spacer()
                        }.observeViewSize()
                    }
                    ForEach(googleActivities.prefix(getMaxItemsFor(height: proxy.size.height)), id: \.self) { activity in
                        if proxy.size.height + activityRowHeight < sheetProxy.size.height {
                            HStack {
                                Text(getContentAttributedString(activity.startDate?.toString("d MMMM hh:mm") ?? "-"))
                                Text(getContentAttributedString(activity.eventDescription ?? "-"))
                                Spacer()
                            }.observeViewSize()
                        }
                    }
                }.onPreferenceChange(SizePreferenceKey.self) { size in
                    if size.height > 0 {
                        activityRowHeight = size.height
                    }
                }
        }
    }
    
    private func getTitleAttributedString(text: String) -> AttributedString {
        AttributedString(NSAttributedString(
            string: text,
            attributes: editViewModel.item.getTitleAttributes(scaleFactor)
        ))
    }
    
    private func getContentAttributedString(_ text: String) -> AttributedString {
        AttributedString(NSAttributedString(
            string: text,
            attributes: editViewModel.item.getLyricsAttributes(scaleFactor)
        ))
    }

    private var hasNoTitle: Bool {
        editViewModel.item.title.count == 0 && !editViewModel.item.displayTime
    }
    
    private func getScaledValue(_ factor: CGFloat) -> CGFloat {
        factor * scaleFactor
    }
    
    private func getSheetHeightFor(width: CGFloat) -> CGFloat {
        return externalDisplayWindowRatio * width
    }
    
    private var googleActivities: [GoogleActivityCodable] {
        (editViewModel.item.sheet as? SheetActivitiesCodable)?.hasGoogleActivities ?? []
    }
    
    private func getMaxItemsFor(height: CGFloat) -> Int {
        guard height > 0, activityRowHeight > 0 else { return 0 }
        
        let bottomMargin = getScaledValue(10)
        let rowHeight = CGFloat(activityRowHeight)
        let one: Int = 1 // line outside of foreach to calculate height
        
        return max(0, Int(((height - bottomMargin) / rowHeight).rounded(.down)) - one)
    }
}

struct GoogleActivitiesViewUI_Previews: PreviewProvider {
    @State static var imageSheet = SheetTitleImageCodable.makeDefault()
        @State static var editModel = WrappedStruct(withItem: EditSheetOrThemeViewModel(editMode: .sheet(imageSheet, sheetType: .SheetTitleImage), isUniversal: false, image: UIImage(named: "Pio-Sebastiaan-en-Marilou.jpg"))!)

    static var previews: some View {
        GoogleActivitiesViewEditUI(editViewModel: editModel, scaleFactor: 1, isForExternalDisplay: false)
    }
}

struct GoogleActivitiesViewDisplayUI: View {
    
    
    @State private var activityRowHeight: CGFloat = .zero
    private let isForExternalDisplay: Bool
    private let scaleFactor: CGFloat
    @ObservedObject private var songServiceModel: WrappedStruct<SongServiceUI>
    private let sheet: SheetMetaType
    private let showSelectionCover: Bool
    private let theme: ThemeCodable?
    private var titleAlignmentNumber: Int {
        theme?.titleAlignmentNumber.intValue ?? 0
    }
    private var contentAlignmentNumber: Int {
        theme?.contentAlignmentNumber.intValue ?? 0
    }
    
    init(songServiceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, scaleFactor: CGFloat, isForExternalDisplay: Bool, showSelectionCover: Bool) {
        self.songServiceModel = songServiceModel
        self.sheet = sheet
        self.scaleFactor = scaleFactor
        self.isForExternalDisplay = isForExternalDisplay
        self.showSelectionCover = showSelectionCover
        self.theme = songServiceModel.item.themeFor(sheet: sheet)
    }
    var body: some View {
        Group {
            GeometryReader { proxy in
                VStack {
                    if !hasNoTitle {
                        HStack {
                            Text(getTitleAttributedString(text: songServiceModel.item.sheetTitleFor(sheet: sheet) ?? ""))
                                .modifier(SheetTitleDisplayUIModifier(
                                    scaleFactor: scaleFactor,
                                    alignmentNumber: titleAlignmentNumber,
                                    frameWidth: .infinity
                                ))
                            if theme?.displayTime ?? false {
                                Spacer()
                                Text(getTitleAttributedString(text: Date().time))
                                    .modifier(SheetTitleDisplayUIModifier(
                                        scaleFactor: scaleFactor,
                                        alignmentNumber: titleAlignmentNumber
                                    ))
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    getActivitiesRow(sheetProxy: proxy)
                        .padding(EdgeInsets(
                            top: getScaledValue(10),
                            leading: getScaledValue(10),
                            bottom: 0,
                            trailing: getScaledValue(10))
                        )
                    Spacer()
                }
            }
        }
        .setBackgroundImage(isForExternalDisplay: false, theme: theme)
        .modifier(SheetBackgroundColorAndOpacityModifier(sheetTheme: theme))
        .cornerRadius(10)
        .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
        .ignoresSafeArea()
        .overlay {
            if songServiceModel.item.selectedSheetId != sheet.id, showSelectionCover {
                Rectangle()
                    .fill(.black.opacity(0.3))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .shadow(radius: 6)
        .onChange(of: activityRowHeight) { newValue in
            print(newValue)
        }
    }
    
    @ViewBuilder func getActivitiesRow(sheetProxy: GeometryProxy) -> some View {
        GeometryReader { proxy in
                VStack(spacing: 0) {
                    if googleActivities.count > 0 {
                        HStack {
                            if let text = getContentAttributedString(Date().toString("d MMMM hh:mm")) {
                                Text(text)
                            }
                            if let text = getContentAttributedString("Geweldige activiteiten hier") {
                                Text(text)
                            }
                            Spacer()
                        }.observeViewSize()
                    }
                    ForEach(googleActivities.prefix(getMaxItemsFor(height: proxy.size.height)), id: \.self) { activity in
                        if proxy.size.height + activityRowHeight < sheetProxy.size.height {
                            HStack {
                                if let text = getContentAttributedString(activity.startDate?.toString("d MMMM hh:mm") ?? "-") {
                                    Text(text)
                                }
                                if let text = getContentAttributedString(activity.eventDescription ?? "-") {
                                    Text(text)
                                }
                                Spacer()
                            }.observeViewSize()
                        }
                    }
                }.onPreferenceChange(SizePreferenceKey.self) { size in
                    if size.height > 0 {
                        activityRowHeight = size.height
                    }
                }
        }
    }
    
    private func getTitleAttributedString(text: String) -> AttributedString {
        AttributedString(NSAttributedString(
            string: text,
            attributes: theme?.getTitleAttributes(scaleFactor) ?? [:]
        ))
    }
    
    private func getContentAttributedString(_ text: String?) -> AttributedString? {
        guard let content = text else { return nil }
        return AttributedString(NSAttributedString(
            string: content,
            attributes: theme?.getLyricsAttributes(scaleFactor) ?? [:]
        ))
    }
    
    private var hasNoTitle: Bool {
        songServiceModel.item.sheetTitleFor(sheet: sheet)?.count ?? 0 == 0 && !(theme?.displayTime ?? true)
    }
    
    private func getScaledValue(_ factor: CGFloat) -> CGFloat {
        factor * scaleFactor
    }
    
    private func getSheetHeightFor(width: CGFloat) -> CGFloat {
        return externalDisplayWindowRatio * width
    }
    
    private var googleActivities: [GoogleActivityCodable] {
        (sheet as? SheetActivitiesCodable)?.hasGoogleActivities ?? []
    }
    
    private func getMaxItemsFor(height: CGFloat) -> Int {
        guard height > 0, activityRowHeight > 0 else { return 0 }
        
        let bottomMargin = getScaledValue(10)
        let rowHeight = CGFloat(activityRowHeight)
        let one: Int = 1 // line outside of foreach to calculate height
        
        return max(0, Int(((height - bottomMargin) / rowHeight).rounded(.down)) - one)
    }
}
