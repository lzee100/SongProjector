//
//  TabViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct TabViewUI: View {
    @ObservedObject private var model = TabViewViewModel()
    @State private var selectedTab: Feature = .songService
    private var songService = WrappedStruct(withItem: SongServiceUI(songs: []))
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(model.tabFeatures) { feature in
                switch feature {
                case .songService:
                    SongServiceViewUI(songService: songService) {
                        
                    }
                    .tabItem {
                        Label {
                            Text(feature.titel)
                        } icon: {
                            Image(uiImage: feature.image.normal)
                        }
                    }
                    .tag(feature)
                case .songs:
                    CollectionsViewUI(editingSection: nil, songServiceEditorModel: nil)
                        .tabItem {
                            Label {
                                Text(feature.titel)
                            } icon: {
                                Image(uiImage: feature.image.normal)
                            }
                        }
                        .tag(feature)
                case .themes:
                    ThemesViewUI()
                        .tabItem {
                            Label {
                                Text(feature.titel)
                            } icon: {
                                Image(uiImage: feature.image.normal)
                            }
                        }
                    .tag(feature)
                case .more:
                    SongServiceViewUI(songService: songService) {
                        
                    }
                    .tabItem {
                        Label {
                            Text(feature.titel)
                        } icon: {
                            Image(uiImage: feature.image.normal)
                        }
                    }
                    .tag(feature)
                default:
                    SongServiceViewUI(songService: songService) {
                        
                    }
                    .tabItem {
                        Label {
                            Text(feature.titel)
                        } icon: {
                            Image(uiImage: feature.image.normal)
                        }
                    }
                    .tag(feature)
                }
            }
        }
        .accentColor(Color(uiColor: themeHighlighted))
    }
}

struct TabViewUI_Previews: PreviewProvider {
    static var previews: some View {
        TabViewUI()
    }
}

class TabViewViewModel: ObservableObject {
    
    @Published private(set) var tabFeatures: [Feature]
    @Published private(set) var moreTabFeatures: [Feature]
    
    init() {
        let activeFeatures = Feature.all.filter{ $0.isActief }
        let standardFeatures = Array(activeFeatures.prefix(4))
        self.tabFeatures = standardFeatures
        self.moreTabFeatures = Array(activeFeatures.suffix(activeFeatures.count - standardFeatures.count))
    }
    
}
