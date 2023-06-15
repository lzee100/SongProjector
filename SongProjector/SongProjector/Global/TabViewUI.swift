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
    @State private var showingSongServiceView = true
    @EnvironmentObject var externalDisplayConnector: ExternalDisplayConnector

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(model.tabFeatures) { feature in
                switch feature {
                case .songService:
                    tabView(SongServiceViewUI(showingSongServiceView: $showingSongServiceView), feature: feature)
                case .songs:
                    tabView(CollectionsViewUI(
                        editingSection: Binding.constant(nil),
                        songServiceEditorModel: SongServiceEditorModel(),
                        mandatoryTags: []), feature: feature)
                case .themes:
                    tabView(ThemesViewUI(), feature: feature)
                case .tags:
                    tabView(TagsViewUI(), feature: feature)
                case .songServiceManagement:
                    tabView(SongServiceSettingsViewUI(), feature: feature)
                case .settings:
                    tabView(SettingsViewUI(), feature: feature)
                default:
                    tabView(SettingsViewUI(), feature: feature)
                }
            }
        }
        .accentColor(Color(uiColor: themeHighlighted))
    }
    
    @ViewBuilder private func tabView(_ view: some View, feature: Feature) -> some View {
        view
            .tabItem {
                Label {
                    Text(feature.titleForDisplay)
                } icon: {
                    Image(uiImage: feature.image.normal).font(.system(size: 26))
                }
            }
            .tag(feature)
    }
}

struct TabViewUI_Previews: PreviewProvider {
    static var previews: some View {
        TabViewUI()
    }
}

class TabViewViewModel: ObservableObject {
    
    @Published private(set) var tabFeatures: [Feature]
//    @Published private(set) var moreTabFeatures: [Feature]
    
    init() {
        tabFeatures = Feature.all.filter{ $0.isActief }
//        let standardFeatures = Array(activeFeatures.prefix(4))
//        self.tabFeatures = standardFeatures
//        self.moreTabFeatures = Array(activeFeatures.suffix(activeFeatures.count - standardFeatures.count))
    }
    
}
