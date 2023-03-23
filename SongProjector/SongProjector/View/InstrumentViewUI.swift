//
//  InstrumentViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 20/03/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct InstrumentViewUI: View {
    
    @State var isSelected: Bool = true
    @State private var orientation: Sticky.Alignment = .vertical
    var instrument: VInstrument
    
    var body: some View {
        VStack(spacing: 2) {
            Image(uiImage: instrument.image ?? UIImage(systemName: "minus")!)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color(uiColor: .whiteColor))
                .aspectRatio(contentMode: .fit)
                .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
            Rectangle()
                .fill(isSelected ? Color(uiColor: themeHighlighted) : .black)
                .frame(height: 8)
        }
        .onTapGesture {
            isSelected = !isSelected
        }
        .background(.black)
        .cornerRadius(orientation.isVertical ? 10 : 0)
        .onAppear {
            if [.landscapeLeft, .landscapeRight].contains(UIDevice.current.orientation) {
                self.orientation = .horizontal
            } else {
                self.orientation = .vertical
            }
        }
        .onRotate { orientation in
            if [.landscapeLeft, .landscapeRight].contains(orientation) {
                self.orientation = .horizontal
            } else {
                self.orientation = .vertical
            }
        }
    }
}

struct InstrumentViewUI_Previews: PreviewProvider {
    static var previews: some View {
        InstrumentViewUI(instrument: makeDemoInstruments().first!)
            .previewLayout(.sizeThatFits)
            .previewDevice("iPhone 14")
    }
}
