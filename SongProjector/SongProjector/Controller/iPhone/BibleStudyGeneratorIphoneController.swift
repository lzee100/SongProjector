//
//  BibleStudyGeneratorIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

protocol BibleStudyGeneratorIphoneDelegate {
	func didFinishGeneratorWith(_ sheets: [VSheet])
}

class BibleStudyGeneratorIphoneController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
	
	@IBOutlet var textViewContainerView: UIView!
	@IBOutlet var saveButton: UIBarButtonItem!
	@IBOutlet var segmentControl: UISegmentedControl!
	@IBOutlet var collectionViewThemes: UICollectionView!
	@IBOutlet var textView: UITextView!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var collectionViewSheets: UICollectionView!
	@IBOutlet var emptyView: UIView!
	

	var selectedTheme: VTheme?
	var delegate: BibleStudyGeneratorIphoneDelegate?
	
	// MARK: Private properties
	private var sheets: [VSheet] = []
	private var themes: [VTheme] = []
	private var visibleCells: [IndexPath] = []
	private var sheetsSorted: [VSheet] { return sheets.sorted { $0.position < $1.position } }
	private var delaySheetAimation = 0.0
	private var multiplier: CGFloat = externalDisplayWindowRatio
	private var sheetSize = CGSize(width: 375, height: 281)
	private var isFirstTime = true
	private var needsReload = false
	private var scaleFactor: CGFloat { get { return externalDisplayWindowWidth / sheetSize.width } }
	private var addEmptySheet = true
	var position: Int = 0
	
	private var testImage: UIImage?
	
	// MARK: - UIViewController Functions
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setup()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		update()
	}
	
	// MARK: - UITableView Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sheets.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath) as! BasicCell
		let fullName = BibleIndexx(searchText: sheets[indexPath.row].title).getFullName()
		cell.setup(title: fullName ?? sheets[indexPath.row].title ?? "", textColor: (fullName != nil && (sheets[indexPath.row] as! VSheetTitleContent).content != "") ? UIColor.green : UIColor.red)
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 40
	}
	
	
	// MARK: - UICollectionView Functions
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return collectionView == collectionViewSheets ? sheets.count : 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionView == collectionViewSheets ? 1 : themes.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == collectionViewThemes {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.themeCellCollection, for: indexPath) as! ThemeCellCollection
			cell.setup(themeName: themes[indexPath.row].title ?? "")
			cell.isSelectedCell = themes[indexPath.row].id == selectedTheme?.id
			return cell
		} else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.sheetCollectionCell, for: indexPath) as! SheetCollectionCell
			cell.setupWith(cluster: nil, sheet: sheetsSorted[indexPath.section], theme: selectedTheme, didDeleteSheet: nil)
			return cell
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == collectionViewThemes {
			return CGSize(width: 200, height: 50)
		} else {
			return getSizeWith(height: collectionView.frame.height)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView != collectionViewSheets {
			if selectedTheme?.id != themes[indexPath.row].id {
				selectedTheme = themes[indexPath.row]
				update()
			}
		}
	}
	
	
	// MARK: - Private Functions

	private func setup() {
		
		saveButton.title = AppText.Actions.save
		
		navigationController?.title = AppText.CustomSheets.title
		title = AppText.CustomSheets.title
		view.backgroundColor = themeWhiteBlackBackground
		emptyView.backgroundColor = themeWhiteBlackBackground
		
		hideKeyboardWhenTappedAround()
		textViewContainerView.layer.borderColor = themeHighlighted.cgColor
		collectionViewSheets.register(UINib(nibName: Cells.sheetCollectionCell, bundle: nil), forCellWithReuseIdentifier: Cells.sheetCollectionCell)
		collectionViewThemes.register(UINib(nibName: Cells.themeCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.themeCellCollection)
		
		NotificationCenter.default.addObserver(forName: .externalDisplayDidChange, object: nil, queue: nil, using: externalDisplayDidChange)
		
		tableView.register(cell: Cells.basicCellid)
		tableView.keyboardDismissMode = .interactive
		
//        let themes: [Theme] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "position", ascending: true))
//        self.themes = themes.map({ VTheme(theme: $0, context: moc) })
		
		setSheetSize()

		textView.backgroundColor = themeWhiteBlackBackground
		textView.textColor = .blackColor
		
		segmentControl.setTitle(AppText.CustomSheets.segmentInput, forSegmentAt: 0)
		segmentControl.setTitle(AppText.CustomSheets.segmentCheck, forSegmentAt: 1)
		segmentControl.setTitle(AppText.CustomSheets.segmentSheets, forSegmentAt: 2)
		segmentControl.selectedSegmentIndex = 0
		
		
		let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		
		leftSwipe.direction = .left
		rightSwipe.direction = .right
		
		view.addGestureRecognizer(leftSwipe)
		view.addGestureRecognizer(rightSwipe)
		
		let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		longPressGesture.minimumPressDuration = 0.7
		longPressGesture.delegate = self
		self.tableView.addGestureRecognizer(longPressGesture)
		
		let doubleTab = UITapGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		doubleTab.numberOfTapsRequired = 2
		view.addGestureRecognizer(doubleTab)
		
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
		layout.itemSize = sheetSize
		layout.minimumInteritemSpacing = 30
		layout.minimumLineSpacing = 0
		collectionViewSheets!.collectionViewLayout = layout
		
		visibleCells = getMaxVisiblecells()
		
		update()
	}
	
	private func update() {
        var predicates: [NSPredicate] = [.skipDeleted]
		predicates.append("isHidden", equals: 0)
//        let themes: [Theme] = DataFetcher().getEntities(moc: moc, predicates: predicates, sort: NSSortDescriptor(key: "position", ascending: true))
//        self.themes = themes.map({ VTheme(theme: $0, context: moc) })
		collectionViewThemes.reloadData()
		collectionViewSheets.reloadData()
		tableView.reloadData()
		isFirstTime = true
	}
	
	private func getMaxVisiblecells() -> [IndexPath] {
		
		let completeCellsVisible = Int(tableView.bounds.height / sheetSize.height)
		let remainder = tableView.bounds.height.truncatingRemainder(dividingBy: sheetSize.height)
		let remainderInt = remainder > 0 ? 1 : 0
		let sum = completeCellsVisible + remainderInt
		var indexPaths: [IndexPath] = []
		for index in 0..<sum {
			indexPaths.append(IndexPath(row: 0, section: index + 1))
		}
		
		let tooMuchCells = (indexPaths.count - sheets.count)
		
		if tooMuchCells > 0 {
			for _ in 0..<tooMuchCells {
				indexPaths.removeLast()
			}
		}
		
		return indexPaths
	}
	
	@objc private func respondToSwipeGesture(_ swipe: UISwipeGestureRecognizer) {
		
		swipe.cancelsTouchesInView = false
		if swipe.direction == .left {
			if segmentControl.selectedSegmentIndex < 3 {
				segmentControl.selectedSegmentIndex = segmentControl.selectedSegmentIndex + 1
				valueChanged(segmentControl)
			}
		} else if swipe.direction == .right {
			if segmentControl.selectedSegmentIndex > 0 {
			segmentControl.selectedSegmentIndex = segmentControl.selectedSegmentIndex - 1
			valueChanged(segmentControl)
			}
		}
		
	}
	
	private func hasThemeSelected() -> Bool {
		if selectedTheme != nil {
			return true
		} else {
			let alert = UIAlertController(title: AppText.NewSong.errorTitleNoTheme, message: AppText.NewSong.erorrMessageNoTheme, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: AppText.Actions.ok, style: UIAlertAction.Style.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
			
			return false
		}
	}
	
	@objc private func editTableView(_ gestureRecognizer: UIGestureRecognizer) {
		if let gestureRecognizer = gestureRecognizer as? UILongPressGestureRecognizer {
			if gestureRecognizer.state == UIGestureRecognizer.State.began {
				changeEditingState()
			}
		} // for double tab
		else if let _ = gestureRecognizer as? UITapGestureRecognizer, tableView.isEditing {
			changeEditingState()
		}
	}
	
	private func changeEditingState(_ onlyIfEditing: Bool? = nil) {
		if let _ = onlyIfEditing {
			if tableView.isEditing {
				tableView.setEditing(false, animated: false)
			}
		} else {
			tableView.setEditing(tableView.isEditing ? false : true, animated: false)
		}
	}
	
	private func generateSheets() {
		
		var inputText = textView.text + "\n"
		
		sheets = []

		// get titles
		while let range = inputText.range(of: "\n") {
			let start = inputText.index(inputText.startIndex, offsetBy: 0)
			let rangeSheet = start..<range.lowerBound
			let rangeRemove = start..<range.upperBound

			let verses = BibleIndex.getVersesFor(searchValue: String(inputText[rangeSheet]) ).0
			let initialTextLength = BibleIndex.getVersesFor(searchValue:  String(inputText[rangeSheet]) ).1
			
			if let fontSize = selectedTheme?.contentTextSize, let verses = verses {
				var expodential = 1
				
				if Int(fontSize) > 10 {
					expodential = (Int(fontSize) % 10) + 1
				} else if Int(fontSize) % 10 == 0 {
					expodential = 1
				} else {
					expodential = -(10 - Int(fontSize) % 10)
				}
				
				let factor = externalDisplayWindowWidth < 1000 ? 2.0 : 1.3
				
				var sum: CGFloat = 0
				if expodential > 0 {
					sum = CGFloat(fontSize) * CGFloat((factor * Double(expodential)))
				} else {
					var expodentialMinus: Double = 1
					switch expodential {
					case -1:
						expodentialMinus = 0.5
					case -2:
						expodentialMinus = 0.6
					case -3:
						expodentialMinus = 0.8
					default:
						expodentialMinus = 0.9
					}
					sum = CGFloat(fontSize) / CGFloat(abs(expodentialMinus))
				}
				let maxCharactersSheet = 8000 / sum
				
				buildAllSheetWith(title: String(inputText[rangeSheet]), verses: verses, initialTextLength: initialTextLength, maxTextLenght: Int(maxCharactersSheet))

			}
			
		
			
			inputText.removeSubrange(rangeRemove)
		}
		
		sheets.sort{ $0.position < $1.position }
		
	}
	
	private func isInputValid(searchInput: String) {
		
	}
	
	@IBAction func saveBibleStudy(_ sender: UIBarButtonItem) {
		
	}
	@IBAction func valueChanged(_ sender: UISegmentedControl) {
		
		if sender.selectedSegmentIndex == 0 {
			
			isFirstTime = true
			visibleCells = collectionViewSheets.indexPathsForVisibleItems
			
			view.bringSubviewToFront(textView)
			textView.isHidden = false
			
			collectionViewSheets.isHidden = true
			view.sendSubviewToBack(collectionViewSheets)

			tableView.isHidden = true
			view.sendSubviewToBack(tableView)
			
		} else if sender.selectedSegmentIndex == 1 {
			
			generateSheets()
			
			isFirstTime = true
			visibleCells = collectionViewSheets.indexPathsForVisibleItems

			textView.isHidden = true
			textView.resignFirstResponder()
			view.sendSubviewToBack(textView)
			
			tableView.isHidden = false
			view.bringSubviewToFront(tableView)
			
			collectionViewSheets.isHidden = true
			view.sendSubviewToBack(collectionViewSheets)
			
			update()
			
		} else {
			
			textView.isHidden = true
			textView.resignFirstResponder()
			view.sendSubviewToBack(textView)
			
			tableView.isHidden = true
			view.sendSubviewToBack(tableView)
			
			collectionViewSheets.isHidden = false
			view.bringSubviewToFront(collectionViewSheets)

			update()
			isFirstTime = false
		}
		
	}
	
	private func buildAllSheetWith(title: String, verses: [Vers], initialTextLength: Int, maxTextLenght: Int) {
		
		var remainderVerses = verses
		
		let titleSpace = 40
		let spaceTitle = (selectedTheme?.allHaveTitle ?? false) ? 40 : 0
		
		if initialTextLength < (maxTextLenght - titleSpace) {
			let sheet = VSheetTitleContent()
			sheet.deleteDate = NSDate()
			sheet.title = title
			sheet.content = getTextFor(verses: verses)
			sheet.position = position
			position += 1
			sheets.append(sheet)
			remainderVerses.removeAll()
		}
		
		
		while getTextLengthFor(verses: remainderVerses) > (maxTextLenght - spaceTitle) {
			
			let sheet = VSheetTitleContent()
			sheet.deleteDate = NSDate()
			sheet.title = title
			
			var totalTextLenght = 0
			var versesForThisSheet: [Vers] = []
			while totalTextLenght < maxTextLenght, let nextVers = remainderVerses.first {
				totalTextLenght += getTextLengthFor(verses: [nextVers])
				versesForThisSheet.append(nextVers)
				remainderVerses.remove(at: 0)
			}
			
			sheet.content = getTextFor(verses: versesForThisSheet)
			sheet.position = position
			position += 1
			sheets.append(sheet)
			
		}
		
		if remainderVerses.count > 0 {
			let sheet = VSheetTitleContent()
			sheet.deleteDate = NSDate()
			sheet.title = title
			sheet.content = getTextFor(verses: remainderVerses)
			sheet.position = position
			position += 1
			sheets.append(sheet)
			remainderVerses.removeAll()
		}
		
		if addEmptySheet {
			let sheet = VSheetTitleContent()
			sheet.deleteDate = NSDate()
			sheet.position = position
			position += 1
			sheets.append(sheet)
			remainderVerses.removeAll()
		}
		
		
		
	}
	
	private func getTextFor(verses: [Vers]) -> String {
		var totalString = ""
		verses.forEach({ totalString += "\($0.number) \( $0.text!) " })
		return totalString
	}
	
	private func getTextLengthFor(verses: [Vers]) -> Int {
		var lenght = 0
		let allLengths = verses.compactMap({ $0.text?.length })
		allLengths.forEach{ lenght += $0 }
		return lenght
	}
	
	private func externalDisplayDidChange(notification: Notification) {
		setSheetSize()
	}
	
	private func setSheetSize() {
		multiplier = externalDisplayWindowRatio
		let cellWidth =  200  / multiplier
		sheetSize = CGSize(width: cellWidth, height: 200)
		collectionViewSheets.reloadData()
	}
	
}
