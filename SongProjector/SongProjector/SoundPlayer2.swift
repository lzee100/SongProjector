//
//  SoundPlayer2.swift
//  SongProjector
//
//  Created by Leo van der Zee on 03/05/2023.
//  Copyright © 2023 iozee. All rights reserved.
//

import Foundation
import SwiftUI
import AVFoundation
import MediaPlayer

class SoundPlayer2 {
    
    @Binding private var selectedSheet: String?
    
    private var selectedSong: SongObjectUI? = nil
    private var isPianoSolo = false
    private var isPlaying = false
    private var isLooping = false
    private var timers: [Timer] = []
    private var loopTime: TimeInterval = 0
    private var queuePlayer = AVQueuePlayer()
    private var playerLooper: AVPlayerLooper? = nil
    private var players: [InstrumentPlayer] = []
    
    init(selectedSheet: Binding<String?>) {
        do {
            UIApplication.shared.beginReceivingRemoteControlEvents()
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .moviePlayback, policy: .longFormAudio, options: [.mixWithOthers, .allowAirPlay, .allowBluetooth])
        } catch {
            print(error)
        }
        self._selectedSheet = selectedSheet
    }
    
    func play(song: SongObjectUI, pianoSolo: Bool = false) {
        self.selectedSong = song
        try? AVAudioSession.sharedInstance().setActive(true)
        stop()
        isPianoSolo = pianoSolo
        players = []
        
        guard !isPlaying else {
            isPlaying = true
            NotificationCenter.default.post(name: .soundPlayerPlayedOrStopped, object: nil)
            return
        }
        
        self.loadAudio(pianoSolo: pianoSolo)
    }
    
    func stop() {
        try? AVAudioSession.sharedInstance().setActive(false)
        timers.forEach { $0.invalidate() }
        timers = []
        for player in players {
            player.setVolume(0, fadeDuration: 2)
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval.seconds(2)) {
                player.stop()
            }
        }
        isPlaying = false
        isPianoSolo = false
        isLooping = false
        selectedSong = nil
        NotificationCenter.default.post(name: .soundPlayerPlayedOrStopped, object: nil)
    }
    
    private func playInstruments() {
        
        DispatchQueue.global().async {
            let commandCenter = MPRemoteCommandCenter.shared()
            commandCenter.playCommand.isEnabled = true
            
            for player in self.players {
//                commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
//                    if player.rate == 0.0 {
//                        player.play()
//                        return .success
//                    }
//                    return .commandFailed
//                }
                player.volume = 0
                player.play()
                self.setVolumeFor(player: player)
            }
        }
    }
    
    private func setVolumeFor(player: InstrumentPlayer) {
        let systemVolume = AVAudioSession.sharedInstance().outputVolume
        var instrumentVolume: Float = 0.5
        if let instrumentType = player.instrumentType, let volumeInstrument = VolumeManager.getVolumeFor(instrumentType: instrumentType) {
            instrumentVolume = volumeInstrument
        }
        var isMuted = false
        if let instrument = self.selectedSong?.cluster.hasInstruments.first(where: { $0.type == player.instrumentType }) {
            isMuted = VolumeManager.isMutedFor(instrument: instrument)
        }
        if isMuted {
            player.setVolume(0, fadeDuration: 2)
        } else {
            player.setVolume(systemVolume * instrumentVolume, fadeDuration: 2)
        }
    }
    
    private func playerFor(instrumentType: InstrumentType) -> InstrumentPlayer? {
        return players.first(where: { $0.instrumentType == instrumentType })
    }
    
    func setVolumeFor(_ type: InstrumentType, volume: Float, saveValue: Bool = true) {
        playerFor(instrumentType: type)?.setVolume(volume, fadeDuration: 0)
        if saveValue {
            VolumeManager.set(volume: volume, instrumentType: type)
        }
    }
    
    func getVolumeFor(_ type: InstrumentType) -> Float? {
        playerFor(instrumentType: type)?.volume
    }
    
    func containsInstrument(_ instrument: VInstrument) -> Bool {
        return selectedSong?.cluster.hasInstruments.contains(entity: instrument) ?? false
    }
    
    func updateVolumeBasedOnGlobalVolume(systemVolume: Float = AVAudioSession.sharedInstance().outputVolume) {
        for player in self.players {
            var instrumentVolume: Float = 1
            if let instrumentType = player.instrumentType, let volumeInstrument = VolumeManager.getVolumeFor(instrumentType: instrumentType) {
                instrumentVolume = volumeInstrument
            }
            guard systemVolume > 0 else {
                player.setVolume(0, fadeDuration: 2)
                return
            }
            player.setVolume(systemVolume * instrumentVolume, fadeDuration: 2)
        }
    }
    
    private func setIsLooping() {
        guard let selectedSong else { return }
        isLooping = selectedSong.cluster.hasInstruments.filter({ $0.isLoop == true }).count > 0 || selectedSong.cluster.hasInstruments.contains(where: { $0.type == .pianoSolo })
    }
    
    private func loadAudio(pianoSolo: Bool) {
        
        if let song = selectedSong {
                        
            if pianoSolo, let instrument = song.cluster.hasInstruments.first(where: { $0.type == .pianoSolo }) {
                loadSongAudioFor(instrument: instrument)
                return
            }
            
            for instrument in song.cluster.hasInstruments.filter({ $0.type != .pianoSolo }) {
                loadSongAudioFor(instrument: instrument)
            }
            
        }
        
    }
    
    private func loadSongAudioFor(instrument: InstrumentCodable) {
        
        var player = InstrumentPlayer()
        if let urlString = instrument.resourcePath {
            let url = FileManager.getURLfor(name: urlString)
            do {
                player = try InstrumentPlayer(contentsOf: url)
                player.instrumentType = instrument.type
                player.prepareToPlay()
                player.isLoop = instrument.isLoop
                player.numberOfLoops = instrument.isLoop ? -1 : 0
                players.append(player)
            }
            
            catch {
                print(error)
            }
            
        }
    }
    
    private func setSheetTimers() {
        guard let selectedSong else { return }
        for index in 0..<selectedSong.cluster.hasSheets.count {
            let totalTime = Array(0...index).compactMap{ selectedSong.sheets[safe: $0]?.time }.reduce(0, +)
            let timer = Timer.scheduledTimer(withTimeInterval: totalTime, repeats: false) { [weak self] _ in
                self?.selectedSheet = selectedSong.sheets[safe: index + 1]?.id
            }
            timers.append(timer)
        }
    }
    
}
