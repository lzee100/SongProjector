//
//  BeamerViewUI2.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct BeamerViewUI2: View {
    let selectedCluster: VCluster
    
    var body: some View {
        TabView() {
            TitleContentViewUI(position: 0, scaleFactor: 1, sheet: selectedCluster.hasSheets.first as! VSheetTitleContent, sheetTheme: VTheme())
        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
}

struct BeamerViewUI2_Previews: PreviewProvider {
    static var previews: some View {
        let demoCluster = VCluster()
        let demoSheet = VSheetTitleContent()
        demoSheet.title = "Test title Leo"
        demoSheet.content = "Test content Leo"
        demoCluster.hasSheets = [demoSheet]
        return BeamerViewUI2(selectedCluster: demoCluster)
    }
}
