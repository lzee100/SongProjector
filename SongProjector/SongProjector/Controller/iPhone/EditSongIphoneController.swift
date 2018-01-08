//
//  EditSongIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//


import UIKit

class EditSongIphoneController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	// MARK: - Types
	struct Constants {
		static let songTitleSheet = 1
	}
	
	@IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var edit: UIBarButtonItem!
	@IBOutlet var save: UIBarButtonItem!
	
	@IBOutlet var collectionView: UICollectionView!
	
	@IBOutlet var textView: UITextView!
	@IBOutlet var collectionViewSheets: UICollectionView!
	
	
	
	// MARK: - Properties
	
	var cluster: Cluster?
	
	private var isSetup = true
	private var clusterTitle: String?
	private var sheets: [Sheet] = []
	private var tags: [Tag] = []
	private var delaySheetAimation = 0.0
	private var isFirstTime = true {
		willSet { if newValue == true { delaySheetAimation = 0.0 } }
	}
	private var multiplier: CGFloat = 4/3
	private var sheetSize = CGSize(width: 375, height: 281)
	private var sheetPreviewView = SheetView()
	private var selectedTag: Tag? {
		didSet { update() }
	}
	private var textMode = false
	private var madeChanges = false
	private var doneMode = false
	
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
	}
	
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		if collectionView == collectionViewSheets {
			return sheets.count > 0 ? sheets.count : cluster?.hasSheets?.count ?? 0
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
				
				for subview in collectionCell.previewView.subviews {
					subview.removeFromSuperview()
				}
				let sheet = sheets.count > 0 ? sheets[indexPath.section] : cluster?.hasSheetsArray[indexPath.section]
				let view = buildSheetViewFor(sheet: sheet, frame: collectionCell.bounds)
				collectionCell.previewView.addSubview(view)
				
				if isFirstTime {
					let y = collectionCell.bounds.minY
					collectionCell.bounds = CGRect(
						x: -self.view.bounds.width,
						y: y,
						width: collectionCell.bounds.width,
						height: collectionCell.bounds.height)
					
					UIView.animate(withDuration: 0.4, delay: delaySheetAimation, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
						
						collectionCell.bounds = CGRect(
							x: 0,
							y: y,
							width: collectionCell.bounds.width,
							height: collectionCell.bounds.height)
						
					})
					delaySheetAimation += 0.12
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
			if selectedTag?.id != tags[indexPath.row].id {
				selectedTag = tags[indexPath.row]
				save.title = Text.Actions.save
				madeChanges = true
				update()
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == collectionViewSheets {
			return sheetSize
		} else {
			return CGSize(width: 200, height: 50)
		}
	}
	
	
	
	
	// MARK: - Private Functions
	
	private func setup() {
		tags = CoreTag.getEntities()
		
		collectionView.register(UINib(nibName: Cells.tagCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.tagCellCollection)
		collectionViewSheets.register(UINib(nibName: Cells.sheetCollectionCell, bundle: nil), forCellWithReuseIdentifier: Cells.sheetCollectionCell)
		navigationController?.title = Text.NewSong.title
		title = Text.Players.title
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
		NotificationCenter.default.addObserver(forName: Notification.Name.UIScreenDidConnect, object: nil, queue: nil, using: databaseDidChange)

		cancel.title = Text.Actions.cancel
		edit.title = Text.Actions.edit
		save.title = Text.Actions.done
		
		multiplier = externalDisplayWindowRatio
		let cellHeight = multiplier * (UIScreen.main.bounds.width - 20)
		sheetSize = CGSize(width: UIScreen.main.bounds.width - 20, height: cellHeight)
		
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
		layout.itemSize = sheetSize
		layout.minimumInteritemSpacing = 30
		layout.minimumLineSpacing = 0
		collectionViewSheets!.collectionViewLayout = layout
		
		textView.contentSize = CGSize(width: textView.bounds.width, height: UIScreen.main.bounds.height * 2)
		textView.keyboardDismissMode = .interactive
		
		isCollectionviewSheetsHidden = false
		selectedTag = cluster?.hasTag
		update()
	}
	
	private func update() {
		// TODO: uncomment
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
			
			let newSheet = CoreSheet.createEntityNOTsave()
			newSheet.title = sheetTitle
			newSheet.lyrics = sheetLyrics
			newSheet.position = position
			
			sheets.append(newSheet)
			
			lyricsToDevide.removeSubrange(rangeRemove)
			position += 1
		}
		
		sheets.sort{ $0.position < $1.position }
		
	}
	
	private func buildSheetViewFor(sheet: Sheet?, frame: CGRect) -> SheetView {
		let view = SheetView(frame: frame)
		view.isEmptySheet = false
		view.selectedTag =  selectedTag ?? cluster?.hasTag
		view.songTitle = clusterTitle ?? cluster?.title
		view.lyrics = sheet?.lyrics
		view.position = Int(sheet?.position ?? 0)
		view.isEditable = true
		view.update()
		return view
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
	
	private func databaseDidChange(_ notification: Notification) {
		tags = CoreTag.getEntities()
		update()
	}
	
	private func getTextFromSheets() -> String {
		var totalString = (cluster?.title ?? "") + "\n\n"
		let tempSheets:[Sheet] = sheets.count > 0 ? sheets : cluster?.hasSheetsArray ?? []
		for (index, sheet) in tempSheets.enumerated() {
			totalString += sheet.lyrics ?? ""
			if index < tempSheets.count {
				totalString +=  "\n\n"
			}
		}
		return totalString
	}
	
	// MARK: - IBAction Functions
	
	@IBAction func cancel(_ sender: UIBarButtonItem) {
		
		if !textMode {
			dismiss(animated: true)
		} else {
			isSetup = true
			textMode = !textMode
			isFirstTime = true
			isCollectionviewSheetsHidden = false
			edit.tintColor = .primary
			edit.isEnabled = true
			save.title = Text.Actions.done
		}
		
	}
	
	@IBAction func edit(_ sender: UIBarButtonItem) {
		isCollectionviewSheetsHidden = true
		textView.text = getTextFromSheets()
		madeChanges = true
		isSetup = true
		isFirstTime = true
		textMode = !textMode
		edit.isEnabled = false
		edit.tintColor = .clear
		save.title = Text.Actions.done
	}
	
	
	@IBAction func save(_ sender: UIBarButtonItem) {
		if textMode {
			// edit mode
			isCollectionviewSheetsHidden = false
			buildSheets(fromText: textView.text)
			madeChanges = true
			isSetup = true
			isFirstTime = true
			textMode = !textMode
			edit.isEnabled = true
			edit.tintColor = .primary
			save.title = madeChanges ? Text.Actions.save : Text.Actions.done
		} else {
			// sheet mode
			if !madeChanges {
				dismiss(animated: true)
			} else {
				save.isEnabled = true
				textMode = true
				// save
				if let cluster = cluster {
					cluster.title = clusterTitle ?? cluster.title
					if CoreCluster.saveContext() { print("song saved") } else { print("song not saved") }
					
					if sheets.count > 0 { // if made changes to text // else made changes to tag
						
						if let sheets = cluster.hasSheets as? Set<Sheet> {
							for sheet in sheets {
								let _ = CoreSheet.delete(entity: sheet)
							}
						}
						
						for tempSheet in sheets {
							let sheet = CoreSheet.createEntity()
							sheet.title = tempSheet.title
							sheet.lyrics = tempSheet.lyrics
							sheet.position = tempSheet.position
							sheet.hasCluster = cluster
							cluster.addToHasSheets(sheet)
						}
						
						if CoreSheet.saveContext() { print("sheets saved") } else { print("sheets not saved") }
						
					}
					cluster.hasTag = selectedTag
					if CoreTag.saveContext() { print("tag saved") } else { print("tag not saved") }
					
					//dismiss
					dismiss(animated: true)
				}
			}
			
		}
	}
	
	@objc func keyboardWillShow(notification:NSNotification){
		
		var userInfo = notification.userInfo!
		var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
		keyboardFrame = self.view.convert(keyboardFrame, from: nil)
		
		var contentInset:UIEdgeInsets = self.textView.contentInset
		contentInset.bottom = keyboardFrame.size.height + 30
		textView.contentInset = contentInset
	}
	
	@objc func keyboardWillHide(notification:NSNotification){
		
		let contentInset:UIEdgeInsets = UIEdgeInsets.zero
		textView.contentInset = contentInset
	}
	
}

