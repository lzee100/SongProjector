//
//  SheetTimesEditViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/06/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import UIKit

protocol SheetTimesEditViewDelegate {
    func didUpdateSheetTimes(value: String)
}

struct SheetTimesEditViewUI: View {
    
    @State var sheetTimesEditorStringValue: String = ""
    @State private var textStyle: UIFont.TextStyle = .body
    @Binding var showingSheetTimesEditView: Bool
    let delegate: SheetTimesEditViewDelegate?
    
    var body: some View {
        NavigationStack {
            TextView(text: $sheetTimesEditorStringValue, textStyle: $textStyle, placeholder: "11.4\n4.5\n6.6")
                .padding()
                .navigationTitle(AppText.UploadUniversalSong.title)
                .navigationBarTitleDisplayMode(.large)
                .toolbar(content: {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button(AppText.Actions.close) {
                            showingSheetTimesEditView = false
                        }
                        .tint(Color(uiColor: themeHighlighted))
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            sheetTimesEditorStringValue = ""
                        } label: {
                            Image(systemName: "trash")
                                .tint(Color(uiColor: themeHighlighted))
                        }
                        Button(AppText.Actions.save) {
                            delegate?.didUpdateSheetTimes(value: sheetTimesEditorStringValue)
                        }
                        .tint(Color(uiColor: themeHighlighted))
                    }
                })
        }
    }
}

struct SheetTimesEditViewUI_Previews: PreviewProvider {
    @State static private var showing = false
    static var previews: some View {
        SheetTimesEditViewUI(showingSheetTimesEditView: $showing, delegate: nil)
    }
}
