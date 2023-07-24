//
//  TitleImageViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct TitleImageEditViewUI: View {
    
    @ObservedObject private var sheetViewModel: SheetViewModel
    
    private let isForExternalDisplay: Bool
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var time = Date().time

    init(sheetViewModel: SheetViewModel, isForExternalDisplay: Bool) {
        self.sheetViewModel = sheetViewModel
        self.isForExternalDisplay = isForExternalDisplay
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                
                if !hasNoTitle {
                    HStack {
                        Text(getTitleAttributedString(sheetViewModel.title, viewSize: proxy.size))
                            .modifier(SheetTitleEditUIModifier(scaleFactor: getScaleFactor(width: proxy.size.width), sheetViewModel: sheetViewModel, frameWidth: .infinity))
                            .lineLimit(1)
                        if sheetViewModel.displayTime {
                            Spacer()
                            Text(getTitleAttributedString(time, viewSize: proxy.size))
                                .modifier(SheetTitleEditUIModifier(scaleFactor: getScaleFactor(width: proxy.size.width), sheetViewModel: sheetViewModel))
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                if sheetViewModel.sheetModel.content.count > 0 {
                    HStack{
                        if [1, 2].contains(sheetViewModel.themeModel.theme.contentAlignmentNumber.intValue) {
                            Spacer()
                        }
                        Text(getContentAttributedString(viewSize: proxy.size))
                            .modifier(SheetContentEditModifier(scaleFactor: getScaleFactor(width: proxy.size.width), multiLine: false, sheetViewModel: sheetViewModel))
                        if [0, 1].contains(sheetViewModel.themeModel.theme.contentAlignmentNumber.intValue) {
                            Spacer()
                        }
                    }
                }
                if let uiImage = sheetViewModel.sheetModel.getImage(thumb: true) {
                    HStack {
                        Spacer()
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(uiImage.size, contentMode: .fit)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: hasNoTitle && sheetViewModel.sheetModel.content.count == 0 ? 15 : 0, leading: 0, bottom: 15, trailing: 0))
                } else {
                    Spacer()
                }
            }
            .setBackgroundImage(isForExternalDisplay: isForExternalDisplay, sheetViewModel: sheetViewModel)
            .modifier(SheetBackgroundColorAndOpacityEditModifier(sheetViewModel: sheetViewModel))
            .cornerRadius(isForExternalDisplay ? 0 : 10)
            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
            .ignoresSafeArea()
            .onReceive(timer) { _ in
                if sheetViewModel.themeModel.theme.displayTime {
                    time = Date().time
                    if Date().minute == 0 {
                        timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
                    }
                } else {
                    self.timer.upstream.connect().cancel()
                }
            }
        }
    }
    
    private func getTitleAttributedString(_ text: String, viewSize: CGSize) -> AttributedString {
        AttributedString(NSAttributedString(
            string: text,
            attributes: sheetViewModel.themeModel.theme.getTitleAttributes(getScaleFactor(width: viewSize.width))
        ))
    }
    
    private func getContentAttributedString(viewSize: CGSize) -> AttributedString {
        AttributedString(NSAttributedString(
            string: sheetViewModel.sheetModel.content,
            attributes: sheetViewModel.themeModel.theme.getLyricsAttributes(getScaleFactor(width: viewSize.width))
        ))
    }
    
    private var hasNoTitle: Bool {
        sheetViewModel.title.count == 0 && !sheetViewModel.themeModel.theme.displayTime
    }
    
}
