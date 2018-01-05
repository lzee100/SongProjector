//
//  NewSongIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

class NewSongIphoneController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NewSongSheetCellDelegate {
	
	// MARK: - Types
	struct Constants {
		static let songTitleSheet = 1
	}
	
	@IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var done: UIBarButtonItem!
	
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var textView: UITextView!
	@IBOutlet var collectionViewSheets: UICollectionView!
	
	// MARK: - Properties
	
	private var clusterTitle = ""
	private var sheets: [Sheet] = []
	private var tempSheetsBeforeSaving: [(title: String, lyrics: String, position: Int16)] = []
	private var tags: [Tag] = []
	private var delaySheetAimation = 0.0
	private var isFirstTime = true
	private var multiplier: CGFloat = 4/3
	private var sheetSize = CGSize(width: 375, height: 281)
	private var sheetPreviewView = SheetView()
	private var selectedTag: Tag? {
		didSet { update() }
	}
	private var sheetMode = false
	
	private var isCollectionviewSheetsHidden = true {
		didSet { update() }
	}
	
	
	
	// MARK: - Functions
	
	// MARK: UIViewController Functions
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		update()
	}
	
	
	
	// MARK: UITableViewDelegate Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return tempSheetsBeforeSaving.count + Constants.songTitleSheet
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
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
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return indexPath.section == 0 ? 70 : 220
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if section == 0 {
			return Text.NewSong.SongTitle
		} else {
			return Text.NewSong.Sheet + "\(section)"
		}
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		if collectionView == collectionViewSheets {
			return tempSheetsBeforeSaving.count
		} else {
			return 1
		}
	}
	
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == collectionViewSheets {
			return 1
		} else {
			return tags.count
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if collectionView == collectionViewSheets {
			
			let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.sheetCollectionCell, for: indexPath)
			
			if let collectionCell = collectionCell as? SheetCollectionCell {
				collectionCell.setPreviewViewAspectRatioConstraint(multiplier: multiplier)
				
				let view = buildSheetViewFor(title: clusterTitle, sheet: tempSheetsBeforeSaving[indexPath.section], tag: selectedTag, frame: collectionCell.bounds)
				collectionCell.previewView.addSubview(view)
				
				if isFirstTime {
					
					collectionCell.bounds = CGRect(x: -self.view.bounds.width, y: CGFloat(indexPath.section * Int(sheetSize.height)), width: collectionCell.bounds.width, height: collectionCell.bounds.height)
					UIView.animate(withDuration: 0.5, delay: delaySheetAimation, usingSpringWithDamping: 0.4, initialSpringVelocity: 9, options: .curveEaseInOut, animations: {
						collectionCell.bounds = CGRect(x: 0  , y: CGFloat(indexPath.section * Int(self.sheetSize.height)), width: collectionCell.bounds.width, height: collectionCell.bounds.height)
					})
					delaySheetAimation += 0.1
				}
			}
			let navigationBarHeight = UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height
			let tagBarHeight = self.collectionView.bounds.height
			if indexPath.section == Int(round(Double((UIScreen.main.bounds.height - navigationBarHeight - tagBarHeight) / (sheetSize.height + 10)))) - 1 {
				isFirstTime = false
			}
			return collectionCell
			
			
		} else {
			let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.tagCellCollection, for: indexPath)
			
			if let collectionCell = collectionCell as? TagCellCollection {
				collectionCell.setup(tagName: tags[indexPath.row].title ?? "")
				collectionCell.isSelectedCell = selectedTag?.id == tags[indexPath.row].id
			}
			return collectionCell
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView != collectionViewSheets {
			if selectedTag?.id == tags[indexPath.row].id {
				selectedTag = nil
			} else {
				selectedTag = tags[indexPath.row]
			}
			update()
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == collectionViewSheets {
			return sheetSize
		} else {
			return CGSize(width: 200, height: 50)
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
		
		collectionView.register(UINib(nibName: Cells.tagCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.tagCellCollection)
		navigationController?.title = Text.NewSong.title
		title = Text.Players.title

		cancel.title = Text.Actions.cancel
		done.title = Text.Actions.done
		
		collectionViewSheets.register(UINib(nibName: Cells.sheetCollectionCell, bundle: nil), forCellWithReuseIdentifier: Cells.sheetCollectionCell)
		multiplier = externalDisplayWindowRatioHeightWidth
		let cellHeight = multiplier * (UIScreen.main.bounds.width - 20)
		sheetSize = CGSize(width: UIScreen.main.bounds.width - 20, height: cellHeight)

		sheetPreviewView = buildSheetViewFor(title: "", sheet: (title: "", lyrics: "", position: Int16(0)), tag: selectedTag, frame: CGRect(x: 0, y: 0, width: sheetSize.width, height: sheetSize.height))
		
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
		layout.itemSize = sheetSize
		layout.minimumInteritemSpacing = 30
		layout.minimumLineSpacing = 0
		collectionViewSheets!.collectionViewLayout = layout
		
		isCollectionviewSheetsHidden = true
	}
	
	private func update() {
		// TODO: uncomment
		tags = CoreTag.getEntities()
		collectionView.reloadData()
		collectionViewSheets.reloadData()
		isFirstTime = true
		collectionViewSheets.isHidden = isCollectionviewSheetsHidden
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
	
	private func buildSheetViewFor(title: String?, sheet: (title: String, lyrics: String, position: Int16), tag: Tag?, displayToBeamer: Bool = false, frame: CGRect) -> SheetView {
		let defaults = UserDefaults.standard
		let view = SheetView(frame: frame)
		view.isEmptySheet = false
		view.selectedTag = tag
		view.songTitle = title
		view.lyrics = sheet.lyrics
		view.isEditable = true
		if let heightExternalDisplay = defaults.object(forKey: "externalDisplayWindowHeight") as? CGFloat {
			view.scaleFactor = heightExternalDisplay / (frame.size.height * UIScreen.main.scale)
		}
		view.update()
		return view
	}
	
	private func sheetViewFor(indexPath: IndexPath) -> UIView {
		sheetPreviewView.titleLabel.text = clusterTitle
		sheetPreviewView.lyrics = sheets[indexPath.row].lyrics
		sheetPreviewView.update()
		return sheetPreviewView
	}
	
	private func hasTagSelected() -> Bool {
		if selectedTag != nil {
			return true
		} else {
			let alert = UIAlertController(title: Text.NewSong.errorTitleNoTag, message: Text.NewSong.erorrMessageNoTag, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: Text.Actions.ok, style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: nil)

			return false
		}
	}
	
	// MARK: - IBAction Functions
	
	@IBAction func cancel(_ sender: UIBarButtonItem) {
		
		if !sheetMode {
			dismiss(animated: true)
		} else {
			sheetMode = false
			tempSheetsBeforeSaving = []
		}
		isFirstTime = true
		isCollectionviewSheetsHidden = true
		
	}
	
	@IBAction func done(_ sender: UIBarButtonItem) {
		if sheetMode {
			if hasTagSelected() {
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
			}
		} else {
			textView.resignFirstResponder()
			isCollectionviewSheetsHidden = false
			sheetMode = true
			buildSheets(fromText: textView.text)
			
			update()
		}
	}

	
	
}
