//
//  TabViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 11/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct TabViewUI: View {

    @Binding var selectedTab: Feature

    @StateObject private var model = TabViewViewModel()
    @State private var showingSongServiceView = true
    @EnvironmentObject var externalDisplayConnector: ExternalDisplayConnector
    @EnvironmentObject var musicDownloadManager: MusicDownloadManager

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(model.tabFeatures) { feature in
                switch feature {
                case .songService:
                    tabView(SongServiceViewUI(showingSongServiceView: $showingSongServiceView).environmentObject(musicDownloadManager), feature: feature)
                case .songs:
                    tabView(CollectionsViewUI(
                        editingSection: Binding.constant(nil),
                        songServiceEditorModel: SongServiceEditorModel(),
                        mandatoryTagIds: []).environmentObject(musicDownloadManager), feature: feature)
                case .themes:
                    tabView(ThemesViewUI(), feature: feature)
                case .tags:
                    tabView(TagsViewUI(), feature: feature)
                case .songServiceManagement:
                    tabView(SongServiceSettingsViewUI(selectedTab: $selectedTab), feature: feature)
                case .settings:
                    tabView(SettingsViewUI(selectedTab: $selectedTab), feature: feature)
                default:
                    tabView(AboutViewUI(), feature: feature)
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
        TabViewUI(selectedTab: .constant(.songService))
    }
}

class TabViewViewModel: ObservableObject {
    
    @Published private(set) var tabFeatures: [Feature]
    
    init() {
        tabFeatures = Feature.all.filter{ $0.isActief }
    }
    
}
