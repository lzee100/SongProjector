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
    var instrument: InstrumentCodable
    
    var body: some View {
        VStack(spacing: 2) {
            (instrument.image ?? Image(systemName: "minus"))
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color(uiColor: .whiteColor))
                .aspectRatio(contentMode: .fit)
                .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
            Rectangle()
                .fill(isSelected ? Color(uiColor: themeHighlighted) : .black)
                .frame(height: 5)
        }
        .onTapGesture {
            isSelected.toggle()
            MuteInstrumentsUseCase().setMuteFor(instrument: instrument, isMuted: !isSelected)
        }
        .background(.black)
        .cornerRadius(orientation.isVertical ? 10 : 0)
        .onAppear {
            if [.landscapeLeft, .landscapeRight].contains(UIDevice.current.orientation) {
                self.orientation = .horizontal
            } else {
                self.orientation = .vertical
            }
            isSelected = !MuteInstrumentsUseCase().isMutedFor(instrument: instrument)
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
        InstrumentViewUI(instrument: InstrumentCodable.makeDefault()!)
            .previewLayout(.sizeThatFits)
            .previewDevice("iPhone 14")
    }
}

private extension InstrumentCodable {
    var image: Image? {
        guard let type = type else {
            return nil
        }
        switch type {
        case .guitar, .piano, .drums: return Image(type.rawValue.capitalized)
        case .bassGuitar: return Image("BassGuitar")
        case .pianoSolo: return Image("Piano")
        case .unKnown: return nil
        }
    }
}
