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
                    let vol = AVAudioSession.sharedInstance().outputVolume
                    var volume: Float = 0.5
                    if let instrumentType = player.instrumentType, let volumeInstrument = VolumeManager.getVolumeFor(instrumentType: instrumentType) {
                        volume = volumeInstrument
                    }
                    player.setVolume(min(vol,volume), fadeDuration: 2)
                }
            }
			isPlaying = true
		}
	}
	
	func stop() {
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
	}
	
	func playerFor(instrumentType: InstrumentType) -> InstrumentPlayer? {
		return players.first(where: { $0.instrumentType == instrumentType })
	}
    
    
    func updateVolumeBasedOnGlobalVolume() {
        for player in self.players {
            let vol = AVAudioSession.sharedInstance().outputVolume
            var volume: Float = 0.5
            if let instrumentType = player.instrumentType, let volumeInstrument = VolumeManager.getVolumeFor(instrumentType: instrumentType) {
                volume = volumeInstrument
            }
            player.setVolume(min(vol,volume), fadeDuration: 2)
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
	
}
