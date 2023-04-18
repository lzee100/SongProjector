//
//  LabelColorPickerViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct LabelColorPickerViewUI: View {
    
    let label: String
    var defaultColor: Color? = nil
    var colorDidChange: ((String) -> Void) = { _ in }
    @Binding var selectedColor: Color
    
    var body: some View {
        HStack() {
            
            ColorPicker(selection: $selectedColor) {
                Text(label)
                    .styleAs(font: .xNormal)
            }
            
            Image(systemName: "trash")
                .foregroundColor(Color(uiColor: themeHighlighted))
                .onTapGesture {
                    selectedColor = defaultColor ?? .clear
                }
                .padding()
        }
        .onChange(of: selectedColor) { newValue in
            if let colorHex = newValue.toHex() {
                colorDidChange(colorHex)
            }
        }
    }
}

struct LabelColorPickerViewUI_Previews: PreviewProvider {
    @State static var selectedColor: Color = .blue
    static var previews: some View {
        LabelColorPickerViewUI(label: "Label", selectedColor: $selectedColor)
    }
}
