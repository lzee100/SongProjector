//
//  SongServiceUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI
import UIKit

struct SongServiceViewUI: View {
    
    @State var songService: WrappedStruct<SongServiceUI>
    let dismiss: (() -> Void)
    private let alignment: Sticky.Alignment
    @SwiftUI.Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State var selectedSheet: String?
    
    init(songService: WrappedStruct<SongServiceUI>, dismiss: @escaping (() -> Void), alignment: Sticky.Alignment = .horizontal) {
        self._songService = State(wrappedValue: songService)
        self.dismiss = dismiss
        self.alignment = alignment
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { ruler in
                VStack(alignment: .center, spacing: 0) {
                    
                    BeamerPreviewUI(songService: songService)
                        .padding(EdgeInsets(top: 10, leading: 50, bottom: 50, trailing: 50))
                        .aspectRatio(externalDisplayWindowRatioHeightWidth, contentMode: .fit)
                    
                    SheetScrollViewUI(songServiceModel: songService, isSelectable: true)
                        .frame(maxWidth: isCompactOrVertical(ruler: ruler) ? (ruler.size.width * 0.7) : .infinity, maxHeight: isCompactOrVertical(ruler: ruler) ? .infinity : 200)
                    
                }
                .background(.black)
                .edgesIgnoringSafeArea(.all)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(AppText.SongService.title)
            .toolbar(content: {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(AppText.Actions.close) {
                        dismiss()
                    }
                }
            })
        }
        .onChange(of: selectedSheet) { newValue in
            songService.item.selectedSheetId = newValue
        }
    }
    
    func isCompactOrVertical(ruler: GeometryProxy) -> Bool {
        ruler.size.width < ruler.size.height || horizontalSizeClass == .compact
    }
}

struct SongServiceUI_Previews: PreviewProvider {
    @State static var songService = WrappedStruct(withItem: SongServiceUI(songs: []))
    static var previews: some View {
        SongServiceViewUI(songService: songService, dismiss: {})
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (4th generation)"))
            .previewInterfaceOrientation(.portrait)
    }
}
