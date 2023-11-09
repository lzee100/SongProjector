//
//  TitleContentViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct TitleContentViewEditUI: View {
    
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
                HStack {
                    Text(getTitleAttributedString(text: sheetViewModel.title, viewSize: proxy.size))
                        .modifier(SheetTitleEditUIModifier(scaleFactor: getScaleFactor(width: proxy.size.width), sheetViewModel: sheetViewModel, frameWidth: .infinity))
                        .lineLimit(1)
                    if sheetViewModel.displayTime {
                        Spacer()
                        Text(getTitleAttributedString(text: time, viewSize: proxy.size))
                            .modifier(SheetTitleEditUIModifier(scaleFactor: getScaleFactor(width: proxy.size.width), sheetViewModel: sheetViewModel))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
                
                HStack(spacing: 0) {
                    if [1, 2].contains(sheetViewModel.themeModel.theme.contentAlignmentNumber) {
                        Spacer()
                    }
                    Text(getContentAttributedString(viewSize: proxy.size))
                        .modifier(SheetContentDisplayModifier(
                            scaleFactor: getScaleFactor(width: proxy.size.width),
                            multiLine: true,
                            alignment: sheetViewModel.themeModel.theme.contentAlignmentNumber.intValue
                        ))
                    if [0, 1].contains(sheetViewModel.themeModel.theme.contentAlignmentNumber) {
                        Spacer()
                    }
                }
                Spacer()
            }
            .setBackgroundImage(isForExternalDisplay: false, sheetViewModel: sheetViewModel)
            .modifier(SheetBackgroundColorAndOpacityEditModifier2(sheetViewModel: sheetViewModel))
            .cornerRadius(isForExternalDisplay ? 0 : 10)
            .aspectRatio(16 / 9, contentMode: .fit)
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
    
    private func getTitleAttributedString(text: String, viewSize: CGSize) -> AttributedString {
        return AttributedString(NSAttributedString(
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
}

struct SheetBackgroundColorAndOpacityEditModifier: ViewModifier {
    
    @ObservedObject private var sheetViewModel: SheetViewModel
    
    init(sheetViewModel: SheetViewModel) {
        self.sheetViewModel = sheetViewModel
    }
    
    func body(content: Content) -> some View {
        content
            .background(getColor() ?? .white)
            .opacity(getOpacity())
    }
    
    func getOpacity() -> Double {
        let transparancy = sheetViewModel.themeModel.theme.backgroundTransparancyNumber
        if getColor() == nil || (sheetViewModel.themeModel.getImage(thumb: true) == nil) {
            return 1.0
        }
        return transparancy
    }
    
    func getColor() -> Color? {
        sheetViewModel.themeModel.theme.backgroundColor?.color
    }
    
}

struct SheetBackgroundColorAndOpacityEditModifier2: ViewModifier {
    
    @ObservedObject private var sheetViewModel: SheetViewModel
    
    init(sheetViewModel: SheetViewModel) {
        self.sheetViewModel = sheetViewModel
    }
    
    func body(content: Content) -> some View {
        content
            .background(getColor() ?? .white)
            .opacity(getOpacity())
    }
    
    func getOpacity() -> Double {
        let transparancy = sheetViewModel.themeModel.theme.backgroundTransparancyNumber
        if getColor() == nil || sheetViewModel.themeModel.getImage(thumb: false) == nil {
            return 1.0
        }
        return transparancy
    }
    
    func getColor() -> Color? {
        sheetViewModel.themeModel.theme.backgroundColor?.color
    }
    
}
