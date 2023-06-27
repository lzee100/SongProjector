//
//  ThemesScrollViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 24/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

@MainActor class ThemesSelectionModel: ObservableObject {
    
    @Published private(set) var selectedTheme: ThemeCodable?
    @Published private(set) var themes: [ThemeCodable] = []
    
    init(selectedTheme: ThemeCodable?) {
        self.selectedTheme = selectedTheme
        
        defer {
            Task {
                let themes = await GetThemesUseCase().fetch()
                await MainActor.run {
                    self.themes = themes
                }
            }
        }
    }
    
    func didSelect(theme: ThemeCodable?) {
        selectedTheme = selectedTheme?.id == theme?.id ? nil : theme
    }
    
    func selectFirstthemeIfNeeded() {
        if selectedTheme == nil {
            selectedTheme = themes.first
        }
    }
}

struct ThemesScrollViewUI: View {
    
    @StateObject var model: ThemesSelectionModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack() {
                    ForEach(model.themes) { theme in
                        Button {
                            model.didSelect(theme: theme)
                        } label: {
                            Text(theme.title ?? "-")
                        }
                        .styleAsSelectionCapsuleButton(isSelected: model.selectedTheme?.id == theme.id)
                        .id(theme.id)
                    }
                }
            }
            .onAppear {
                if let theme = model.selectedTheme {
                    proxy.scrollTo(theme.id)
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
