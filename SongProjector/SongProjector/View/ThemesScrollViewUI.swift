//
//  ThemesScrollViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 24/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct ThemesScrollViewUI: View {
    
    @StateObject var model: ThemesSelectionModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack() {
                ForEach(model.themes) { theme in
                    Button {
                        model.didSelect(theme: theme)
                    } label: {
                        Text(theme.title ?? "-")
                    }
                    .styleAsSelectionCapsuleButton(isSelected: model.selectedTheme?.id == theme.id)
                }
            }
        }
    }
}

struct ThemesScrollViewUI_Previews: PreviewProvider {
    @State static var model = ThemesSelectionModel(selectedTheme: nil)
    static var previews: some View {
        ThemesScrollViewUI(model: model)
    }
}
