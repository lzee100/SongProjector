//
//  PickerViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

class PickerRepresentable: Identifiable {
    var value: Any
    let labelValue: String
    var id: String {
        if let value = value as? EntityCodable {
            return value.id
        }
        if let value = value as? Entity {
            return value.id
        }
        return UUID().uuidString
    }
    
    init(value: Any, label: String) {
        self.value = value
        self.labelValue = label
    }
}

struct PickerViewUI<T: PickerRepresentable>: View {
    
    let label: String
    var pickerValues: [T] = []
    var selectedItem: Binding<T>?
    var didSelectItem: ((T) -> Void) = { _ in }
        
    var body: some View {
            DisclosureGroup() {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack() {
                        ForEach(pickerValues) { pickerValue in
                            Button {
                                didSelectItem(pickerValue)
                                selectedItem?.wrappedValue = pickerValue
                            } label: {
                                Text(pickerValue.labelValue)
                            }
                            .buttonStyle(GrayButtonConfigurationStyle())
                        }
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
            } label: {
                HStack() {
                    Text(label)
                        .styleAs(font: .xNormal)
                        Spacer()
                    Text((selectedItem?.wrappedValue.labelValue ?? "").prefix(20))
                        .styleAs(font: .xNormal)
                        .lineLimit(1)
                }
            }
    }
    
    func backgroundColorFor(_ pickerValue: T) -> Color {
        if let pickedValue = selectedItem?.wrappedValue, pickerValue.id == pickedValue.id {
            return Color(uiColor: themeHighlighted)
        }
        return .gray.opacity(0.2)
    }
    
    func textColorFor(_ pickerValue: T) -> Color {
        if let pickedValue = selectedItem?.wrappedValue, pickerValue.id == pickedValue.id {
            return .white
        }
        return .black.opacity(0.8)
    }

}

struct PickerViewUI_Previews: PreviewProvider {
    private static let theme = VTheme()
    @State static var pickedValue = PickerRepresentable(value: theme, label: "picked Value")
    private static let demoItems: [PickerRepresentable] = [
        pickedValue,
        PickerRepresentable(value: theme, label: "1"),
        PickerRepresentable(value: VTheme(), label: "2"),
        PickerRepresentable(value: VTheme(), label: "3"),
        PickerRepresentable(value: VTheme(), label: "4"),
        PickerRepresentable(value: VTheme(), label: "5")
    ]
    static var previews: some View {
        PickerViewUI<PickerRepresentable>(label: "Label", pickerValues: demoItems,  selectedItem: $pickedValue)
    }
}


