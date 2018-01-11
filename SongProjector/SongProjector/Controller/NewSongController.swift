//
//  NewSongController.swift
//  SongViewer
//
//  Created by Leo van der Zee on 06-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit
import CoreData

class NewSongController: UIViewController, UITableViewDataSource, UITableViewDelegate, NewSongSheetCellDelegate {
	
	// MARK: - Types
	struct Constants {
		static let songTitleSheet = 1
	}
	
	
	
	// MARK: - Properties

	@IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var done: UIBarButtonItem!
	@IBOutlet var headerTags: UILabel!
	@IBOutlet var headerLyrics: UILabel!
	@IBOutlet var inputTextView: UITextView!
	@IBOutlet var tableViewTags: UITableView!
	@IBOutlet var tableViewSheets: UITableView!
	
	
	
	// MARK: - Properties
	
	private var clusterTitle = ""
	private var sheets: [Sheet] = []
	private var tempSheetsBeforeSaving: [(title: String, lyrics: String, position: Int16)] = []
	private var tags: [Tag] = []
	private var selectedTag: Tag? {
		didSet { update() }
	}
	private var sheetMode = false
	
	private var isTableViewHidden = true {
		didSet { update() }
	}
	
	
	
	// MARK: - Functions
	
	// MARK: UIViewController Functions
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setup()
    }
	
	
	
	// MARK: UITableViewDelegate Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		if tableView == tableViewSheets {
			return tempSheetsBeforeSaving.count + Constants.songTitleSheet
		} else {
			return 1
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView == tableViewTags {
			return tags.count
		}
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if tableView == tableViewTags {
			let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
			if let cell = cell as? BasicCell {
				cell.setup(title: tags[indexPath.row].title, icon: Cells.bulletFilled)
				cell.selectedCell = selectedTag?.id == tags[indexPath.row].id
			}
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: Cells.newSongSheetCellid, for: indexPath)
			
			if let cell = cell as? NewSongSheetCell {
				if indexPath.section == 0 {
					cell.index = 0
					cell.songTitle = clusterTitle
				} else {
					if indexPath.section == 4 {
						print("")
					}
					print(indexPath.section)
					print(tempSheetsBeforeSaving[indexPath.section-Constants.songTitleSheet].lyrics)
					cell.index = indexPath.section
					cell.lyrics = tempSheetsBeforeSaving[indexPath.section-Constants.songTitleSheet].lyrics
					cell.delegate = self
				}
			}
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if tableView == tableViewTags {
			return 60
		} else {
			return indexPath.section == 0 ? 70 : 220
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if tableView == tableViewSheets {
			if section == 0 {
				return Text.NewSong.SongTitle
			} else {
				return Text.NewSong.Sheet + "\(section)"
			}
		} else {
			return nil
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView == tableViewTags {
			if selectedTag?.id == tags[indexPath.row].id {
				selectedTag = nil
			} else {
				selectedTag = tags[indexPath.row]
			}
			update()
		}
	}
	
	
	
	// MARK: - NewSongSheetCellDelegate Functions
	
	func textViewDidChange(index: Int?, lyrics: String?) {
		if let index = index{
			tempSheetsBeforeSaving[index].lyrics = lyrics ?? ""
		}
	}
	
	
	// MARK: - Private Functions
	
	private func setup() {

		tableViewTags.register(cell: Cells.basicCellid)
		tableViewSheets.register(cell: Cells.newSongSheetCellid)
		navigationController?.title = Text.NewSong.title
		cancel.title = Text.Actions.cancel
		done.title = Text.Actions.done
		headerTags.text = Text.NewSong.headerTag
		headerLyrics.text = Text.NewSong.headerLyrics

		isTableViewHidden = true
	}
	
	private func update() {
		// TODO: uncomment
		CoreTag.predicates.append("title", notEquals: "Player")
		tags = CoreTag.getEntities()
		tableViewTags.reloadData()
		tableViewSheets.reloadData()
		tableViewSheets.isHidden = isTableViewHidden
	}
	
	private func buildSheets(fromText: String) {
		print(fromText)
		
		var lyricsToDevide = fromText + "\n\n"
		
		// get title
		if let range = lyricsToDevide.range(of: "\n\n") {
			let start = lyricsToDevide.index(lyricsToDevide.startIndex, offsetBy: 0)
			let rangeSheet = start..<range.lowerBound
			let rangeRemove = start..<range.upperBound
			clusterTitle = String(lyricsToDevide[rangeSheet])
			lyricsToDevide.removeSubrange(rangeRemove)
		}
		
		var position: Int16 = 0
		// get sheets
		while let range = lyricsToDevide.range(of: "\n\n") {
			
			// get lyrics
			let start = lyricsToDevide.index(lyricsToDevide.startIndex, offsetBy: 0)
			let rangeSheet = start..<range.lowerBound
			let rangeRemove = start..<range.upperBound
			
			let sheetLyrics = String(lyricsToDevide[rangeSheet])
			var sheetTitle: String = Text.NewSong.NoTitleForSheet
			
			// get title
			if let rangeTitle = lyricsToDevide.range(of: "\n") {
				let startTitle = lyricsToDevide.index(lyricsToDevide.startIndex, offsetBy: 0)
				let rangeSheetTitle = startTitle..<rangeTitle.lowerBound
				sheetTitle = String(lyricsToDevide[rangeSheetTitle])
			}

			tempSheetsBeforeSaving.append((title: sheetTitle, lyrics: sheetLyrics, position: position))
			
			lyricsToDevide.removeSubrange(rangeRemove)
			position += 1
		}
		
		tempSheetsBeforeSaving.sort{ $0.position < $1.position }
		
	}

	
	
	// MARK: - IBAction Functions
	
	@IBAction func cancel(_ sender: UIBarButtonItem) {
		
		if !sheetMode {
			dismiss(animated: true)
		} else {
			sheetMode = false
			tempSheetsBeforeSaving = []
		}
		
		isTableViewHidden = true

	}
	
	@IBAction func done(_ sender: UIBarButtonItem) {
		if sheetMode {

			let cluster = CoreCluster.createEntity()
			cluster.title = clusterTitle
			let id = Int(cluster.id)
			cluster.position = Int16(id)
			if CoreCluster.saveContext() { print("song saved") } else { print("song not saved") }
			
			for tempSheet in tempSheetsBeforeSaving {
				let sheet = CoreSheet.createEntityNOTsave()
				sheet.title = tempSheet.title
				sheet.lyrics = tempSheet.lyrics
				sheet.position = tempSheet.position
				sheet.hasCluster = cluster
				sheets.append(sheet)
			}
			
			if CoreSheet.saveContext() { print("sheets saved") } else { print("sheets not saved") }

			cluster.hasTag = selectedTag
			if CoreTag.saveContext() { print("tag saved") } else { print("tag not saved") }
			
			dismiss(animated: true)
			
		} else {
			isTableViewHidden = false
			sheetMode = true
			buildSheets(fromText: inputTextView.text)
			
			update()
		}
	}

}
