//
//  SongService.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05-08-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation

class SongService {
	
	private var playerTimer = Timer()
	private var stopAfterLastSheetTimer = Timer()
	
	var songs: [SongObject] = [] { didSet { songs.sort{ $0.cluster.position < $1.cluster.position } }}
	var selectedSection: Int?
	var selectedSong: SongObject? {
		didSet {
			if selectedSong != nil {
				selectedSheet = selectedSong?.sheets.first
				CoreCluster.managedObjectContext = moc
				let cluster = selectedSong?.cluster.getManagedObject(context: moc) as! Cluster
				cluster.lastShownAt = NSDate()
				do {
					try moc.save()
				} catch {}
				self.startPlay()
			} else {
				self.stopPlay()
			}
		}
	}
	
	var selectedSheet: VSheet? {
		didSet {
			if let sheet = selectedSheet {
				let newSong = songs.first(where: { $0.sheets.contains(sheet) })
				if newSong != selectedSong {
					selectedSong = newSong
				}
				displaySheet(sheet)
			} else {
				selectedSong = nil
				selectedSection = nil
				shutDownBeamer()
			}
		}
	}
	var selectedTheme: VTheme? { return selectedSheet?.hasTheme ?? selectedSong?.cluster.hasTheme }
	var previousTheme: VTheme? { return getPreviousTheme() }
	var nextTheme: VTheme? { return getNextTheme() }
	var isPlaying = false
	var isAnimating = false
	let swipeLeft: (() -> Void)
	let displaySheet: ((VSheet) -> Void)
	let shutDownBeamer: (() -> Void)
	
	init(swipeLeft: @escaping (() -> Void), displaySheet: @escaping ((VSheet) -> Void), shutDownBeamer: @escaping (() -> Void)) {
		self.swipeLeft = swipeLeft
		self.displaySheet = displaySheet
		self.shutDownBeamer = shutDownBeamer
	}
	
	@discardableResult
	func nextSheet(select: Bool = true) -> VSheet? {
		if let selectedSheet = selectedSheet, let selectedSong = selectedSong {
			let selectedSheetPosition = Int(selectedSheet.position)
			if selectedSheetPosition + 1 < selectedSong.sheets.count {
				if !select {
					return selectedSong.sheets[selectedSheetPosition + 1]
				}
				self.selectedSheet = selectedSong.sheets[selectedSheetPosition + 1]
				if let selectedSheet = self.selectedSheet, selectedSheet.time != 0, selectedSong.cluster.hasMusic {
					startPlay()
				}
				return self.selectedSheet
			} else {
				
				if isAnimating {
					if select {
						self.selectedSheet = selectedSong.sheets.first
					}
					return selectedSong.sheets.first
				}
				
				guard let index = songs.index(where: { $0 == selectedSong }) else {
					return nil
				}
				
				if index + 1 >= songs.count {
					return nil
				}
				if !select {
					return songs[index + 1].sheets.first
				}
				selectedSection = index + 1
				self.selectedSheet = songs[index + 1].sheets.first
				return selectedSheet
				
			}
		} else {
			if !select {
				return songs.first?.sheets.first
			}
			selectedSheet = songs.first?.sheets.first
			return selectedSheet
		}
	}
	
	@discardableResult
	func previousSheet(select: Bool = true) -> VSheet? {
		
		if let selectedSheet = selectedSheet, let selectedSong = songs.first(where: { $0.sheets.contains(selectedSheet) }) {
			let selectedSheetPosition = Int(selectedSheet.position)
			if selectedSheetPosition - 1 >= 0 {
				if !select {
					return selectedSong.sheets[selectedSheetPosition - 1]
				}
				self.selectedSheet = selectedSong.sheets[selectedSheetPosition - 1]
				return self.selectedSheet
			} else {
				guard let index = songs.index(where: { $0 == selectedSong }) else {
					return nil
				}
				
				if index - 1 < 0 {
					return nil
				}
				
				if !select || isAnimating {
					return songs[index - 1].sheets.first
				}
				
				selectedSection = index - 1
				self.selectedSheet = songs[index - 1].sheets.first
				return selectedSheet
				
			}
		} else {
			return nil
		}
	}
	
	func indexPathForNextSheet() -> IndexPath? {
		if let selectedSong = selectedSong {
			let selectedSheetPosition = Int(selectedSheet!.position)
			if selectedSheetPosition + 1 < selectedSong.sheets.count {
				return IndexPath(row: selectedSheetPosition + 1, section: Int(selectedSong.cluster.position))
			} else {
				guard let index = songs.index(where: { $0 == selectedSong }) else {
					return nil
				}
				
				if index + 1 >= songs.count {
					return nil
				}
				return IndexPath(row: 0, section: index + 1)
			}
		} else {
			if songs.first?.sheets.first != nil {
				return IndexPath(row: 0, section: 0)
			} else {
				return nil
			}
		}
	}
	
	func indexPathForPreviousSheet() -> IndexPath? {
		
		if let selectedSong = selectedSong {
			let selectedSheetPosition = Int(selectedSheet!.position)
			if selectedSheetPosition - 1 >= 0 {
				return IndexPath(row: selectedSheetPosition - 1, section: Int(selectedSong.cluster.position))
			} else {
				guard let index = songs.index(where: { $0 == selectedSong }) else {
					return nil
				}
				
				if index - 1 < 0 {
					return nil
				}
				return IndexPath(row: 0, section: index - 1)
			}
		} else {
			return nil
		}
	}
	
	func getSongForNextSheet() -> SongObject? {
		if isAnimating {
			return selectedSong
		}
		
		if let position = selectedSheet?.position, Int(position) + 1 < (selectedSong?.sheets.count ?? 0) {
			return selectedSong
		} else {
			if let index = songs.index(where: { $0 == selectedSong }) {
				if index + 1 < songs.count {
					return songs[index + 1]
				}
				return nil
			} else {
				return songs.first
			}
		}
	}
	
	func getSongForPreviousSheet() -> SongObject? {
		if let position = selectedSheet?.position, Int(position) - 1 >= 0 {
			return selectedSong
		} else {
			if let index = songs.index(where: { $0 == selectedSong }) {
				if index - 1 >= 0 {
					return songs[index - 1]
				}
				return nil
			} else {
				return nil
			}
		}
	}
	
	private func getPreviousTheme() -> VTheme? {
		if let selectedSong = selectedSong {
			let selectedSheetPosition = Int(selectedSheet!.position)
			if selectedSheetPosition - 1 >= 0 {
				return selectedSong.sheets[selectedSheetPosition - 1].hasTheme ?? selectedSong.cluster.hasTheme
			} else {
				guard let index = songs.index(where: { $0 == selectedSong }) else {
					return nil
				}
				
				if index - 1 < 0 {
					return nil
				}
				
				return songs[index - 1].sheets.first?.hasTheme ?? songs[index - 1].cluster.hasTheme
				
			}
		} else {
			return nil
		}
	}
	
	private func getNextTheme() -> VTheme? {
//		if isAnimating {
//			return selectedTheme
//		}
		if let selectedSong = selectedSong {
			
			let selectedSheetPosition = Int(selectedSheet!.position)
			
			if selectedSheetPosition + 1 < selectedSong.sheets.count {
				return selectedSong.sheets[selectedSheetPosition + 1].hasTheme ?? selectedSong.cluster.hasTheme
			} else {
				guard let index = songs.index(where: { $0 == selectedSong }) else {
					return nil
				}
				
				if index + 1 >= songs.count {
					if isAnimating {
						return songs[index].sheets.first?.hasTheme ?? songs[index].cluster.hasTheme
					}
					return nil
				}
				
				if isAnimating {
					return songs[index].sheets.first?.hasTheme ?? songs[index].cluster.hasTheme
				}
				
				return songs[index + 1].sheets.first?.hasTheme ?? songs[index + 1].cluster.hasTheme
				
			}
		} else {
			return songs.first?.sheets.first?.hasTheme ?? songs.first?.cluster.hasTheme
		}
	}
	
	private func startPlay() {
		
		if (selectedSheet?.hasCluster?.hasMusic ?? false) && selectedSheet?.position == selectedSong?.sheets.last?.position && selectedSong?.cluster.hasSheets.count != 1 {
			playerTimer.invalidate()
			if let time = selectedSheet?.time {
				stopAfterLastSheetTimer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(stopPlay), userInfo: nil, repeats: true)
			}
			return
		}
		
		var time = selectedSheet?.time
		if time == nil || time == 0 {
			time = selectedSong?.cluster.time
		}
		
		if let time = time, time > 0 {
			
			if let song = selectedSong?.cluster, song.hasMusic, !SoundPlayer.isPlaying {
				
//				if !SoundPlayer.isLooping, Int(selectedSheet?.position ?? 0) == (song.hasSheets?.count ?? 0) - 1 {
//					SoundPlayer.stop()
//				}
				SoundPlayer.play(song: song)
				isPlaying = true
			} else {
				isAnimating = true
			}
			playerTimer.invalidate()
			playerTimer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(swipeAutomatically), userInfo: nil, repeats: true)
		}
	}
	
	@objc private func swipeAutomatically() {
		print("swipe left")
		self.swipeLeft()
	}
	
	@objc private func stopPlay() {
		playerTimer.invalidate()
		SoundPlayer.stop()
		isPlaying = false
		isAnimating = false
	}
	
}








class SongObject: Comparable {
	
	var cluster: VCluster { didSet { addEmptySheet() }}
	var sheets: [VSheet] = []
	
	private func addEmptySheet() {
		if cluster.hasTheme?.hasEmptySheet ?? false {
			
			var emptySheetsAdded: [VSheet] = []
			
			let emptySheet = VSheetEmpty()
			emptySheet.deleteDate = NSDate()
			emptySheet.isEmptySheet = true
			
			if cluster.hasTheme?.isEmptySheetFirst ?? false {
				emptySheetsAdded.append(emptySheet)
				emptySheetsAdded.append(contentsOf: cluster.hasSheets)
			} else {
				emptySheetsAdded.append(contentsOf: cluster.hasSheets)
				emptySheetsAdded.append(emptySheet)
			}
			
			var position = 0
			emptySheetsAdded.forEach {
				$0.position = position
				position += 1
			}
			
			sheets = emptySheetsAdded
		} else {
			sheets = cluster.hasSheets
		}
	}
	
//	var selectedSheet: Sheet?
	var clusterTheme: VTheme? {
		return cluster.hasTheme
	}
	
	init(cluster: VCluster) {
		self.cluster = cluster
		addEmptySheet()
	}
	
	static func ==(lhs: SongObject, rhs: SongObject) -> Bool {
		return lhs.cluster.id == rhs.cluster.id
	}
	
	static func < (lhs: SongObject, rhs: SongObject) -> Bool {
		return lhs.cluster.position < rhs.cluster.position
	}
	
}
