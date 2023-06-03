//
//  MixerViewUI.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import SwiftUI

struct MixerViewUI: View {
    
    private let volumeUseCase = VolumeUseCase()

    @EnvironmentObject private var soundPlayer: SoundPlayer2
    @State private var pianoVolume: Float = 0
    @State private var guitarVolume: Float = 0
    @State private var bassGuitarVolume: Float = 0
    @State private var drumsVolume: Float = 0
    
    var body: some View {
        HStack {
            VStack {
                style(Image("Piano"))
                style(Image("Guitar"))
                style(Image("BassGuitar"))
                style(Image("Drums"))
            }
            VStack {
                pianoSlider
                guitar
                bassGuitar
                drums
            }
        }
        .frame(width: 400, height: 400)
        .background(.clear)
        .rotationEffect(.degrees(-90))
        .padding([.top], 20)
        .onChange(of: pianoVolume) { newValue in
            volumeUseCase.set(volume: newValue, instrumentType: .piano)
            soundPlayer.setVolumeFor(.piano, volume: newValue)
        }
        .onChange(of: guitarVolume) { newValue in
            volumeUseCase.set(volume: newValue, instrumentType: .guitar)
            soundPlayer.setVolumeFor(.guitar, volume: newValue)
        }
        .onChange(of: bassGuitarVolume) { newValue in
            volumeUseCase.set(volume: newValue, instrumentType: .bassGuitar)
            soundPlayer.setVolumeFor(.bassGuitar, volume: newValue)
        }
        .onChange(of: drumsVolume) { newValue in
            volumeUseCase.set(volume: newValue, instrumentType: .drums)
            soundPlayer.setVolumeFor(.drums, volume: newValue)
        }
        .onAppear {
            if let pianoVolume = volumeUseCase.getVolumeFor(instrumentType: .piano) {
                self.pianoVolume = pianoVolume
            }
            if let guitarVolume = volumeUseCase.getVolumeFor(instrumentType: .guitar) {
                self.guitarVolume = guitarVolume
            }
            if let bassGuitarVolume = volumeUseCase.getVolumeFor(instrumentType: .bassGuitar) {
                self.bassGuitarVolume = bassGuitarVolume
            }
            if let drumsVolume = volumeUseCase.getVolumeFor(instrumentType: .drums) {
                self.drumsVolume = drumsVolume
            }
        }
    }
    
    private func style(_ view: Image) -> some View {
        view
            .resizable()
            .foregroundColor(.white)
            .aspectRatio(1, contentMode: .fit)
            .padding()
            .rotationEffect(.degrees(90))
    }
    
    @ViewBuilder var pianoSlider: some View {
        Slider(value: $pianoVolume, in: 0...1)
            .frame(minHeight: 0, maxHeight: .infinity)
            .accentColor(Color(uiColor: themeHighlighted))
    }
    
    @ViewBuilder var guitar: some View {
        Slider(value: $guitarVolume, in: 0...1)
            .frame(minHeight: 0, maxHeight: .infinity)
            .accentColor(Color(uiColor: themeHighlighted))
    }
    
    @ViewBuilder var bassGuitar: some View {
        Slider(value: $bassGuitarVolume, in: 0...1)
            .frame(minHeight: 0, maxHeight: .infinity)
            .accentColor(Color(uiColor: themeHighlighted))
    }
    
    @ViewBuilder var drums: some View {
        Slider(value: $drumsVolume, in: 0...1)
            .frame(minHeight: 0, maxHeight: .infinity)
            .accentColor(Color(uiColor: themeHighlighted))
    }
}

struct MixerViewUI_Previews: PreviewProvider {
    static var previews: some View {
        MixerViewUI()
    }
}
