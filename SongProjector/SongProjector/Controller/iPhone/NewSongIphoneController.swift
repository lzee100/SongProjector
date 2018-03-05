//
//  NewSongIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

class NewSongIphoneController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	// MARK: - Types
	struct Constants {
		static let songTitleSheet = 1
	}
	
	@IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var done: UIBarButtonItem!
	
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var segmentControl: UISegmentedControl!
	@IBOutlet var textViewContainer: UIView!
	@IBOutlet var textView: UITextView!
	@IBOutlet var collectionViewSheets: UICollectionView!
	
	// MARK: - Properties
	
	var cluster: Cluster?
	var sheets: [SheetTitleContentEntity] = []
	var editExistingCluster = false
	
	private var isSetup = true
	private var tags: [Tag] = []
	private var delaySheetAimation = 0.0
	private var isFirstTime = true {
		willSet { if newValue == true { delaySheetAimation = 0.0 } }
	}
	private var visibleCells: [IndexPath] = []
	private var multiplier = externalDisplayWindowRatio
	private var sheetSize = CGSize(width: 375, height: 281)
	private var selectedTag: Tag? {
		didSet { update() }
	}
	private var sheetMode = false
	
	private var isCollectionviewSheetsHidden = true
	
	private var hasBible = false
	
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
			return sheets.count
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
				
				let view = SheetTitleContent.createWith(frame: collectionCell.bounds, title: cluster?.title, sheet: sheets[indexPath.section], tag: selectedTag ?? cluster?.hasTag)
				collectionCell.previewView.addSubview(view)
				
				if visibleCells.contains(indexPath) {
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
			
			if let index = visibleCells.index(of: indexPath), segmentControl.selectedSegmentIndex == 1 {
				visibleCells.remove(at: index) // remove cell for one time animation
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
		CoreTag.predicates.append("isHidden", notEquals: true)
		tags = CoreTag.getEntities()
		
		if cluster == nil {
			cluster = CoreCluster.createEntity()
		}

		collectionView.register(UINib(nibName: Cells.tagCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.tagCellCollection)
		collectionViewSheets.register(UINib(nibName: Cells.sheetCollectionCell, bundle: nil), forCellWithReuseIdentifier: Cells.sheetCollectionCell)
		NotificationCenter.default.addObserver(forName: Notification.Name.UIScreenDidConnect, object: nil, queue: nil, using: databaseDidChange)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		navigationController?.title = Text.NewSong.title
		title = Text.CustomSheets.title
		textViewContainer.layer.borderColor = themeHighlighted.cgColor
		
		cancel.title = Text.Actions.cancel
		done.title = Text.Actions.save
		
		view.backgroundColor = themeWhiteBlackBackground
		textView.backgroundColor = themeWhiteBlackBackground
		textView.textColor = themeWhiteBlackTextColor
		
		segmentControl.setTitle(Text.NewSong.segmentTitleText, forSegmentAt: 0)
		segmentControl.setTitle(Text.NewSong.segmentTitleSheets, forSegmentAt: 1)
		
		let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		
		leftSwipe.direction = .left
		rightSwipe.direction = .right
		
		textView.addGestureRecognizer(leftSwipe)
		collectionViewSheets.addGestureRecognizer(rightSwipe)
		
		let cellHeight = multiplier * (UIScreen.main.bounds.width - 20)
		sheetSize = CGSize(width: UIScreen.main.bounds.width - 20, height: cellHeight)

		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
		layout.itemSize = sheetSize
		layout.minimumInteritemSpacing = 30
		layout.minimumLineSpacing = 0
		collectionViewSheets!.collectionViewLayout = layout
		
		textView.keyboardDismissMode = .interactive
		
		visibleCells = getMaxVisiblecells()
		if editExistingCluster {
			textView.text = getTextFromSheets()
			segmentControl.selectedSegmentIndex = 1
			selectedTag = cluster?.hasTag
		} else {
			isCollectionviewSheetsHidden = true
			segmentControl.selectedSegmentIndex = 0
			segmentControlValueChanged(segmentControl)
		}
	}
	
	private func update() {
		collectionView.reloadData()
		collectionViewSheets.reloadData()
		isFirstTime = true
	}
	
	private func databaseDidChange(_ notification: Notification) {
		selectedTag = nil
		CoreTag.predicates.append("isHidden", notEquals: true)
		tags = CoreTag.getEntities()
		update()
	}
	
	private func buildSheets(fromText: String) {
		sheets = []
		var lyricsToDevide = fromText + "\n\n"
		
		// get title
		if let range = lyricsToDevide.range(of: "\n\n") {
			let start = lyricsToDevide.index(lyricsToDevide.startIndex, offsetBy: 0)
			let rangeSheet = start..<range.lowerBound
			let rangeRemove = start..<range.upperBound
			cluster?.title = String(lyricsToDevide[rangeSheet])
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
			
			let newSheet = CoreSheetTitleContent.createEntityNOTsave()
			newSheet.title = sheetTitle
			newSheet.lyrics = sheetLyrics
			newSheet.position = position
			
			sheets.append(newSheet)
			
			lyricsToDevide.removeSubrange(rangeRemove)
			position += 1
		}
		
		sheets.sort{ $0.position < $1.position }
		
	}
	
	private func getMaxVisiblecells() -> [IndexPath] {
		
		let completeCellsVisible = Int(collectionViewSheets.bounds.height / sheetSize.height)
		let remainder = collectionViewSheets.bounds.height.truncatingRemainder(dividingBy: sheetSize.height)
		let remainderInt = remainder > 0 ? 1 : 0
		let sum = completeCellsVisible + remainderInt
		var indexPaths: [IndexPath] = []
		for index in 0..<sum {
			indexPaths.append(IndexPath(row: 0, section: index))
		}
		
		let tooMuchCells = (indexPaths.count - sheets.count)
		
		if tooMuchCells > 0 {
			for _ in 0..<tooMuchCells {
				indexPaths.removeLast()
			}
		}
		
		return indexPaths
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
	
	@objc private func respondToSwipeGesture(_ swipe: UISwipeGestureRecognizer) {
		swipe.cancelsTouchesInView = false
		if swipe.direction == .left {
			segmentControl.selectedSegmentIndex = 1
			segmentControlValueChanged(segmentControl)
		} else if swipe.direction == .right {
			segmentControl.selectedSegmentIndex = 0
			segmentControlValueChanged(segmentControl)
		}
	}
	
	private func getTextFromSheets() -> String {
		var totalString = (cluster?.title ?? "") + "\n\n"
		let tempSheets:[SheetTitleContentEntity] = sheets.count > 0 ? sheets : cluster?.hasSheetsArray as? [SheetTitleContentEntity] ?? []
		for (index, sheet) in tempSheets.enumerated() {
			totalString += sheet.lyrics ?? ""
			if index < tempSheets.count - 1 { // add only \n\n to second last, not the last one, or it will add empty sheet
				totalString +=  "\n\n"
			}
		}
		return totalString
	}

	
	// MARK: - IBAction Functions
	
	@IBAction func cancel(_ sender: UIBarButtonItem) {
		if !editExistingCluster, let cluster = cluster {
			let _ = CoreCluster.delete(entity: cluster)
		}
		dismiss(animated: true)
	}
	
	@IBAction func done(_ sender: UIBarButtonItem) {
		if !hasBible {
			generateBible()
			hasBible = !hasBible
			return
		}
		
		if hasTagSelected() {
			
			buildSheets(fromText: textView.text)

			// if existing cluster, remove current sheets
			CoreCluster.predicates.append("id", equals: cluster?.id)
			let results = CoreCluster.getEntities()
			if results.count != 0, let cluster = cluster {
				for sheet in cluster.hasSheetsArray {
					sheet.delete()
				}
			}
			
			for tempSheet in sheets {
				let sheet = CoreSheetTitleContent.createEntity()
				sheet.title = tempSheet.title
				sheet.lyrics = tempSheet.lyrics
				sheet.position = tempSheet.position
				sheet.hasCluster = cluster
				sheets.append(sheet)
			}
			
			if CoreSheet.saveContext() { print("sheets saved") } else { print("sheets not saved") }
			
			cluster?.hasTag = selectedTag
			if CoreTag.saveContext() { print("tag saved") } else { print("tag not saved") }
		}
		dismiss(animated: true)
	}
	
	@IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
		if sender.selectedSegmentIndex == 1 {
			isSetup = false
			isCollectionviewSheetsHidden = false
			textView.resignFirstResponder()
			buildSheets(fromText: textView.text)
			view.bringSubview(toFront: collectionViewSheets)
			update()
		} else {
			isSetup = true
			visibleCells = collectionViewSheets.indexPathsForVisibleItems
			sheets = []
			isFirstTime = true
			isCollectionviewSheetsHidden = true
			view.sendSubview(toBack: collectionViewSheets)
			update()
		}
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	@objc func keyboardWillShow(notification:NSNotification){
		
		var userInfo = notification.userInfo!
		var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
		keyboardFrame = self.view.convert(keyboardFrame, from: nil)
		
		var contentInset:UIEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
		contentInset.bottom = keyboardFrame.size.height + 30
		textView.contentInset = contentInset
	}
	
	@objc func keyboardWillHide(notification:NSNotification){
		
		let contentInset:UIEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
		textView.contentInset = contentInset
	}
	
	
	private func generateBible() {
		
		for book in CoreBook.getEntities() {
			CoreBook.delete(entity: book)
		}
		for chapter in CoreChapter.getEntities() {
			CoreChapter.delete(entity: chapter)
		}
		for vers in CoreVers.getEntities() {
			CoreVers.delete(entity: vers)
		}
		
		var hasNextBook = true
		var hasNextChapter = true
		var bookNumber = 0
		var chapterNumber: Int16 = 1
		var versNumber: Int16 = 1
		var versString = "\(1)"
		
		var nextVersNumber: Int16 = versNumber + 1
		var nextVersString = "\(nextVersNumber)"
		
		var text = textView.text ?? ""
		
		
		// find book range
		while let bookRange = text.range(of: "xxx") {
			
			let book = CoreBook.createEntity()
			book.name = BibleIndex.getBookFor(index: bookNumber)
			
			// get all text in book
			let start = text.index(text.startIndex, offsetBy: 0)
			let rangeBook = start..<bookRange.upperBound
			var bookText = String(text[rangeBook]).trimmingCharacters(in: .whitespacesAndNewlines)
			
			text.removeSubrange(rangeBook)
			
			// find chapter range
			while let chapterRange = bookText.range(of: "hhh") {
				
				// prepare chapter
				let chapter = CoreChapter.createEntity()
				chapter.number = chapterNumber
				CoreChapter.saveContext()
				
				print("chapter\(chapterNumber)")
				// get all text in book
				let start = bookText.index(bookText.startIndex, offsetBy: 0)
				let rangeChapter = start..<chapterRange.upperBound
				var chapterText = String(bookText[rangeChapter]).trimmingCharacters(in: .whitespacesAndNewlines)
				
				// remove text from total
				bookText.removeSubrange(rangeChapter)
				
				while let range = chapterText.range(of: nextVersString) {
					let start = text.index(text.startIndex, offsetBy: 0)
					let rangeVers = start..<range.lowerBound
					let rangeRemove = start..<range.upperBound
					
					let vers = CoreVers.createEntity()
					vers.number = versNumber
					vers.text = String(chapterText[rangeVers]).trimmingCharacters(in: .whitespacesAndNewlines)
					vers.hasChapter = chapter
					CoreVers.saveContext()
					chapterText.removeSubrange(rangeRemove)
					
					versNumber += 1
					versString = "\(versNumber)"
					
					nextVersNumber = versNumber + 1
					nextVersString = "\(nextVersNumber)"
					
				}
				
				if chapterText.contains("hhh") {
					if let range = chapterText.range(of: "hhh") {
						chapterText.removeSubrange(range)
					}
					
				}
				if chapterText.contains("xxx") {
					if let range = chapterText.range(of: "xxx") {
						bookText.removeSubrange(range)
					}
				}
				
				let vers = CoreVers.createEntity()
				vers.number = versNumber
				vers.text = chapterText.trimmingCharacters(in: .whitespacesAndNewlines)
				vers.hasChapter = chapter
				CoreVers.saveContext()
				chapterText.removeAll()
				
				chapter.hasBook = book
				CoreChapter.saveContext()
				print(chapterNumber)
				chapterNumber += 1
				
				versNumber = 1
				versString = "\(versNumber)"
				
			}
			
			
			bookText = text.trimmingCharacters(in: .whitespacesAndNewlines)
			bookNumber += 1
			
		}
		
		CoreChapter.predicates.append("hasBook.name", equals: "Genesis")
		print(CoreChapter.getEntities().count)
		CoreChapter.predicates.append("hasBook.name", equals: "Exodus")
		print(CoreChapter.getEntities().count)
		
	}

	
}


