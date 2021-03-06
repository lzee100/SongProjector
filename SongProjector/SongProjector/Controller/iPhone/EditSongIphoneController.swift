//
//  EditSongIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 06-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//


import UIKit
import CoreData

class EditSongIphoneController: ChurchBeamViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	// MARK: - Types
	struct Constants {
		static let songTitleSheet = 1
	}
	
	@IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var save: UIBarButtonItem!
	
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var segmentControl: UISegmentedControl!
	
	@IBOutlet var textView: UITextView!
	@IBOutlet var collectionViewSheets: UICollectionView!
	
	
	
	// MARK: - Properties
	
	var cluster: VCluster?
	var sheets: [VSheetTitleContent] = []

	private var isSetup = true
	private var clusterTitle: String?
	private var themes: [VTheme] = []
	private var visibleCells: [IndexPath] = []
	private var delaySheetAimation = 0.0
	private var isFirstTime = true {
		willSet { if newValue == true { delaySheetAimation = 0.0 } }
	}
	private var multiplier: CGFloat = 4/3
	private var sheetSize = CGSize(width: 375, height: 281)
	private var sheetPreviewView = SheetView()
	private var selectedTheme: VTheme? {
		didSet { update() }
	}
	
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
			return sheets.count > 0 ? sheets.count : cluster?.hasSheets.count ?? 0
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
				if let sheet = sheets.count > 0 ? sheets[indexPath.section] : cluster?.hasSheets[indexPath.section] as? VSheetTitleContent {
					collectionCell.setupWith(cluster: cluster, sheet: sheet, theme: selectedTheme ?? cluster?.hasTheme(moc: moc), didDeleteSheet: nil, isDeleteEnabled: true)
				}
				
				if visibleCells.contains(indexPath) { // is cell was visible to user, animate
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
				if let index = visibleCells.firstIndex(of: indexPath), segmentControl.selectedSegmentIndex == 1 {
					visibleCells.remove(at: index) // remove cell for one time animation
				}
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
				save.title = AppText.Actions.save
				update()
			}
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == collectionViewSheets {
			return getSizeWith(height: nil, width: collectionViewSheets.frame.width)
		} else {
			return CGSize(width: 200, height: 50)
		}
	}
	
	
	
	// MARK: - Private Functions
	
	private func setup() {
        let themes: [Theme] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "position", ascending: true))
            
        self.themes = themes.map({ VTheme(theme: $0, context: moc) })
		
		view.backgroundColor = themeWhiteBlackBackground
		textView.backgroundColor = themeWhiteBlackBackground
		textView.textColor = .blackColor
		
		collectionView.register(UINib(nibName: Cells.themeCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.themeCellCollection)
		collectionViewSheets.register(UINib(nibName: Cells.sheetCollectionCell, bundle: nil), forCellWithReuseIdentifier: Cells.sheetCollectionCell)
		navigationController?.title = AppText.NewSong.title
		title = AppText.CustomSheets.title
		
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		NotificationCenter.default.addObserver(forName: UIScreen.didConnectNotification, object: nil, queue: nil, using: databaseDidChange)
		
		segmentControl.setTitle(AppText.NewSong.segmentTitleText, forSegmentAt: 0)
		segmentControl.setTitle(AppText.NewSong.segmentTitleSheets, forSegmentAt: 1)
		segmentControl.selectedSegmentIndex = 1
		
		let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		
		leftSwipe.direction = .left
		rightSwipe.direction = .right
		
		textView.layer.borderColor = themeHighlighted.cgColor
		textView.layer.borderWidth = 1
		textView.layer.cornerRadius = CGFloat(5.0)
		textView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		
		textView.addGestureRecognizer(leftSwipe)
		collectionViewSheets.addGestureRecognizer(rightSwipe)

		cancel.title = AppText.Actions.cancel
		save.title = AppText.Actions.save
		
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
		selectedTheme = cluster?.hasTheme(moc: moc)
		
//		visibleCells = getMaxVisiblecells()

		update()
	}
	
	override func update() {
		// TODO: uncomment
		collectionView.reloadData()
		collectionViewSheets.reloadData()
		isFirstTime = true
		collectionViewSheets.isHidden = isCollectionviewSheetsHidden
	}
	
	
	private func buildSheets(fromText: String) {
		
		var contentToDevide = fromText + "\n\n"
		
		// get title
		if let range = contentToDevide.range(of: "\n\n") {
			let start = contentToDevide.index(contentToDevide.startIndex, offsetBy: 0)
			let rangeSheet = start..<range.lowerBound
			let rangeRemove = start..<range.upperBound
			clusterTitle = String(contentToDevide[rangeSheet])
			contentToDevide.removeSubrange(rangeRemove)
		}
		
		var position = 0
		// get sheets
		while let range = contentToDevide.range(of: "\n\n") {
			
			// get content
			let start = contentToDevide.index(contentToDevide.startIndex, offsetBy: 0)
			let rangeSheet = start..<range.lowerBound
			let rangeRemove = start..<range.upperBound
			
			let sheetLyrics = String(contentToDevide[rangeSheet])
			var sheetTitle: String = AppText.NewSong.NoTitleForSheet
			
			// get title
			if let rangeTitle = contentToDevide.range(of: "\n") {
				let startTitle = contentToDevide.index(contentToDevide.startIndex, offsetBy: 0)
				let rangeSheetTitle = startTitle..<rangeTitle.lowerBound
				sheetTitle = String(contentToDevide[rangeSheetTitle])
			}
			
			let newSheet = VSheetTitleContent()
			newSheet.title = sheetTitle
			newSheet.content = sheetLyrics
			newSheet.position = position
			
			sheets.append(newSheet)
			
			contentToDevide.removeSubrange(rangeRemove)
			position += 1
		}
		
		sheets.sort{ $0.position < $1.position }
		
	}
	
//	private func buildSheetViewFor(sheet: Sheet?, frame: CGRect) -> SheetView {
//		let view = SheetView(frame: frame)
//		view.isEmptySheet = false
//		view.selectedTheme =  selectedTheme ?? cluster?.hasTheme
//		view.songTitle = clusterTitle ?? cluster?.title
//		view.content = sheet?.content
//		view.position = Int(sheet?.position ?? 0)
//		view.isEditable = true
//		view.update()
//		return view
//	}
	
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
	
	private func databaseDidChange(_ notification: Notification) {
		selectedTheme = nil
        let themes: [Theme] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "position", ascending: true))
        self.themes = themes.map({ VTheme(theme: $0, context: moc) })
		update()
	}
	
	private func getTextFromSheets() -> String {
		var totalString = (cluster?.title ?? "") + "\n\n"
		let currentSheets = cluster?.hasSheets as? [VSheetTitleContent] ?? []
		let tempSheets:[VSheetTitleContent] = sheets.count > 0 ? sheets : currentSheets
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
	
	
	@IBAction func save(_ sender: UIBarButtonItem) {
		if let cluster = cluster {
			cluster.title = clusterTitle ?? cluster.title
			
			if let themeId = selectedTheme?.id {
				cluster.themeId = themeId
			}
		}
        self.dismiss(animated: true)
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
			textView.text = getTextFromSheets()
			sheets = []
			isFirstTime = true
			isCollectionviewSheetsHidden = true
		}
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

