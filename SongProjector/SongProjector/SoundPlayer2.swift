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

class CollectionCountDown {
    
    private var timers: [Timer] = []
    private let countDownDidChange: ((Int?) -> Void)
    private var countDownNumber = 0
    
    init(countDownDidChange: @escaping ((Int?) -> Void)) {
        self.countDownDidChange = countDownDidChange
    }
    
    func start(song: SongObjectUI) {
        stop()
        setTimers(for: song)
    }
    
    func stop() {
        countDownDidChange(nil)
        timers.forEach { $0.invalidate() }
        timers = []
    }
    
    private func setTimers(for song: SongObjectUI) {
        let startTime = song.cluster.startTime
        if startTime > 0 {
            switch startTime {
            case 5...: countDownNumber = 3
            case 1 ..< 1.6: countDownNumber = 1
            default: countDownNumber = 1
            }
            
            for counter in (1...countDownNumber).reversed() {
                let timer = Timer.scheduledTimer(withTimeInterval: startTime - Double(counter), repeats: false) { [weak self] timer in
                    self?.countDownDidChange(counter)
                }
                timers.append(timer)
            }
            let finishCountDowntimer = Timer.scheduledTimer(withTimeInterval: startTime, repeats: false) { [weak self] _ in
                self?.countDownDidChange(nil)
                self?.stop()
            }
            timers.append(finishCountDowntimer)
        }
    }
    
}

class SheetPlayer {
    var didSelectSheet: ((String?) -> Void)?
    private var selectedSong: SongObjectUI?
    private var timers: [Timer] = []
    private var sheetIndex: Int?
    
    init(didSelectSheet: ((String?) -> Void)? = nil) {
        self.didSelectSheet = didSelectSheet
    }
    
    func play(song: SongObjectUI, pianoSolo: Bool = false) {
        selectedSong = song
        if song.cluster.time > 0 {
            setCollectionTimer()
        } else if let times = selectedSong?.sheets.compactMap({ $0.sheetTime }) {
                let sortedTimes = times.sorted(by: <)
            if times == sortedTimes {
                setSheetTimersV2()
            } else {
                setSheetTimers()
            }
        }
    }
    
    func stop() {
        selectedSong = nil
        sheetIndex = nil
        timers.forEach { $0.invalidate() }
        timers = []
    }
    
    private func setCollectionTimer() {
        guard let selectedSong else { return }
        let timer = Timer.scheduledTimer(withTimeInterval: selectedSong.cluster.time, repeats: true) { [weak self] _ in
            guard let self else { return }
            let sheetIndex = (self.sheetIndex ?? 0) + 1 > selectedSong.sheets.count - 1 ? 0 : (self.sheetIndex ?? 0) + 1
            self.sheetIndex = sheetIndex
            self.didSelectSheet?(selectedSong.sheets[sheetIndex].id)
        }
        timers.append(timer)
    }
    
    private func setSheetTimers() {
        guard let selectedSong else { return }
        for index in 0..<selectedSong.cluster.hasSheets.count {
            let totalTime = Array(0...index).compactMap{ selectedSong.sheets[safe: $0]?.sheetTime }.reduce(0, +)
            let timer = Timer.scheduledTimer(withTimeInterval: totalTime, repeats: false) { [weak self] _ in
                if let sheetId = selectedSong.sheets[safe: index + 1]?.id {
                    self?.didSelectSheet?(sheetId)
                }
            }
            timers.append(timer)
        }
    }
    
    private func setSheetTimersV2() {
        guard let selectedSong else { return }
        for (index, sheet) in selectedSong.cluster.hasSheets.enumerated() {
            if let time = sheet.sheetTime {
                let timer = Timer.scheduledTimer(withTimeInterval: time, repeats: false) { [weak self] _ in
                    if let sheetId = selectedSong.sheets[safe: index + 1]?.id {
                        self?.didSelectSheet?(sheetId)
                    }
                }
                timers.append(timer)
            }
        }
    }

}

class SoundWithSheetPlayer {
    private let soundPlayer2: SoundPlayer2
    private let sheetPlayer: SheetPlayer
    private let collectionCountDown: CollectionCountDown

    init(soundPlayer: SoundPlayer2, collectionCountDown: CollectionCountDown, didSelectSheet: ((String?) -> Void)? = nil) {
        sheetPlayer = SheetPlayer(didSelectSheet: didSelectSheet)
        self.soundPlayer2 = soundPlayer
        self.collectionCountDown = collectionCountDown
    }
    func play(song: SongObjectUI, pianoSolo: Bool = false) {
        if song.cluster.hasLocalMusic {
            soundPlayer2.play(song: song, pianoSolo: pianoSolo)
            collectionCountDown.start(song: song)
        }
        sheetPlayer.play(song: song)
    }
    
    func stop() {
        soundPlayer2.stop()
        sheetPlayer.stop()
        collectionCountDown.stop()
    }
}

class SoundPlayer2: ObservableObject {
    
    @Published private(set) var selectedSong: SongObjectUI? = nil
    private var isPianoSolo = false
    private var isPlaying = false
    private var isLooping = false
    private var loopTime: TimeInterval = 0
    private var queuePlayer = AVQueuePlayer()
    private var playerLooper: AVPlayerLooper? = nil
    private var players: [InstrumentPlayer] = []
    
    var isPlayingPianoSolo: Bool {
        return players.contains(where: { $0.instrumentType == .pianoSolo })
    }
    
    init() {
        do {
            UIApplication.shared.beginReceivingRemoteControlEvents()
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .moviePlayback, policy: .longFormAudio, options: [.mixWithOthers, .allowAirPlay, .allowBluetooth])
        } catch {
            print(error)
        }
    }
    
    func play(song: SongObjectUI, pianoSolo: Bool = false) {
        stop()
        self.selectedSong = song
        try? AVAudioSession.sharedInstance().setActive(true)
        isPianoSolo = pianoSolo
        players = []
        
        guard !isPlaying else {
            isPlaying = true
            NotificationCenter.default.post(name: .soundPlayerPlayedOrStopped, object: nil)
            return
        }
        
        loadAudio(pianoSolo: pianoSolo)
        playInstruments()
    }
    
    func stop() {
        try? AVAudioSession.sharedInstance().setActive(false)
        for player in players {
            player.setVolume(0, fadeDuration: 2)
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval.seconds(2)) {
                player.stop()
            }
        }
        players = []
        isPlaying = false
        isPianoSolo = false
        isLooping = false
        selectedSong = nil
        NotificationCenter.default.post(name: .soundPlayerPlayedOrStopped, object: nil)
    }
    
    private func playInstruments() {
        
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
    
    func updateVolumeForInstrumentForMuteChange(instrument: InstrumentCodable) {
        guard selectedSong?.cluster.hasInstruments.contains(where: { $0.id == instrument.id }) ?? false else { return }
        if let player = players.first(where: { $0.instrumentType == instrument.type }) {
            setVolumeFor(player: player)
        }
    }
    
    func setVolumeFor(_ type: InstrumentType, volume: Float) {
        playerFor(instrumentType: type)?.setVolume(volume, fadeDuration: 0)
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
        
        players = []
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
        if let urlString = instrument.resourcePath, let url = urlString.contains(where: { $0 == "/"}) ? URL(string: urlString) :
            GetFileURLUseCase(fileName: urlString).getURL(location: .persitent) {
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
}
