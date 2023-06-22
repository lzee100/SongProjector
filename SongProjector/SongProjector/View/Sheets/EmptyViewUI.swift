//
//  EmptyViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct EmptyViewEditUI: View {
    private let isForExternalDisplay: Bool
    
    @ObservedObject private var sheetViewModel: SheetViewModel
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
                    if sheetViewModel.displayTime {
                        Spacer()
                        Text(getTitleAttributedString(text: time, viewSize: proxy.size))
                            .padding(EdgeInsets(
                                top: getScaledValue(10, width: proxy.size.width),
                                leading: getScaledValue(10, width: proxy.size.width),
                                bottom: getScaledValue(5, width: proxy.size.width),
                                trailing: getScaledValue(10, width: proxy.size.width))
                            )
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
                Spacer()
            }
            .setBackgroundImage(isForExternalDisplay: isForExternalDisplay, theme: sheetViewModel.themeModel.theme)
            .modifier(SheetBackgroundColorAndOpacityModifier(sheetTheme: sheetViewModel.themeModel.theme))
            .cornerRadius(10)
            .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
            .ignoresSafeArea()
            .onReceive(timer) { _ in
                if sheetViewModel.displayTime {
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
    
    private func getScaledValue(_ factor: CGFloat, width: CGFloat) -> CGFloat {
        factor * getScaleFactor(width: width)
    }
    
    private func getTitleAttributedString(text: String, viewSize: CGSize) -> AttributedString {
        return AttributedString(NSAttributedString(
            string: text,
            attributes: sheetViewModel.themeModel.theme.getTitleAttributes(getScaleFactor(width: viewSize.width))
        ))
    }

}


struct EmptyViewDisplayUI: View {
    
    @ObservedObject private var songServiceModel: WrappedStruct<SongServiceUI>
    private let isForExternalDisplay: Bool
    private let sheet: SheetMetaType
    private let showSelectionCover: Bool
    private var theme: ThemeCodable?
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var time = Date().time

    init(serviceModel: WrappedStruct<SongServiceUI>, sheet: SheetMetaType, isForExternalDisplay: Bool, showSelectionCover: Bool) {
        _songServiceModel = ObservedObject(initialValue: serviceModel)
        self.isForExternalDisplay = isForExternalDisplay
        self.sheet = sheet
        self.showSelectionCover = showSelectionCover
        self.theme = serviceModel.item.themeFor(sheet: sheet)
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                HStack {
                    if theme?.displayTime ?? false {
                        Spacer()
                        Text(getTitleAttributedString(text: time, viewSize: proxy.size))
                            .padding(EdgeInsets(
                                top: getScaledValue(10, width: proxy.size.width),
                                leading: getScaledValue(10, width: proxy.size.width),
                                bottom: getScaledValue(5, width: proxy.size.width),
                                trailing: getScaledValue(10, width: proxy.size.width))
                            )
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
                
            }
            .setBackgroundImage(isForExternalDisplay: isForExternalDisplay, theme: theme)
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
            .onReceive(timer) { _ in
                if theme?.displayTime ?? false {
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
    
    private func getScaledValue(_ factor: CGFloat, width: CGFloat) -> CGFloat {
        factor * getScaleFactor(width: width)
    }
    
    private func getTitleAttributedString(text: String, viewSize: CGSize) -> AttributedString {
        return AttributedString(NSAttributedString(
            string: text,
            attributes: theme?.getTitleAttributes(getScaleFactor(width: viewSize.width))
        ))
    }
    
}
