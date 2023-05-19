//
//  NumberModifierViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct NumberModifierViewModel<T> where T: Numeric, T: CustomStringConvertible {
    let label: String
    var allowSubstraction: ((T) -> Bool) = { _ in  true }
    var allowIncrement: ((T) -> Bool) = { _ in  true }
    @Binding var numberValue: T
}

struct NumberModifierViewUI<T>: View where T: Numeric, T: CustomStringConvertible {
    
    private var viewModel: NumberModifierViewModel<T>
    
    init(viewModel: NumberModifierViewModel<T>) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack() {
            Text(viewModel.label)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                .styleAs(font: .xNormal)
            Spacer()
            HStack(spacing: 0) {
                Button {
                    if viewModel.allowSubstraction(viewModel.numberValue) {
                        viewModel.numberValue -= 1
                    }
                } label: {
                    Image(systemName: "minus")
                        .foregroundColor(Color(uiColor: themeHighlighted))
                        .padding()
                }
                .buttonStyle(.borderless)

                Text("\(viewModel.numberValue.description)")
                    .styleAs(font: .xNormal)
                
                Button {
                    if viewModel.allowIncrement(viewModel.numberValue) {
                        viewModel.numberValue += 1
                    }
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color(uiColor: themeHighlighted))
                        .padding()
                }
                .buttonStyle(.borderless)
            }
        }
    }
}

struct NumberModifierViewUI_Previews: PreviewProvider {
    @State static var numberValue: Double = 10.0
    @State static var viewModel = NumberModifierViewModel(label: "Label", numberValue: $numberValue)
    static var previews: some View {
        NumberModifierViewUI(viewModel: viewModel)
    }
}
