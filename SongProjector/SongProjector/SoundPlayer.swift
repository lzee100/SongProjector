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

class SoundPlay: NSObject, AVAssetDownloadDelegate {
	
	var isPlaying = false
	var song: Song?
	
	var players: [InstrumentPlayer] = []
	
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
	
	func play(song: Song) {
		stop()
		players = []
		if !isPlaying {
			self.song = song
			self.loadAudio()
			for player in players {
				player.play()
			}
			isPlaying = !isPlaying
		}
	}
	
	func stop() {
		if isPlaying {
			for player in players {
				player.stop()
			}
			isPlaying = !isPlaying
		}
	}
	
	func loadSongAudioFor(instrument: Instrument) {
		
		var player = InstrumentPlayer()
		
		if let resourcePath = instrument.resourcePath, let stringURL = Bundle.main.path(forResource: resourcePath, ofType: "mp3") {
			
			do {
				
				player = try InstrumentPlayer(contentsOf: URL(fileURLWithPath: stringURL))
				player.instrumentType = instrument.type
				player.prepareToPlay()
				players.append(player)
				
			}
			
			catch {
				print(error)
			}
			
		}
	}
	
}
