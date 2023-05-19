//
//  NumberScrollViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct NumberScrollViewUI: View {
    
    private struct IdentifiableNumber: Identifiable {
        public let id = UUID()
        let value: Int
    }
    
    @Binding var selectedNumber: Int
    
    private let numbers: [IdentifiableNumber]
    
    init(min: Int, max: Int, selectedNumber: Binding<Int>) {
        numbers = Array(min..<max).map { IdentifiableNumber(value: $0) }
        self._selectedNumber = selectedNumber
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            ScrollViewReader { proxy in
                HStack {
                    ForEach(numbers) { number in
                        Button {
                            selectedNumber = selectedNumber == number.value ? 0 : number.value
                        } label: {
                            Text("\(number.value)")
                        }
                        .styleAsSelectionCapsuleButton(isSelected: number.value == selectedNumber)
                        .id(number.value)
                    }
                }.onAppear {
                    if selectedNumber != 0 {
                        proxy.scrollTo(selectedNumber)
                    }
                }
            }
        }
    }
}

struct NumberScrollViewUI_Previews: PreviewProvider {
    @State static var n = 1
    static var previews: some View {
        NumberScrollViewUI(min: 1, max: 10, selectedNumber: $n)
    }
}
