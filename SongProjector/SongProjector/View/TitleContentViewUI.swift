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
    var isForExternalDisplay = false
    let scaleFactor: CGFloat
    @Binding var selectedSheet: VSheet?
    let sheet: VSheet
    let sheetTheme: VTheme
    let showSelectionCover: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Text(getTitleAttributedString())
                .padding(EdgeInsets(
                    top: getScaledValue(10),
                    leading: getScaledValue(10),
                    bottom: getScaledValue(5),
                    trailing: getScaledValue(10))
                )
                .frame(maxWidth: .infinity, alignment: .leading)
//                .setTitleBackgroundColor(sheetTheme: sheetTheme, position: position)
                .background(.pink.opacity(0.1))
           
            Text(getContentAttributedString())
                .padding(EdgeInsets(
                    top: getScaledValue(5),
                    leading: getScaledValue(10),
                    bottom: getScaledValue(10),
                    trailing: getScaledValue(10)
                ))
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .background(.green.opacity(0.1))
            Spacer()
        }
        .setBackgroundImage(sheetTheme: sheetTheme, isForExternalDisplay: isForExternalDisplay) { view, image in
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
        .overlay {
            if selectedSheet?.id != sheet.id, showSelectionCover {
                Rectangle()
                    .fill(.black.opacity(0.2))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private func getTitleAttributedString() -> AttributedString {
        let nsAttrString = NSAttributedString(string: sheet.title ?? "", attributes: sheetTheme.getTitleAttributes(scaleFactor))
        return AttributedString(nsAttrString)
    }
    
    private func getContentAttributedString() -> AttributedString {
        let nsAttrString = NSAttributedString(string: (sheet as? VSheetTitleContent)?.content ?? "", attributes: sheetTheme.getLyricsAttributes(scaleFactor))
        return AttributedString(nsAttrString)
    }
    
    private func getScaledValue(_ factor: CGFloat) -> CGFloat {
        factor * scaleFactor
    }
    
}

struct TitleContentViewUI_Previews: PreviewProvider {
    
    @State static var songService = makeSongService(true)

    static var previews: some View {
        TitleContentViewUI(
            position: 0,
            scaleFactor: 1,
            selectedSheet: $songService.selectedSheet,
            sheet: songService.selectedSheet!,
            sheetTheme: VTheme(),
            showSelectionCover: true
        )
        .previewInterfaceOrientation(.landscapeLeft)
        .previewLayout(.sizeThatFits)
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
    @ViewBuilder func setBackgroundImage<Content: View>(sheetTheme: VTheme, isForExternalDisplay: Bool, transform: (Self, Image) -> Content) -> some View {
        if let image = isForExternalDisplay ? sheetTheme.backgroundImageAsImage : sheetTheme.thumbnailAsImage {
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
