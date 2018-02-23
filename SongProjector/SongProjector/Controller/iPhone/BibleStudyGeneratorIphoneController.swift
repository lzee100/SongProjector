//
//  BibleStudyGeneratorIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

protocol BibleStudyGeneratorIphoneDelegate {
	func didFinishGeneratorWith(_ sheets: [Sheet])
}

class BibleStudyGeneratorIphoneController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
	
	@IBOutlet var saveButton: UIBarButtonItem!
	@IBOutlet var segmentControl: UISegmentedControl!
	@IBOutlet var collectionViewTags: UICollectionView!
	@IBOutlet var textView: UITextView!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var collectionViewSheets: UICollectionView!
	@IBOutlet var emptyView: UIView!
	

	var selectedTag: Tag?
	var delegate: BibleStudyGeneratorIphoneDelegate?
	
	// MARK: Private properties
	private var sheets: [Sheet] = []
	private var tags: [Tag] = []
	private var visibleCells: [IndexPath] = []
	private var sheetsSorted: [Sheet] { return sheets.sorted { $0.position < $1.position } }
	private var delaySheetAimation = 0.0
	private var multiplier: CGFloat = 9/16
	private var sheetSize = CGSize(width: 375, height: 281)
	private var isFirstTime = true
	
	
	// MARK: - UIViewController Functions
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setup()
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
		let fullName = BibleIndex(searchText: sheets[indexPath.row].title).getFullName()
		cell.setup(title: fullName ?? sheets[indexPath.row].title ?? "", textColor: fullName != nil ? UIColor.green : UIColor.red)
		cell.textLabel?.textColor = fullName != nil ? UIColor.green : UIColor.red
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 40
	}
	
	
	// MARK: - UICollectionView Functions
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return sheets.count
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == collectionViewTags {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.tagCellCollection, for: indexPath) as! TagCellCollection
			return cell
		} else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.sheetCollectionCell, for: indexPath) as! SheetCollectionCell
			return cell
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == collectionViewTags {
			return CGSize(width: 200, height: 50)
		} else {
			return sheetSize
		}
	}
	
	
	// MARK: - Private Functions

	private func setup() {
		
		saveButton.title = Text.Actions.save
		
		navigationController?.title = Text.CustomSheets.title
		title = Text.CustomSheets.title
		view.backgroundColor = themeWhiteBlackBackground
		emptyView.backgroundColor = themeWhiteBlackBackground
		hideKeyboardWhenTappedAround()
		
		collectionViewSheets.register(UINib(nibName: Cells.sheetCollectionCell, bundle: nil), forCellWithReuseIdentifier: Cells.sheetCollectionCell)
		collectionViewTags.register(UINib(nibName: Cells.tagCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.tagCellCollection)
		
		tableView.register(cell: Cells.basicCellid)
		tableView.keyboardDismissMode = .interactive
		
		CoreTag.predicates.append("isHidden", notEquals: true)
		tags = CoreTag.getEntities()
		
		textView.backgroundColor = themeWhiteBlackBackground
		textView.textColor = themeWhiteBlackTextColor
		textView.layer.borderColor = themeHighlighted.cgColor
		textView.layer.borderWidth = 1
		textView.layer.cornerRadius = CGFloat(5.0)
		textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10)
		textView.setNeedsLayout()
		textView.setNeedsDisplay()
		
		segmentControl.setTitle(Text.CustomSheets.segmentInput, forSegmentAt: 0)
		segmentControl.setTitle(Text.CustomSheets.segmentCheck, forSegmentAt: 1)
		segmentControl.setTitle(Text.CustomSheets.segmentSheets, forSegmentAt: 2)
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
		
		let cellHeight = multiplier * (UIScreen.main.bounds.width - 20)
		sheetSize = CGSize(width: UIScreen.main.bounds.width - 20, height: cellHeight)
		
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
		collectionViewTags.reloadData()
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
	
	private func setViewFor(collectionCell: UICollectionViewCell, sheet: Sheet) {
		
		if let collectionCell = collectionCell as? SheetCollectionCell {
			
			collectionCell.setPreviewViewAspectRatioConstraint(multiplier: multiplier)
			
			for subview in collectionCell.previewView.subviews {
				subview.removeFromSuperview()
			}
			
			var view = UIView()
			switch sheet.type {
			case .SheetTitleContent:
				view = SheetTitleContent.createWith(frame: collectionCell.bounds, title: sheet.title, sheet: sheet as? SheetTitleContentEntity, tag: sheet.hasTag)
			case .SheetTitleImage:
				view = SheetTitleImage.createWith(frame: collectionCell.bounds, sheet: sheet as! SheetTitleImageEntity, tag: sheet.hasTag)
			case .SheetSplit:
				view = SheetSplit.createWith(frame: collectionCell.bounds, sheet: sheet as! SheetSplitEntity, tag: sheet.hasTag)
			case .SheetEmpty:
				view = SheetEmpty.createWith(frame: collectionCell.bounds, tag: sheet.hasTag)
			case .SheetActivities:
				print("Sheet Activities biblestudygeneratoriphonecontroller")
				break
			}
			
			collectionCell.previewView.addSubview(view)
			
		}
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
	
	@objc private func editTableView(_ gestureRecognizer: UIGestureRecognizer) {
		if let gestureRecognizer = gestureRecognizer as? UILongPressGestureRecognizer {
			if gestureRecognizer.state == UIGestureRecognizerState.began {
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
		
		for sheet in sheets {
			sheet.delete()
		}
		sheets = []
		var position: Int16 = 0

		// get titles
		while let range = inputText.range(of: "\n") {
			let start = inputText.index(inputText.startIndex, offsetBy: 0)
			let rangeSheet = start..<range.lowerBound
			let rangeRemove = start..<range.upperBound
			let sheet = CoreSheet.createEntity()
			sheet.isTemp = true
			sheet.title = String(inputText[rangeSheet])
			sheet.position = position
			sheets.append(sheet)
			position += 1
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
			
			view.bringSubview(toFront: textView)
			textView.isHidden = false
			
			collectionViewSheets.isHidden = true
			view.sendSubview(toBack: collectionViewSheets)

			tableView.isHidden = true
			view.sendSubview(toBack: tableView)
			
		} else if sender.selectedSegmentIndex == 1 {
			
			generateSheets()
			
			isFirstTime = true
			visibleCells = collectionViewSheets.indexPathsForVisibleItems

			textView.isHidden = true
			textView.resignFirstResponder()
			view.sendSubview(toBack: textView)
			
			tableView.isHidden = false
			view.bringSubview(toFront: tableView)
			
			collectionViewSheets.isHidden = true
			view.sendSubview(toBack: collectionViewSheets)
			
			update()
			
		} else {
			
			textView.isHidden = true
			textView.resignFirstResponder()
			view.sendSubview(toBack: textView)
			
			tableView.isHidden = true
			view.sendSubview(toBack: tableView)
			
			collectionViewSheets.isHidden = false
			view.bringSubview(toFront: collectionViewSheets)

			update()
			isFirstTime = false
		}
		
	}
}
