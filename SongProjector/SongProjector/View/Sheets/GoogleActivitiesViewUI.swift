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
    
    @ObservedObject private var sheetViewModel: SheetViewModel
    
    init(sheetViewModel: SheetViewModel, isForExternalDisplay: Bool) {
        self.sheetViewModel = sheetViewModel
        self.isForExternalDisplay = isForExternalDisplay
    }
    
    var body: some View {
        Group {
            GeometryReader { proxy in
                VStack {
                    if !hasNoTitle {
                        HStack {
                            Text(getTitleAttributedString(text: sheetViewModel.title, viewSize: proxy.size))
                                .modifier(SheetTitleEditUIModifier(scaleFactor: getScaleFactor(width: proxy.size.width), sheetViewModel: sheetViewModel))
                                .lineLimit(1)
                            if sheetViewModel.themeModel.theme.displayTime {
                                Spacer()
                                Text(getTitleAttributedString(text: Date().time, viewSize: proxy.size))
                                    .modifier(SheetTitleEditUIModifier(scaleFactor: getScaleFactor(width: proxy.size.width), sheetViewModel:  sheetViewModel))
                                    .lineLimit(1)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    getActivitiesRow(sheetProxy: proxy)
                        .padding(EdgeInsets(
                            top: getScaleFactor(width: proxy.size.width) * 10,
                            leading: getScaleFactor(width: proxy.size.width) * 10,
                            bottom: 0,
                            trailing: getScaleFactor(width: proxy.size.width) * 10)
                        )
                    
                    Spacer()
                }
            }
        }
        .setBackgroundImage(isForExternalDisplay: isForExternalDisplay, sheetViewModel: sheetViewModel)
        .modifier(SheetBackgroundColorAndOpacityEditModifier(sheetViewModel: sheetViewModel))
        .cornerRadius(isForExternalDisplay ? 0 : 10)
        .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
        .ignoresSafeArea()
        .shadow(radius: 6)
    }
    
    @ViewBuilder func getActivitiesRow(sheetProxy: GeometryProxy) -> some View {
        GeometryReader { proxy in
                VStack(spacing: 0) {
                    ForEach(googleActivities.prefix(getMaxItemsFor(height: proxy.size.height, viewSize: proxy.size)), id: \.self) { activity in
                        if proxy.size.height + activityRowHeight < sheetProxy.size.height {
                            HStack {
                                Text(getContentAttributedString(activity.startDate?.toString("E d MMM") ?? "-", viewSize: proxy.size))
                                Text(getContentAttributedString(activity.title ?? "-", viewSize: proxy.size))
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
    
    private func getTitleAttributedString(text: String, viewSize: CGSize) -> AttributedString {
        AttributedString(NSAttributedString(
            string: text,
            attributes: sheetViewModel.themeModel.theme.getTitleAttributes(getScaleFactor(width: viewSize.width))
        ))
    }
    
    private func getContentAttributedString(_ text: String, viewSize: CGSize) -> AttributedString {
        AttributedString(NSAttributedString(
            string: text,
            attributes: sheetViewModel.themeModel.theme.getLyricsAttributes(getScaleFactor(width: viewSize.width))
        ))
    }

    private var hasNoTitle: Bool {
        sheetViewModel.title.count == 0 && !sheetViewModel.themeModel.theme.displayTime
    }
    
    private func getSheetHeightFor(width: CGFloat) -> CGFloat {
        return externalDisplayWindowRatio * width
    }
    
    private var googleActivities: [GoogleActivityCodable] {
        (sheetViewModel.sheetModel.sheet as? SheetActivitiesCodable)?.hasGoogleActivities ?? []
    }
    
    private func getMaxItemsFor(height: CGFloat, viewSize: CGSize) -> Int {
        guard height > 0, activityRowHeight > 0 else { return 0 }
        
        let bottomMargin = getScaleFactor(width: viewSize.width) * 10
        let rowHeight = CGFloat(activityRowHeight)
        let one: Int = 1 // line outside of foreach to calculate height
        
        return max(0, Int(((height - bottomMargin) / rowHeight).rounded(.down)) - one)
    }
}
