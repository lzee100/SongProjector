//
//  SoundPlayer.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01-02-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import MediaPlayer


//https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3

let SoundPlayer = SoundPlay()

class SoundPlay: NSObject, AVAssetDownloadDelegate {
	
	var isPlaying = false
	var isPianoOnlyPlaying = false
	var isLooping = false
	
	private (set) var song: VCluster?
	private var timer: Timer?
	private var loopTime: TimeInterval = 0
	private var queuePlayer = AVQueuePlayer()
	private var playerLooper: AVPlayerLooper?
	
    private var players: [InstrumentPlayer] = []
    
    override init() {
        super.init()
        do {
            UIApplication.shared.beginReceivingRemoteControlEvents()
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .moviePlayback, policy: .longFormAudio, options: [.mixWithOthers, .allowAirPlay, .allowBluetooth])
//            NotificationCenter.default.addObserver(self, selector: #selector(volumeDidChange(notification:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
            
        } catch {
            print(error)
        }
    }
    
	func play(song: VCluster, pianoSolo: Bool = false) {
        try? AVAudioSession.sharedInstance().setActive(true)
		stop()
		isPianoOnlyPlaying = pianoSolo
		players = []
		if !isPlaying {
			self.song = song
			self.loadAudio(pianoSolo: pianoSolo)
			
            DispatchQueue.global(qos: .background).async {
                let commandCenter = MPRemoteCommandCenter.shared()
                commandCenter.playCommand.isEnabled = true

                for player in self.players {
                    commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
                        if player.rate == 0.0 {
                            player.play()
                            return .success
                        }
                        return .commandFailed
                    }
                    player.volume = 0
                    player.play()
                    let systemVolume = AVAudioSession.sharedInstance().outputVolume
                    var instrumentVolume: Float = 0.5
                    if let instrumentType = player.instrumentType, let volumeInstrument = VolumeManager.getVolumeFor(instrumentType: instrumentType) {
                        instrumentVolume = volumeInstrument
                    }
                    var isMuted = false
                    if let instrument = song.hasInstruments.first(where: { $0.type == player.instrumentType }) {
                        isMuted = VolumeManager.isMutedFor(instrument: instrument)
                    }
                    if isMuted {
                        player.setVolume(0, fadeDuration: 2)
                    } else {
                        player.setVolume(systemVolume * instrumentVolume, fadeDuration: 2)
                    }
                }
            }
			isPlaying = true
            NotificationCenter.default.post(name: .soundPlayerPlayedOrStopped, object: nil)
		}
	}
	
	func stop() {
        try? AVAudioSession.sharedInstance().setActive(false)
        timer?.invalidate()
        timer = nil
        for player in players {
            player.setVolume(0, fadeDuration: 2)
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval.seconds(2)) {
                player.stop()
            }
        }
        isPlaying = false
        isPianoOnlyPlaying = false
        song = nil
        NotificationCenter.default.post(name: .soundPlayerPlayedOrStopped, object: nil)
	}
	
	private func playerFor(instrumentType: InstrumentType) -> InstrumentPlayer? {
		return players.first(where: { $0.instrumentType == instrumentType })
	}
    
    func setVolumeFor(_ type: InstrumentType, volume: Float, saveValue: Bool = true) {
        SoundPlayer.playerFor(instrumentType: type)?.setVolume(volume, fadeDuration: 0)
        if saveValue {
            VolumeManager.set(volume: volume, instrumentType: type)
        }
    }
    
    func getVolumeFor(_ type: InstrumentType) -> Float? {
        SoundPlayer.playerFor(instrumentType: type)?.volume
    }
    
    func containsInstrument(_ instrument: VInstrument) -> Bool {
        return song?.hasInstruments.contains(entity: instrument) ?? false
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
//    private func volumeDidChange(notification: NSNotification) {
//        let volume = notification.userInfo!["AVSystemController_AudioVolumeNotificationParameter"] as! Float
//    }
    
    private func loadAudio(pianoSolo: Bool) {
        
		if let song = song {
			
			isLooping = song.hasInstruments.filter({ $0.isLoop == true }).count > 0 || song.hasInstruments.contains(where: { $0.type == .pianoSolo })
			
			if pianoSolo, let instrument = song.hasInstruments.first(where: { $0.type == .pianoSolo }) {
				loadSongAudioFor(instrument: instrument)
				return
			}
			
			for instrument in song.hasInstruments.filter({ $0.type != .pianoSolo }) {
				loadSongAudioFor(instrument: instrument)
			}
			
		}
		
	}
	
	private func loadSongAudioFor(instrument: VInstrument) {
		
		var player = InstrumentPlayer()
        if let urlString = instrument.resourcePath {
            let url = GetFileURLUseCase(fileName: urlString).getURL(location: .persitent)
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
