//
//  SongService.swift
//  SongProjector
//
//  Created by Leo van der Zee on 05-08-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit

struct SongServiceUI {
    
    var selectedSong: SongObjectUI? {
        didSet {
            setSectionIndex()
            setSelectedTheme()
            selectedSheetId = selectedSong?.sheets.first?.id
        }
        
    }
    var selectedSheetId: String? {
        didSet {
            selectedSheetIndex = selectedSong?.sheets.firstIndex(where: { $0.id == selectedSheetId })
            selectedSheetTheme = selectedSong?.sheets.first(where: { $0.id == selectedSheetId })?.theme
            setSelectedTheme()
        }
    }
    var displayerSelectionIndex: Int? {
        guard let selectedSongIndex = selectedSection else { return nil }
         return selectedSongIndex + (selectedSong?.sheets.firstIndex(where: { $0.id == selectedSheetId }) ?? 0)
    }
    
    private(set) var songs: [SongObjectUI] = []
    private(set) var selectedSection: Int?
    private(set) var selectedSheetIndex: Int?
    private(set) var selectedSongTheme: ThemeCodable?
    private(set) var selectedSheetTheme: ThemeCodable?
    private(set) var sectionedSongs: [SongServiceSectionWithSongs] = []
    
    mutating func set(sectionedSongs: [SongServiceSectionWithSongs]) {
        self.sectionedSongs = sectionedSongs
        self.songs = sectionedSongs.flatMap { $0.songs }
        selectedSong  = nil
        selectedSheetId = nil
        selectedSection = nil
        selectedSheetIndex = nil
        selectedSongTheme = nil
        selectedSheetTheme = nil
    }
    
    func sheetTitleFor(sheet: SheetMetaType) -> String? {
        if sheet.theme != nil {
            return sheet.title
        }
        if sheet.position == 0 {
            return songs.first(where: { $0.sheets.contains(where: { $0.id == sheet.id }) })?.cluster.title
        } else if selectedSongTheme?.allHaveTitle ?? false {
            return songs.first(where: { $0.sheets.contains(where: { $0.id == sheet.id }) })?.cluster.title
        }
        return nil
    }
    
    mutating private func setSectionIndex() {
        selectedSection = songs.firstIndex(where: { $0.cluster.id == selectedSong?.cluster.id })
    }
    
    mutating private func setSelectedTheme() {
        guard let cluster = selectedSong?.cluster else {
            return selectedSongTheme = nil
        }
        if let theme = cluster.theme {
            selectedSongTheme = theme
        }
    }
    
    func getSheetIndexWithSongIndexAddedIfNeeded(_ sheetIndex: Int) -> Int {
        return sheetIndex + (selectedSection ?? 0)
    }
    
    func getSongIndexWithSheetIndexAddedIfNeeded(_ song: SongObjectUI) -> Int {
        guard let songIndex = songs.firstIndex(where: { $0.id == song.id }) else { return 0 }
        let addedIndex = songIndex > (selectedSection ?? 0) ? (selectedSong?.sheets.count ?? 0) - 1 : 0
        return songIndex + addedIndex
    }
    
    func themeFor(sheet: SheetMetaType) -> ThemeCodable? {
        if let theme = sheet.theme {
            return theme
        }
        let cluster = songs.first(where: { $0.sheets.contains(where: { $0.id == sheet.id }) })?.cluster
        if [cluster?.isTypeSong, cluster?.hasBibleVerses].compactMap({ $0 }).contains(true) {
            return cluster?.theme
        }
        return nil
    }

}

var isForPreviewUniversalSongEditing = false

protocol SongServiceDelegate {
    func countDown(value: Int)
    func swipeLeft()
    func displaySheet(_ sheet: VSheet)
    func shutDownBeamer()
}

class SongService: ObservableObject {
	
    private static let countDownMax = 3
	private var playerTimer = Timer()
    private var countDownTimer = Timer()
    private var countDownValue: Int = countDownMax
    private var stopAfterLastSheetTimer: Timer?
    private let sheetTimeOffset: Double
	var songs: [SongObject] = [] { didSet { songs.sort{ $0.cluster.position < $1.cluster.position } }}
	var selectedSection: Int?
    var selectedSongIndex: Int? {
        return songs.firstIndex(where: { $0.cluster.id == selectedSong?.cluster.id })
    }
    var songsClusteredPerSection: [[SongObject]] {
        var sectionedSongObjects: [[SongObject]] = []
        var remainingSongs = songs
        repeat {
            var songsForSection = [SongObject]()
            if let firstRemainingSong = remainingSongs.first {
                songsForSection.append(firstRemainingSong)
                remainingSongs.remove(at: 0)
                let firstIndex = remainingSongs.firstIndex(where: { $0.headerTitle != nil })
                if let firstIndex = firstIndex {
                    songsForSection.append(contentsOf: remainingSongs[0...firstIndex])
                    sectionedSongObjects.append(songsForSection)
                }
            }
        } while remainingSongs.count != 0
        return sectionedSongObjects
    }
    
	@Published var selectedSong: SongObject? {
		didSet {
            self.stopPlay()
			if selectedSong != nil {
				selectedSheet = selectedSong?.sheets.first
                #if (!DEBUG)
                if !isForPreviewUniversalSongEditing {
                    selectedSong?.cluster.setLastShownAt()
                }
                SongServicePlayDateSubmitter.subMitPlayDate()
                #endif  
			}
		}
	}
	
    @Published var selectedSheet: VSheet? {
		didSet {
			if let sheet = selectedSheet {
                let newSong = songs.first(where: { $0.sheets.contains(where: { $0.id == sheet.id }) })
				if newSong != selectedSong {
					selectedSong = newSong
				}
                if (sheet.time != 0 && (selectedSong?.cluster.hasLocalMusic ?? false)) || selectedSong?.cluster.time != 0 {
                    startPlay()
                }
                delegate?.displaySheet(sheet)
			} else {
				selectedSong = nil
				selectedSection = nil
                delegate?.shutDownBeamer()
			}
		}
	}
	var selectedTheme: VTheme? { return selectedSheet?.hasTheme ?? selectedSong?.cluster.hasTheme(moc: moc) }
	var previousTheme: VTheme? { return getPreviousTheme() }
	var nextTheme: VTheme? { return getNextTheme() }
	var isPlaying = false
	var isAnimating = false
    var delegate: SongServiceDelegate?
	
    init(delegate: SongServiceDelegate?) {
        self.delegate = delegate
        let user: User? = DataFetcher().getEntity(moc: moc, predicates: [.skipDeleted])
        self.sheetTimeOffset = [user].compactMap({ $0 }).map({ VUser(user: $0, context: moc) }).first?.sheetTimeOffset ?? 0
	}
    
    enum SelectAction {
        case song(SongObject)
        case none
    }
    
    func didSelect(_ selectAction: SelectAction) -> NSDiffableDataSourceSnapshot<SongObject, VSheet> {
        switch selectAction {
        case .song(let song):
            var snapshot = SongServiceDataSource.snapshot()
            if let selectedSong = selectedSong {
                snapshot.deleteItems(selectedSong.sheets)
                if selectedSong.cluster.id == song.cluster.id {
                    snapshot.appendSections(songs)
                    self.selectedSong = nil
                    selectedSheet = nil
                } else {
                    snapshot.appendSections(songs)
                    snapshot.appendItems(song.sheets, toSection: song)
                    self.selectedSong = song
                    selectedSheet = song.sheets.first
                }
                snapshot.reloadSections([selectedSong])
            } else {
                selectedSong = song
                selectedSheet = song.sheets.first
                snapshot.appendSections(songs)
                snapshot.appendItems(song.sheets, toSection: song)
            }
            return snapshot
        case .none:
            var snapshot = SongServiceDataSource.snapshot()
            snapshot.appendSections(songs)
            return snapshot
        }
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
                if let selectedSheet = self.selectedSheet, selectedSheet.time != 0, selectedSong.cluster.hasLocalMusic, !SoundPlayer.isPlaying {
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
				
                guard let index = songs.firstIndex(where: { $0 == selectedSong }) else {
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
                guard let index = songs.firstIndex(where: { $0 == selectedSong }) else {
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
                guard let index = songs.firstIndex(where: { $0 == selectedSong }) else {
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
                guard let index = songs.firstIndex(where: { $0 == selectedSong }) else {
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
            if let index = songs.firstIndex(where: { $0 == selectedSong }) {
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
		if let position = selectedSheet?.position, position - 1 >= 0 {
			return selectedSong
		} else {
            guard let index = songs.firstIndex(where: { $0 == selectedSong }) else { return nil }
            return songs[safe: index - 1]
		}
	}
	
	private func getPreviousTheme() -> VTheme? {
        guard let selectedSong = selectedSong, let index = songs.firstIndex(where: { $0 == selectedSong }) else {
            return nil
        }

        if let position = selectedSheet?.position, position - 1 >= 0 {
            return selectedSong.sheets[safe: position - 1]?.hasTheme ?? selectedSong.cluster.hasTheme(moc: moc)
        }
        return songs[safe: index - 1]?.sheets.first?.hasTheme ?? songs[index - 1].cluster.hasTheme(moc: moc)
	}
	
	private func getNextTheme() -> VTheme? {
//		if isAnimating {
//			return selectedTheme
//		}
		if let selectedSong = selectedSong {
			
			let selectedSheetPosition = Int(selectedSheet!.position)
			
			if selectedSheetPosition + 1 < selectedSong.sheets.count {
				return selectedSong.sheets[selectedSheetPosition + 1].hasTheme ?? selectedSong.cluster.hasTheme(moc: moc)
			} else {
                guard let index = songs.firstIndex(where: { $0 == selectedSong }) else {
					return nil
				}
				
				if index + 1 >= songs.count {
					if isAnimating {
						return songs[index].sheets.first?.hasTheme ?? songs[index].cluster.hasTheme(moc: moc)
					}
					return nil
				}
				
				if isAnimating {
					return songs[index].sheets.first?.hasTheme ?? songs[index].cluster.hasTheme(moc: moc)
				}
				
				return songs[index + 1].sheets.first?.hasTheme ?? songs[index + 1].cluster.hasTheme(moc: moc)
				
			}
		} else {
			return songs.first?.sheets.first?.hasTheme ?? songs.first?.cluster.hasTheme(moc: moc)
		}
	}
	
	private func startPlay() {
		
        if selectedSong?.cluster.hasLocalMusic ?? false && selectedSheet?.position == selectedSong?.sheets.last?.position && selectedSong?.sheets.count != 1 {
			playerTimer.invalidate()
			if let time = selectedSheet?.time {
				stopAfterLastSheetTimer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(stopPlay), userInfo: nil, repeats: false)
			}
			return
		}
		
		var time = selectedSheet?.time
		if time == nil || time == 0 {
			time = selectedSong?.cluster.time
		}
		
		if let time = time, time > 0 {
			
            if let song = selectedSong?.cluster, song.hasLocalMusic, song.id != SoundPlayer.song?.id {
				SoundPlayer.play(song: song)
				isPlaying = true
                countDownValue = SongService.countDownMax
                if song.startTime > 0 {
                    countDownTimer.invalidate()
                    switch song.startTime {
                    case 5...: countDownValue = 3
                    case 1 ..< 1.6: countDownValue = 1
                    default: countDownValue = Int(song.startTime - 1)
                    }
                    countDownTimer = Timer.scheduledTimer(timeInterval: TimeInterval(song.startTime - Double(countDownValue)), target: self, selector: #selector(triggerCountDown), userInfo: nil, repeats: true)
                }
			} else {
				isAnimating = true
			}
			playerTimer.invalidate()
			playerTimer = Timer.scheduledTimer(timeInterval: time + sheetTimeOffset, target: self, selector: #selector(swipeAutomatically), userInfo: nil, repeats: true)
		}
	}
    
    @objc private func triggerCountDown() {
        delegate?.countDown(value: countDownValue)
        countDownValue -= 1
        if countDownValue >= 0 {
            countDownTimer.invalidate()
            countDownTimer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(triggerCountDown), userInfo: nil, repeats: true)
        } else {
            countDownTimer.invalidate()
            countDownValue = SongService.countDownMax
        }
    }

	@objc private func swipeAutomatically() {
		delegate?.swipeLeft()
	}
	
	@objc private func stopPlay() {
        stopAfterLastSheetTimer?.invalidate()
        stopAfterLastSheetTimer = nil
		playerTimer.invalidate()
        countDownTimer.invalidate()
        countDownValue = SongService.countDownMax
		SoundPlayer.stop()
		isPlaying = false
		isAnimating = false
	}
    
    func getSheetIndexWithSongIndexAddedIfNeeded(_ currentIndex: Int) -> Int {
        return currentIndex + (selectedSongIndex ?? 0)
    }
    
    func getSongIndexWithSheetIndexAddedIfNeeded(_ currentIndex: Int) -> Int {
        let addedIndex = currentIndex > (selectedSongIndex ?? 0) ? (selectedSong?.sheets.count ?? 0) - 1 : 0
        return currentIndex + addedIndex
    }
}



struct SongObjectUI: Equatable {
    
    let sectionHeader: String?
    let cluster: ClusterCodable
    let sheets: [SheetMetaType]
    var id: String {
        cluster.id
    }
    
    init(cluster: ClusterCodable, sectionHeader: String? = nil) {
        self.sectionHeader = sectionHeader
        self.cluster = cluster
        
        let theme: Theme? = DataFetcher().getEntity(moc: moc, predicates: [.get(id: cluster.themeId)])
        if let theme = theme, theme.hasEmptySheet {
            var sheetEmpty = SheetEmptyCodable.makeDefault()
            sheetEmpty.isEmptySheet = true
            let sortedSheets = cluster.hasSheets.sorted(by: { $0.position < $1.position })
            let sheets = theme.isEmptySheetFirst ? [sheetEmpty] + cluster.hasSheets : cluster.hasSheets + [sheetEmpty]
            var positionedSheets: [SheetMetaType] = []
            for (index, sheet) in sheets.enumerated() {
                var sheet = sheet
                sheet.position = index
                positionedSheets.append(sheet)
            }
            self.sheets = positionedSheets
        } else {
            self.sheets = cluster.hasSheets.sorted(by: { $0.position < $1.position })
        }
    }
    
    static func == (lhs: SongObjectUI, rhs: SongObjectUI) -> Bool {
        return lhs.id == rhs.id
    }

}




class SongObject: Hashable, Identifiable {
	
    private(set) var headerTitle: String?
	private(set) var cluster: VCluster { didSet { addEmptySheet() }}
	private(set) var sheets: [VSheet] = []
	
	private func addEmptySheet() {
		if cluster.hasTheme(moc: moc)?.hasEmptySheet ?? false {
			
			var emptySheetsAdded: [VSheet] = []
			
			let emptySheet = VSheetEmpty()
			emptySheet.deleteDate = NSDate()
			emptySheet.isEmptySheet = true
			
			if cluster.hasTheme(moc: moc)?.isEmptySheetFirst ?? false {
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
		return cluster.hasTheme(moc: moc)
	}
	
    init(cluster: VCluster, headerTitle: String?) {
        self.headerTitle = headerTitle
		self.cluster = cluster
		addEmptySheet()
	}
	
	static func ==(lhs: SongObject, rhs: SongObject) -> Bool {
		return lhs.cluster.id == rhs.cluster.id
	}
	
	static func < (lhs: SongObject, rhs: SongObject) -> Bool {
		return lhs.cluster.position < rhs.cluster.position
	}
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(cluster)
    }
	
}
