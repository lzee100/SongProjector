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
	private var song: Cluster?
	private var timer: Timer?
	private var loopTime: TimeInterval = 0
	
	var queuePlayer = AVQueuePlayer()
	var playerLooper: AVPlayerLooper?
	
	private var players: [InstrumentPlayer] = []
	
	func loadAudio() {
		
		do {
			let audioSession = AVAudioSession.sharedInstance()
			try audioSession.setCategory(AVAudioSessionCategoryPlayback)
		
		} catch {
			print(error)
		}
		
		if let song = song {
			for instrument in song.hasIntrumentsArray {
				loadSongAudioFor(instrument: instrument)
			}
		}
		
	}
	
	func play(song: Cluster) {
		stop()
		players = []
		if !isPlaying {
			self.song = song
			self.loadAudio()
			
			for player in players {
				if !player.isLoop {
					player.volume = 0
					player.play()
					player.setVolume(1, fadeDuration: 2)
					if players.contains(where: { $0.isLoop }) {
						loopTime = player.duration
						timer?.invalidate()
						timer = Timer.scheduledTimer(timeInterval: loopTime, target: self, selector: #selector(replayForLoop), userInfo: nil, repeats: true)
					}
				}
			}
			isPlaying = !isPlaying
		}
	}
	
	func stop() {
		if isPlaying {
			for player in players {
				player.setVolume(0, fadeDuration: 2)
				DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval.seconds(2)) {
					player.stop()
				}
			}
			isPlaying = !isPlaying
		}
	}
	
	func playerFor(instrumentType: InstrumentType) -> InstrumentPlayer? {
		return players.first(where: { $0.instrumentType == instrumentType })
	}
	
	private func loadSongAudioFor(instrument: Instrument) {
		
		var player = InstrumentPlayer()
		
		if let resourcePath = instrument.resourcePath, let stringURL = Bundle.main.path(forResource: resourcePath, ofType: "m4a") {
			
			do {
				
				player = try InstrumentPlayer(contentsOf: URL(fileURLWithPath: stringURL))
				player.instrumentType = instrument.type
				player.prepareToPlay()
				player.delegate = self
				player.isLoop = false
				if instrument.isLoop {
					let playerLoop = try InstrumentPlayer(contentsOf: URL(fileURLWithPath: stringURL))
					playerLoop.instrumentType = instrument.type
					playerLoop.isLoop = true
					playerLoop.prepareToPlay()
					playerLoop.delegate = self
					players.append(playerLoop)
				}
				players.append(player)
				
			}
			
			catch {
				print(error)
			}
			
		}
	}
	
	@objc func replayForLoop() {
		if let newPlayer = players.first(where: { !$0.isPlaying }) {
			newPlayer.play()
		}
		timer?.invalidate()
		timer = Timer.scheduledTimer(timeInterval: loopTime, target: self, selector: #selector(replayForLoop), userInfo: nil, repeats: true)
	}
	
	
	
}
