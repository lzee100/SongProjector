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
	@IBOutlet var textView: UITextView!
	@IBOutlet var collectionViewSheets: UICollectionView!
	
	// MARK: - Properties
	
	private var isSetup = true
	private var clusterTitle = ""
	private var sheets: [SheetTitleContentEntity] = []
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
				
				let view = SheetTitleContent.createSheetTitleTextWith(frame: collectionCell.bounds, title: clusterTitle, sheet: sheets[indexPath.section], tag: selectedTag)
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

		collectionView.register(UINib(nibName: Cells.tagCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.tagCellCollection)
		collectionViewSheets.register(UINib(nibName: Cells.sheetCollectionCell, bundle: nil), forCellWithReuseIdentifier: Cells.sheetCollectionCell)
		NotificationCenter.default.addObserver(forName: Notification.Name.UIScreenDidConnect, object: nil, queue: nil, using: databaseDidChange)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
		
		navigationController?.title = Text.NewSong.title
		title = Text.Players.title

		cancel.title = Text.Actions.cancel
		done.title = Text.Actions.save
		
		view.backgroundColor = themeWhiteBlackBackground
		textView.backgroundColor = themeWhiteBlackBackground
		textView.textColor = themeWhiteBlackTextColor
		textView.layer.borderColor = themeHighlighted.cgColor
		textView.layer.borderWidth = 1
		textView.layer.cornerRadius = CGFloat(5.0)
		textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)

		
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
		
		isCollectionviewSheetsHidden = true
	}
	
	private func update() {
		// TODO: uncomment
		collectionView.reloadData()
		collectionViewSheets.reloadData()
		isFirstTime = true
		collectionViewSheets.isHidden = isCollectionviewSheetsHidden
	}
	
	private func databaseDidChange(_ notification: Notification) {
		selectedTag = nil
		tags = CoreTag.getEntities()
		update()
	}
	
	private func buildSheets(fromText: String) {
		
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
	
//	private func buildSheetViewFor(sheet: Sheet?, frame: CGRect, isSetup: Bool = false) -> SheetView {
//		let view = SheetView(frame: frame)
//		view.isEmptySheet = false
//		view.selectedTag =  selectedTag
//		view.songTitle = clusterTitle
//		view.position = Int(sheet?.position ?? 0)
//		if isSetup {
//			view.lyrics = ""
//		} else {
//			view.lyrics = sheet?.lyrics
//		}
//		view.isEditable = true
//		view.update()
//		return view
//	}
	
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

	
	// MARK: - IBAction Functions
	
	@IBAction func cancel(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
	
	@IBAction func done(_ sender: UIBarButtonItem) {
		if hasTagSelected() {
			let cluster = CoreCluster.createEntity()
			cluster.title = clusterTitle
			let id = Int(cluster.id)
			cluster.position = Int16(id)
			if CoreCluster.saveContext() { print("song saved") } else { print("song not saved") }
			
			for tempSheet in sheets {
				let sheet = CoreSheetTitleContent.createEntity()
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
	}
	
	@IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
		if sender.selectedSegmentIndex == 1 {
			isSetup = false
			isCollectionviewSheetsHidden = false
			textView.resignFirstResponder()
			buildSheets(fromText: textView.text)
			update()
		} else {
			isSetup = true
			visibleCells = collectionViewSheets.indexPathsForVisibleItems
			sheets = []
			isFirstTime = true
			isCollectionviewSheetsHidden = true
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
	

	
}
