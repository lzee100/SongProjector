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
    @State private var orientation = UIDevice.current.orientation
    var instrument: InstrumentCodable
    var muteInstrumentUseCase: MuteInstrumentsUseCase
    @EnvironmentObject private var soundPlayer: SoundPlayer2

    init(isSelected: Bool = true, instrument: InstrumentCodable) {
        self._isSelected = State(initialValue: isSelected)
        self.instrument = instrument
        muteInstrumentUseCase = MuteInstrumentsUseCase(instrument: instrument)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            (instrument.image ?? Image(systemName: "minus"))
                .resizable()
                .renderingMode(.template)
                .foregroundColor(Color(uiColor: .white))
                .aspectRatio(contentMode: .fit)
                .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
            Rectangle()
                .fill(isSelected ? Color(uiColor: themeHighlighted) : .black)
                .frame(height: 5)
        }
        .onTapGesture {
            isSelected.toggle()
            muteInstrumentUseCase.update(isMuted: !isSelected)
            soundPlayer.updateVolumeForInstrumentForMuteChange(instrument: instrument)
        }
        .background(.black)
        .cornerRadius(8, corners: cornersForInstrument)
        .onAppear {
            isSelected = !muteInstrumentUseCase.isMuted
        }
        .onRotate { orientation in
            self.orientation = orientation
        }
    }
    
    private var cornersForInstrument: UIRectCorner {
        switch instrument.type {
        case .piano:
            if orientation.isPortrait {
                return [.topLeft, .bottomLeft]
            } else {
                return .bottomLeft
            }
        case .drums:
            if orientation.isPortrait {
                return [.topRight, .bottomRight]
            } else {
                return .bottomRight
            }
        default: return []
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
