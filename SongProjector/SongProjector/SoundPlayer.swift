//
//  SoundPlayer.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01-02-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import AVFoundation

//https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3

let SoundPlayer = SoundPlay()

class SoundPlay: NSObject, AVAssetDownloadDelegate, AVAudioPlayerDelegate {
	
	var isPlaying = false
	var isPianoOnlyPlaying = false
	var isLooping = false
	
	private var song: VCluster?
	private var timer: Timer?
	private var loopTime: TimeInterval = 0
	private var queuePlayer = AVQueuePlayer()
	private var playerLooper: AVPlayerLooper?
	
	private var players: [InstrumentPlayer] = []
	
	func play(song: VCluster, pianoSolo: Bool = false) {
		stop()
		isPianoOnlyPlaying = pianoSolo
		players = []
		if !isPlaying {
			self.song = song
			self.loadAudio(pianoSolo: pianoSolo)
			
//			if isLooping {
//				timer = Timer.scheduledTimer(timeInterval: song.time, target: self, selector: #selector(replay), userInfo: nil, repeats: true)
//			}
			for player in players {
				player.volume = 0
				player.play()
				player.setVolume(1, fadeDuration: 2)
			}
			isPlaying = !isPlaying
		}
	}
	
	func stop() {
		if isPlaying {
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
		}
	}
	
	func playerFor(instrumentType: InstrumentType) -> InstrumentPlayer? {
		return players.first(where: { $0.instrumentType == instrumentType })
	}
	
	private func loadAudio(pianoSolo: Bool) {
		
		do {
			let audioSession = AVAudioSession.sharedInstance()
			try audioSession.setCategory(AVAudioSessionCategoryPlayback)
			
		} catch {
			print(error)
		}
		
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
		
		if let resourcePath = instrument.resourcePath, let stringURL = Bundle.main.path(forResource: resourcePath, ofType: "m4a") {
			
			do {
				player = try InstrumentPlayer(contentsOf: URL(fileURLWithPath: stringURL))
				player.instrumentType = instrument.type
				player.prepareToPlay()
				player.delegate = self
				player.isLoop = instrument.isLoop
				player.numberOfLoops = instrument.isLoop ? -1 : 0
				players.append(player)
			}
			
			catch {
				print(error)
			}
			
		}
	}
	
//	 @objc private func replay() {
//		if let song = song {
//			play(song: song)
//		}
//	}
	
	
}
