//
//  ToggleViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct ToggleViewUI: View {
    
    let label: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack() {
            Toggle(isOn: $isOn) {
                
                Text(label)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                    .styleAs(font: .xNormal)
            }
        }
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 3))
    }
}

struct ToggleViewUI_Previews: PreviewProvider {
    @State static var isOn = false
    static let label = "Label"
    static var previews: some View {
        ToggleViewUI(label: label, isOn: $isOn)
    }
}
