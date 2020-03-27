//
//  NewSongIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit
import CoreData

class NewSongIphoneController: ChurchBeamViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
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
	
	var cluster: VCluster?
	var sheets: [VSheetTitleContent] = []
	var editExistingCluster = false
	
	private var isSetup = true
	private var themes: [VTheme] = []
	private var delaySheetAimation = 0.0
	private var isFirstTime = true {
		willSet { if newValue == true { delaySheetAimation = 0.0 } }
	}
	private var visibleCells: [IndexPath] = []
	private var multiplier = externalDisplayWindowRatio
	private var sheetSize = CGSize(width: 375, height: 281)
	private var selectedTheme: VTheme? {
		didSet { update() }
	}
	private var sheetMode = false
	
	private var isCollectionviewSheetsHidden = true
		
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
			return themes.count
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if collectionView == collectionViewSheets {
			
			let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.sheetCollectionCell, for: indexPath)
			if let collectionCell = collectionCell as? SheetCollectionCell {
				collectionCell.setupWith(cluster: cluster, sheet: sheets[indexPath.section], theme: selectedTheme ?? cluster?.hasTheme, didDeleteSheet: nil, isDeleteEnabled: false)
				
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
			let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.themeCellCollection, for: indexPath)
			
			if let collectionCell = collectionCell as? ThemeCellCollection {
				collectionCell.setup(themeName: themes[indexPath.row].title ?? "")
				collectionCell.isSelectedCell = selectedTheme?.id == themes[indexPath.row].id
			}
			return collectionCell
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
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == collectionViewSheets {
			return getSizeWith(width: collectionViewSheets.frame.width)
		} else {
			return CGSize(width: 200, height: 50)
		}
	}
	
	// MARK: - Private Functions
	
	private func setup() {
		CoreTheme.predicates.append("isHidden", notEquals: true)
		themes = VTheme.list(sortOn: "position", ascending: true)
		
		if cluster == nil {
			cluster = VCluster()
		}

		collectionView.register(UINib(nibName: Cells.themeCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.themeCellCollection)
		collectionViewSheets.register(UINib(nibName: Cells.sheetCollectionCell, bundle: nil), forCellWithReuseIdentifier: Cells.sheetCollectionCell)
		NotificationCenter.default.addObserver(forName: UIScreen.didConnectNotification, object: nil, queue: nil, using: databaseDidChange)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		
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
			selectedTheme = cluster?.hasTheme
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
		selectedTheme = nil
		CoreTheme.predicates.append("isHidden", notEquals: true)
		themes = VTheme.list(sortOn: "position", ascending: true)
		update()
	}
	
	private func buildSheets(fromText: String) {
		sheets = []
		var contentToDevide = fromText + "\n\n"
		
		// get title
		if let range = contentToDevide.range(of: "\n\n") {
			let start = contentToDevide.index(contentToDevide.startIndex, offsetBy: 0)
			let rangeSheet = start..<range.lowerBound
			let rangeRemove = start..<range.upperBound
			cluster?.title = String(contentToDevide[rangeSheet])
			contentToDevide.removeSubrange(rangeRemove)
		}
		
		var position = 0
		// get sheets
		while let range = contentToDevide.range(of: "\n\n") {
			
			// get content
			let start = contentToDevide.index(contentToDevide.startIndex, offsetBy: 0)
			let rangeSheet = start..<range.lowerBound
			let rangeRemove = start..<range.upperBound
			
			let sheetcontent = String(contentToDevide[rangeSheet])
			var sheetTitle: String = Text.NewSong.NoTitleForSheet
			
			// get title
			if let rangeTitle = contentToDevide.range(of: "\n") {
				let startTitle = contentToDevide.index(contentToDevide.startIndex, offsetBy: 0)
				let rangeSheetTitle = startTitle..<rangeTitle.lowerBound
				sheetTitle = String(contentToDevide[rangeSheetTitle])
			}
			
			let newSheet = VSheetTitleContent()
			newSheet.title = sheetTitle
			newSheet.content = sheetcontent
			newSheet.position = position
			
			sheets.append(newSheet)
			
			contentToDevide.removeSubrange(rangeRemove)
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
	
	private func hasThemeSelected() -> Bool {
		if selectedTheme != nil {
			return true
		} else {
			let alert = UIAlertController(title: Text.NewSong.errorTitleNoTheme, message: Text.NewSong.erorrMessageNoTheme, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: Text.Actions.ok, style: UIAlertAction.Style.default, handler: nil))
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
		let tempSheets:[VSheetTitleContent] = sheets.count > 0 ? sheets : cluster?.hasSheets as? [VSheetTitleContent] ?? []
		for (index, sheet) in tempSheets.enumerated() {
			totalString += sheet.content ?? ""
			if index < tempSheets.count - 1 { // add only \n\n to second last, not the last one, or it will add empty sheet
				totalString +=  "\n\n"
			}
		}
		return totalString
	}

	
	// MARK: - IBAction Functions
	
	@IBAction func cancel(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
	
	@IBAction func done(_ sender: UIBarButtonItem) {
		
		if hasThemeSelected() {
			
			buildSheets(fromText: textView.text)
			
			if let themeId = selectedTheme?.id {
				cluster?.themeId = themeId
			}
			
			if let cluster = cluster {
				NSManagedObjectContext.saveForeground(vEntity: cluster, success: {
					Queues.main.async {
						self.dismiss(animated: true)
					}
				}) { (error) in
					Queues.main.async {
						self.show(message: error.localizedDescription)
					}
				}
			} else {
				Queues.main.async {
					self.dismiss(animated: true)
				}
			}
		}
	}
	
	@IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
		if sender.selectedSegmentIndex == 1 {
			isSetup = false
			isCollectionviewSheetsHidden = false
			textView.resignFirstResponder()
			buildSheets(fromText: textView.text)
			view.bringSubviewToFront(collectionViewSheets)
			update()
		} else {
			isSetup = true
			visibleCells = collectionViewSheets.indexPathsForVisibleItems
			sheets = []
			isFirstTime = true
			isCollectionviewSheetsHidden = true
			view.sendSubviewToBack(collectionViewSheets)
			update()
		}
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	@objc func keyboardWillShow(notification:NSNotification){
		
		let userInfo = notification.userInfo!
		var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
		keyboardFrame = self.view.convert(keyboardFrame, from: nil)
		
		var contentInset:UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		contentInset.bottom = keyboardFrame.size.height + 30
		textView.contentInset = contentInset
	}
	
	@objc func keyboardWillHide(notification:NSNotification){
		
		let contentInset:UIEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		textView.contentInset = contentInset
	}
	
}


