////
////  NewSongController.swift
////  SongViewer
////
////  Created by Leo van der Zee on 06-12-17.
////  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
////
//
//import UIKit
//import CoreData
//
//class NewSongController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//
//	// MARK: - Types
//	struct Constants {
//		static let songTitleSheet = 1
//	}
//	
//
//
//	// MARK: - Properties
//
//	@IBOutlet var cancel: UIBarButtonItem!
//	@IBOutlet var done: UIBarButtonItem!
//	@IBOutlet var inputTextView: UITextView!
//	@IBOutlet var generateSheetsButton: UIButton!
//	@IBOutlet var collectionViewTags: UICollectionView!
//	@IBOutlet var collectionViewSheets: UICollectionView!
//	@IBOutlet var textViewContainerView: UIView!
//
//
//	// MARK: - Properties
//
//	var cluster: Cluster?
//	var sheets: [SheetTitleContentEntity] = []
//	var editExistingCluster = false
//
//	private var isSetup = true
//	private var clusterTitle: String?
//	private var tags: [Tag] = []
//	private var visibleCells: [IndexPath] = []
//	private var delaySheetAimation = 0.0
//	private var isFirstTime = true {
//		willSet { if newValue == true { delaySheetAimation = 0.0 } }
//	}
//	private var multiplier: CGFloat = 4/3
//	private var sheetSize = CGSize(width: 375, height: 281)
//	private var sheetPreviewView = SheetView()
//	private var selectedTag: Tag? {
//		didSet { update() }
//	}
//
//	private var isCollectionviewSheetsHidden = true {
//		didSet { update() }
//	}
//
//
//
//	// MARK: - Functions
//
//	// MARK: UIViewController Functions
//
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		setup()
//	}
//
//	func numberOfSections(in collectionView: UICollectionView) -> Int {
//		if collectionView == collectionViewSheets {
//			return sheets.count > 0 ? sheets.count : cluster?.hasSheets?.count ?? 0
//		} else {
//			return 1
//		}
//	}
//
//
//	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//		if collectionView == collectionViewSheets {
//			return 1
//		} else {
//			return tags.count
//		}
//	}
//
//	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//		if collectionView == collectionViewSheets {
//
//			let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.sheetCollectionCell, for: indexPath)
//			if let collectionCell = collectionCell as? SheetCollectionCell {
//				collectionCell.setPreviewViewAspectRatioConstraint(multiplier: multiplier)
//
//				for subview in collectionCell.previewView.subviews {
//					subview.removeFromSuperview()
//				}
//				if let sheet = sheets.count > 0 ? sheets[indexPath.section] : cluster?.hasSheetsArray[indexPath.section] as? VSheetTitleContent {
//					let view = SheetView.createWith(frame: collectionCell.bounds, cluster: cluster, sheet: sheet, tag: selectedTag ?? cluster?.hasTag)
//				collectionCell.previewView.addSubview(view)
//				}
//
//				if visibleCells.contains(indexPath) { // is cell was visible to user, animate
//					let y = collectionCell.bounds.minY
//					collectionCell.bounds = CGRect(
//						x: -self.view.bounds.width,
//						y: y,
//						width: collectionCell.bounds.width,
//						height: collectionCell.bounds.height)
//
//					UIView.animate(withDuration: 0.4, delay: delaySheetAimation, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
//
//						collectionCell.bounds = CGRect(
//							x: 0,
//							y: y,
//							width: collectionCell.bounds.width,
//							height: collectionCell.bounds.height)
//
//					})
//					delaySheetAimation += 0.12
//				}
//				if let index = visibleCells.index(of: indexPath) {
//					visibleCells.remove(at: index) // remove cell for one time animation
//				}
//			}
//			return collectionCell
//
//
//		} else {
//			let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.tagCellCollection, for: indexPath)
//
//			if let collectionCell = collectionCell as? TagCellCollection {
//				collectionCell.setup(tagName: tags[indexPath.row].title ?? "")
//				collectionCell.isSelectedCell = selectedTag?.id == tags[indexPath.row].id
//			}
//			return collectionCell
//		}
//	}
//
//	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//		if collectionView != collectionViewSheets {
//			if selectedTag?.id != tags[indexPath.row].id {
//				selectedTag = tags[indexPath.row]
//				done.title = Text.Actions.save
//				update()
//			}
//		}
//	}
//
//	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//		if collectionView == collectionViewSheets {
//			return sheetSize
//		} else {
//			return CGSize(width: 200, height: 50)
//		}
//	}
//
//
//
//	// MARK: - Private Functions
//
//	private func setup() {
//		CoreTag.predicates.append("isHidden", notEquals: true)
//		tags = CoreTag.getEntities()
//
//		if cluster == nil {
//			cluster = VCluster()
//			cluster?.isTemp = true
//		} else {
//			inputTextView.text = getTextFromSheets()
//			buildSheets(fromText: getTextFromSheets())
//		}
//
//		view.backgroundColor = themeWhiteBlackBackground
//		inputTextView.textColor = themeWhiteBlackTextColor
//		generateSheetsButton.tintColor = themeHighlighted
//		generateSheetsButton.backgroundColor = .darkGray
//		generateSheetsButton.layer.cornerRadius = 5
//		generateSheetsButton.setTitle(Text.NewSong.generateSheetsButton, for: .normal)
//
//		textViewContainerView.layer.borderWidth = 2
//		textViewContainerView.layer.borderColor = themeHighlighted.cgColor
//		textViewContainerView.layer.cornerRadius = 5
//
//		collectionViewTags.register(UINib(nibName: Cells.tagCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.tagCellCollection)
//		collectionViewSheets.register(UINib(nibName: Cells.sheetCollectionCell, bundle: nil), forCellWithReuseIdentifier: Cells.sheetCollectionCell)
//		navigationController?.title = Text.NewSong.title
//		title = Text.CustomSheets.title
//
//		NotificationCenter.default.addObserver(forName: Notification.Name.UIScreenDidConnect, object: nil, queue: nil, using: databaseDidChange)
//
//		cancel.title = Text.Actions.cancel
//		done.title = Text.Actions.save
//
//		multiplier = externalDisplayWindowRatio
//		let cellHeight = multiplier * (collectionViewSheets.bounds.width - 20)
//		sheetSize = CGSize(width: collectionViewSheets.bounds.width - 20, height: cellHeight)
//
//		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//		layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
//		layout.itemSize = sheetSize
//		layout.minimumInteritemSpacing = 30
//		layout.minimumLineSpacing = 0
//		collectionViewSheets!.collectionViewLayout = layout
//
//		inputTextView.keyboardDismissMode = .interactive
//
//		isCollectionviewSheetsHidden = false
//		selectedTag = cluster?.hasTag
//
//		update()
//	}
//
//	private func update() {
//		// TODO: uncomment
//		collectionViewTags.reloadData()
//		collectionViewSheets.reloadData()
//		isFirstTime = true
//		collectionViewSheets.isHidden = isCollectionviewSheetsHidden
//	}
//
//
//	private func buildSheets(fromText: String) {
//		sheets = []
//		var lyricsToDevide = fromText + "\n\n"
//
//		// get title
//		if let range = lyricsToDevide.range(of: "\n\n") {
//			let start = lyricsToDevide.index(lyricsToDevide.startIndex, offsetBy: 0)
//			let rangeSheet = start..<range.lowerBound
//			let rangeRemove = start..<range.upperBound
//			clusterTitle = String(lyricsToDevide[rangeSheet])
//			lyricsToDevide.removeSubrange(rangeRemove)
//		}
//
//		var position: Int16 = 0
//		// get sheets
//		while let range = lyricsToDevide.range(of: "\n\n") {
//
//			// get lyrics
//			let start = lyricsToDevide.index(lyricsToDevide.startIndex, offsetBy: 0)
//			let rangeSheet = start..<range.lowerBound
//			let rangeRemove = start..<range.upperBound
//
//			let sheetLyrics = String(lyricsToDevide[rangeSheet])
//			var sheetTitle: String = Text.NewSong.NoTitleForSheet
//
//			// get title
//			if let rangeTitle = lyricsToDevide.range(of: "\n") {
//				let startTitle = lyricsToDevide.index(lyricsToDevide.startIndex, offsetBy: 0)
//				let rangeSheetTitle = startTitle..<rangeTitle.lowerBound
//				sheetTitle = String(lyricsToDevide[rangeSheetTitle])
//			}
//
//			let newSheet = CoreSheetTitleContent.createEntityNOTsave()
//			newSheet.title = sheetTitle
//			newSheet.lyrics = sheetLyrics
//			newSheet.position = position
//
//			sheets.append(newSheet)
//
//			lyricsToDevide.removeSubrange(rangeRemove)
//			position += 1
//		}
//
//		sheets.sort{ $0.position < $1.position }
//
//	}
//
//	private func hasTagSelected() -> Bool {
//		if selectedTag != nil {
//			return true
//		} else {
//			let alert = UIAlertController(title: Text.NewSong.errorTitleNoTag, message: Text.NewSong.erorrMessageNoTag, preferredStyle: .alert)
//			alert.addAction(UIAlertAction(title: Text.Actions.ok, style: UIAlertActionStyle.default, handler: nil))
//			self.present(alert, animated: true, completion: nil)
//
//			return false
//		}
//	}
//
//	private func databaseDidChange(_ notification: Notification) {
//		selectedTag = nil
//		tags = CoreTag.getEntities()
//		update()
//	}
//
//	private func getTextFromSheets() -> String {
//		var totalString = (cluster?.title ?? "") + "\n\n"
//		let tempSheets:[SheetTitleContentEntity] = sheets.count > 0 ? sheets : cluster?.hasSheetsArray as? [SheetTitleContentEntity] ?? []
//		for (index, sheet) in tempSheets.enumerated() {
//			totalString += sheet.lyrics ?? ""
//			if index < tempSheets.count - 1 { // add only \n\n to second last, not the last one, or it will add empty sheet
//				totalString +=  "\n\n"
//			}
//		}
//		return totalString
//	}
//
//	// MARK: - IBAction Functions
//
//	@IBAction func generateSheets(_ sender: UIButton) {
//		buildSheets(fromText: inputTextView.text)
//		collectionViewSheets.reloadData()
//	}
//
//	@IBAction func cancel(_ sender: UIBarButtonItem) {
//		if let cluster = cluster {
//			if !cluster.isTemp {
//				managedObjectContext.rollback()
//			} else {
//				cluster.delete()
//			}
//		}
//		self.dismiss(animated: true)
//	}
//
//
//	@IBAction func save(_ sender: UIBarButtonItem) {
//		if let cluster = cluster {
//
//			cluster.title = clusterTitle ?? cluster.title
//			cluster.isTemp = false
//			if sheets.count > 0 { // if made changes to text // else made changes to tag
//
//				if let sheets = cluster.hasSheets as? Set<Sheet> {
//					for sheet in sheets {
//						let _ = CoreSheet.delete(entity: sheet)
//					}
//				}
//
//				for tempSheet in sheets {
//					let sheet = CoreSheetTitleContent.createEntity()
//					sheet.title = tempSheet.title
//					sheet.lyrics = tempSheet.lyrics
//					sheet.position = tempSheet.position
//					sheet.hasCluster = cluster
//					cluster.addToHasSheets(sheet)
//				}
//
//				if CoreSheet.saveContext() { print("sheets saved") } else { print("sheets not saved") }
//
//			}
//			cluster.hasTag = selectedTag
//			if CoreTag.saveContext() { print("tag saved") } else { print("tag not saved") }
//
//			//dismiss
//			self.dismiss(animated: true)
//
//		}
//	}
//
//}
