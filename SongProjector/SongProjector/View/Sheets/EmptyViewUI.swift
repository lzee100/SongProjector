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
            .setBackgroundImage(image: sheetViewModel.themeModel.getImage(thumb: !isForExternalDisplay), backgroundTransparancy: sheetViewModel.themeModel.theme.backgroundTransparancy)
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
