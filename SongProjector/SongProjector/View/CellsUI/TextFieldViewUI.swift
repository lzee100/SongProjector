//
//  TextFieldViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 13/04/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct TextFieldViewModel {
    enum CharacterLimit: Int {
        case standaard = 100
    }
    
    let label: String?
    let placeholder: String
    let characterLimit: Int
    @Binding var text: String
}

struct TextFieldViewUI: View {
    
    private var viewModel: TextFieldViewModel
    
    init(textFieldViewModel: TextFieldViewModel) {
        viewModel = textFieldViewModel
    }
    
    var body: some View {
        HStack() {
            if let label = viewModel.label {
                Text(label)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                    .styleAs(font: .xNormal)
            }
            TextField(viewModel.placeholder, text: viewModel.$text)
                .styleAs(font: .xNormal)
                .lineLimit(1)
                .padding(EdgeInsets(10))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.black.opacity(0.5), lineWidth: 0.3)
                        .padding(EdgeInsets(1))
                }
                .onChange(of: viewModel.text) { newValue in
                    if viewModel.text != newValue.prefix(viewModel.characterLimit) {
                        viewModel.text = String(newValue.prefix(viewModel.characterLimit))
                    }
                }
        }
    }
}

struct TextFieldViewUI_Previews: PreviewProvider {
    @State static var inputText = ""
    static let label = "Label"
    static var previews: some View {
        TextFieldViewUI(textFieldViewModel: TextFieldViewModel(label: label, placeholder: "Placeholder", characterLimit: 100, text: $inputText))
    }
}
