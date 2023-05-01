//
//  ThemesScrollViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 24/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct ThemesScrollViewUI: View {
    
    @ObservedObject private var model: WrappedStruct<ThemesSelectionModel>
    
    init(model: WrappedStruct<ThemesSelectionModel>) {
        self.model = model
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack() {
                ForEach(model.item.themes) { theme in
                    Button {
                        model.item.didSelect(theme: theme)
                    } label: {
                        Text(theme.title ?? "-")
                    }
                    .styleAsSelectionCapsuleButton(isSelected: model.item.selectedTheme?.id == theme.id)
                }
            }
        }
    }
}

struct ThemesScrollViewUI_Previews: PreviewProvider {
    @State static var model = WrappedStruct(withItem: ThemesSelectionModel(selectedTheme: nil, didSelectTheme: {_ in }))
    static var previews: some View {
        ThemesScrollViewUI(model: model)
    }
}
