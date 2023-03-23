//
//  TitleContentViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct TitleContentViewUI: View {
    
    let position: Int
    let scaleFactor: CGFloat
    let sheet: VSheetTitleContent
    let sheetTheme: VTheme
    
    var body: some View {
        VStack(spacing: 10) {
            Text(getTitleAttributedString())
                .padding(EdgeInsets(
                    top: getScaledValue(10),
                    leading: getScaledValue(10),
                    bottom: getScaledValue(10),
                    trailing: getScaledValue(10))
                )
                .frame(maxWidth: .infinity, minHeight: getScaledValue(70), alignment: .leading)
                .setTitleBackgroundColor(sheetTheme: sheetTheme, position: position)
           
            Text(getContentAttributedString())
                .padding(EdgeInsets(
                    top: getScaledValue(10),
                    leading: getScaledValue(10),
                    bottom: getScaledValue(10),
                    trailing: getScaledValue(10)
                ))
                .frame(maxWidth: .infinity, alignment: .topLeading)
            Spacer()
        }
        .setBackgroundImage(sheetTheme: sheetTheme, scaleFactor: scaleFactor) { view, image in
            view.background(
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(sheetTheme.backgroundTransparancy)
                    .clipped()
            )
        }
        .setBackgroundColor(sheetTheme: sheetTheme)
        .setBackgroundTransparancy(sheetTheme: sheetTheme)
        .ignoresSafeArea()
        .aspectRatio(16 / 9, contentMode: .fill)
        .border(.pink)
        .cornerRadius(10)
    }
    
    private func getTitleAttributedString() -> AttributedString {
        let nsAttrString = NSAttributedString(string: sheet.title ?? "", attributes: sheetTheme.getTitleAttributes(scaleFactor))
        return AttributedString(nsAttrString)
    }
    
    private func getContentAttributedString() -> AttributedString {
        let nsAttrString = NSAttributedString(string: sheet.content ?? "", attributes: sheetTheme.getLyricsAttributes(scaleFactor))
        return AttributedString(nsAttrString)
    }
    
    private func getScaledValue(_ factor: CGFloat) -> CGFloat {
        factor * scaleFactor
    }
    
}

struct TitleContentViewUI_Previews: PreviewProvider {
    static var previews: some View {
        TitleContentViewUI(position: 0, scaleFactor: 1, sheet: makeCluster().hasSheets.first as! VSheetTitleContent, sheetTheme: VTheme()).previewInterfaceOrientation(.landscapeLeft).previewLayout(.sizeThatFits)
    }
}

fileprivate extension View {
    
    func setTitleBackgroundColor(sheetTheme: VTheme, position: Int) -> some View {
        if let titleBackgroundColor = sheetTheme.backgroundColorTitleAsColor, let title = sheetTheme.title, title != "" {
            if !sheetTheme.allHaveTitle && position < 1 {
                return self.background(titleBackgroundColor)
            } else if sheetTheme.allHaveTitle {
                return self.background(titleBackgroundColor)
            } else {
                return self.background(.clear)
            }
        } else {
            return self.background(.clear)
        }
    }
    
    func setBackgroundColor(sheetTheme: VTheme) -> some View {
        if let backgroundColor = sheetTheme.backgroundColorAsColor {
            return self.background(backgroundColor)
        } else {
            return self.background(.white)
        }
    }
    
    func setBackgroundTransparancy(sheetTheme: VTheme) -> some View {
        if sheetTheme.backgroundColorAsColor != nil {
            let opacity = sheetTheme.backgroundTransparancy > 0.0 ? sheetTheme.backgroundTransparancy : 1.0
            return self.opacity(opacity)
        } else {
            return self.opacity(1.0)
        }
    }
}

fileprivate extension View {
    @ViewBuilder func setBackgroundImage<Content: View>(sheetTheme: VTheme, scaleFactor: CGFloat, transform: (Self, Image) -> Content) -> some View {
        if let image = scaleFactor > 1.0 ? sheetTheme.backgroundImageAsImage : sheetTheme.thumbnailAsImage {
            transform(self, image)
        } else {
            self
        }
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(condition: (() -> Bool), transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}
