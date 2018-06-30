//
//  CustomSheetsController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10-02-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit


class CustomSheetsController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, NewOrEditIphoneControllerDelegate {
	
	
	// MARK: - Properties
	
	@IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var save: UIBarButtonItem!
	
	@IBOutlet var collectionViewTags: UICollectionView!
	@IBOutlet var collectionView: UICollectionView!
	
	@IBOutlet var addLyricsButton: UIButton!
	@IBOutlet var addSheetButton: UIButton!
	
	
	
	var isNew = true
	var tags: [Tag] = []
	var selectedTag: Tag? {
		didSet {
			clusterTemp?.hasTag = selectedTag
			if clusterTemp?.isTypeSong ?? false {
				updateWithAnimation()
			}
		}
	}
	var isEdited = false
	
	var cluster: Cluster? {
		didSet {
			if let cluster = cluster {
				clusterTemp = cluster.tempVersion
				sheets = cluster.hasSheetsArray
			}
		}
	}
	var clusterTemp: Cluster?
	var sheets: [Sheet] = [] {
		didSet {
			sheetsTemp = []
			save.isEnabled = sheets.count > 0
			for (index, sheet) in sheets.enumerated() {
				sheet.position = Int16(index)
				let tempSheet = sheet.getTemp
				tempSheet.hasTag = sheet.hasTag
				sheetsTemp.append(tempSheet)
			}
		}
	}
	var sheetsTemp: [Sheet] = [] { didSet { sheetsTemp.sort(by: { $0.position < $1.position }) } }
	
	// MARK: Private properties
	private var sheetSize = CGSize(width: 250*externalDisplayWindowRatioHeightWidth, height: 250)
	private var longPressGesture: UILongPressGestureRecognizer!
	
	
	
	// MARK - UIView functions
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		update()
		
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let controller = segue.destination.unwrap() as? SheetPickerMenuController {
			controller.sender = self
			controller.selectedTag = selectedTag
		}
		
		if let controller = segue.destination.unwrap() as? LyricsViewController {
			controller.text = getTextFromSheets()
			controller.didPressDone = buildSheets(fromText:)
		}
		
		if let controller = segue.destination.unwrap() as? SaveNewSongTitleTimeVC {
			controller.didSave = didSaveSongWith
			controller.title = clusterTemp?.title ?? Text.NewSong.title
			controller.songTitle = clusterTemp?.title ?? ""
			controller.time = clusterTemp?.time ?? 0
			controller.selectedTag = selectedTag
		}
	}
	
	
	
	// MARK: - UICollectionView Functions
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionView == collectionViewTags ? tags.count : sheetsTemp.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if collectionView == collectionViewTags {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.tagCellCollection, for: indexPath) as! TagCellCollection
			
			cell.setup(tagName: tags[indexPath.row].title ?? "")
			cell.isSelectedCell = tags[indexPath.row] == selectedTag
			return cell
			
		} else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.sheetCollectionCell, for: indexPath) as! SheetCollectionCell
			cell.setupWith(
				cluster: clusterTemp,
				sheet: sheetsTemp[indexPath.row],
				tag: sheetsTemp[indexPath.row].hasTag ?? clusterTemp?.hasTag,
				didDeleteSheet: didDeleteSheet(sheet:))
			return cell
		}
		
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == collectionViewTags {
			if let cell = collectionView.cellForItem(at: indexPath) as? TagCellCollection {
				return CGSize(width: cell.preferredWidth, height: 50)
			} else {
				return CGSize(width: 200, height: 50)
			}
		} else {
			return getSizeWith(height: collectionView.frame.height)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == collectionViewTags {
			selectedTag = selectedTag == tags[indexPath.row] ? nil : tags[indexPath.row]
			update()
		} else if !(cluster?.isTypeSong ?? false){
			let sheet = sheetsTemp[indexPath.row]
			let controller = storyboard?.instantiateViewController(withIdentifier: "NewOrEditIphoneController") as! NewOrEditIphoneController
			controller.modificationMode = .editCustomSheet
			controller.sheet = sheet
			controller.delegate = self
			let nav = UINavigationController(rootViewController: controller)
			present(nav, animated: true)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let sourceItem = sheetsTemp[sourceIndexPath.row]
		sheetsTemp.remove(at: sourceIndexPath.row)
		sheetsTemp.insert(sourceItem, at: destinationIndexPath.row)
		collectionView.visibleCells.forEach { $0.layer.removeAllAnimations() }
	}
	
	
	
	// MARK: - Delegate Functions
	
	func didCreate(sheet: Sheet) {
		
		sheetsTemp.append(sheet)
		
		isEdited = true
		checkAddButton()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
			if let index = self.sheetsTemp.index(of: sheet) {
				self.collectionView.insertItems(at: [IndexPath(row: index, section: 0)])
			}
		}
	}
	
	
	
	// MARK: - Functions
	
	@objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
		
		switch(gesture.state) {
			
		case .began:
			guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
				break
			}
			collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
			collectionView.visibleCells.forEach { animate(cell: $0) }
		case .changed:
			collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
		case .ended:
			collectionView.visibleCells.forEach { $0.layer.removeAllAnimations() }
			collectionView.endInteractiveMovement()
		default:
			collectionView.visibleCells.forEach { $0.layer.removeAllAnimations() }
			collectionView.cancelInteractiveMovement()
		}
	}
	
	func didDeleteSheet(sheet: Sheet) {
		if let index = sheetsTemp.index(where: { $0 == sheet }) {
			sheetsTemp.delete(entity: sheet)
			collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
		}
	}
	
	func didSaveSongWith(title: String, time: Double) {
		var newCluster = clusterTemp ?? cluster
		if newCluster == nil {
			newCluster = CoreCluster.createEntity()
		}
		
		newCluster?.isTemp = false
		newCluster?.hasTag = selectedTag
		newCluster?.title = title
		newCluster?.time = time

		var index: Int16 = 0
		for sheet in sheetsTemp {
			sheet.position = index
			sheet.hasCluster = newCluster
			sheet.isTemp = false
			index += 1
		}
		
		let _ = CoreCluster.saveContext()
		
		for sheet in sheets {
			sheet.delete()
		}
		
		CoreEntity.predicates.append("isTemp", equals: true)
		let tempEntities = CoreEntity.getEntities()
		for entity in tempEntities {
			entity.delete()
		}
		
		DispatchQueue.main.async {
			self.dismiss(animated: true)
		}
	}
	
	
	
	// MARK: - Private functions
	
	private func setup() {
		
		if let cluster = cluster {
			selectedTag = cluster.hasTag
		}
		
		save.title = Text.Actions.save
		cancel.title = Text.Actions.cancel
		addSheetButton.backgroundColor = themeHighlighted
		addSheetButton.setTitleColor(themeWhiteBlackTextColor, for: .normal)
		addSheetButton.layer.cornerRadius = 5
		addLyricsButton.backgroundColor = themeHighlighted
		addLyricsButton.setTitleColor(themeWhiteBlackTextColor, for: .normal)
		addLyricsButton.layer.cornerRadius = 5
		
		navigationController?.title = Text.CustomSheets.title
		title = Text.CustomSheets.title
		view.backgroundColor = themeWhiteBlackBackground
		
		hideKeyboardWhenTappedAround()
		
		longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
		longPressGesture.minimumPressDuration = 1
		collectionView.addGestureRecognizer(longPressGesture)
		
		collectionViewTags.register(UINib(nibName: Cells.tagCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.tagCellCollection)
		
		CoreTag.predicates.append("isHidden", notEquals: true)
		tags = CoreTag.getEntities()
		
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.itemSize = sheetSize
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 30
		collectionView.collectionViewLayout = layout
		collectionView.register(UINib(nibName: SheetCollectionCell.identitier, bundle: nil), forCellWithReuseIdentifier: SheetCollectionCell.identitier)
		
		update()
	}
	
	private func update() {
		removeRedBorder()
		checkAddButton()
		collectionViewTags.reloadData()
		collectionView.reloadData()
	}
	
	private func checkAddButton() {
		if !isNew || isEdited {
			if cluster?.isTypeSong ?? clusterTemp?.isTypeSong ?? false {
				addSheetButton.removeFromSuperview()
			} else {
				addLyricsButton.removeFromSuperview()
			}
		}
	}
	
	private func hasTagSelected(_ hasTag: Bool) {
		if hasTag {
			collectionViewTags.layer.borderColor = nil
			collectionViewTags.layer.borderWidth = 0
			collectionViewTags.layer.cornerRadius = 0
		} else {
			collectionViewTags.layer.borderColor = UIColor.red.cgColor
			collectionViewTags.layer.borderWidth = 2
			collectionViewTags.layer.cornerRadius = 5
		}
	}
	
	private func buildSheets(fromText: String) {
		let newCluster: Cluster?
		if cluster == nil {
			newCluster = CoreCluster.createEntity()
		} else {
			newCluster = cluster?.tempVersion
		}
		
		newCluster?.isTemp = false
		newCluster?.hasTag = selectedTag
		
		var lyricsToDevide = fromText + "\n\n"
		
		// get title
		if let range = lyricsToDevide.range(of: "\n\n") {
			let start = lyricsToDevide.index(lyricsToDevide.startIndex, offsetBy: 0)
			let rangeSheet = start..<range.lowerBound
			let rangeRemove = start..<range.upperBound
			newCluster?.title = String(lyricsToDevide[rangeSheet])
			lyricsToDevide.removeSubrange(rangeRemove)
		}
		
		var position: Int16 = 0
		var newSheets: [Sheet] = []
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
			
			newSheets.append(newSheet)
			
			lyricsToDevide.removeSubrange(rangeRemove)
			position += 1
		}
		
		newSheets.sort{ $0.position < $1.position }
		
		if let sheets = newSheets as? [SheetTitleContentEntity] {
			for tempSheet in sheets {
				let sheet = CoreSheetTitleContent.createEntity()
				sheet.title = tempSheet.title
				sheet.lyrics = tempSheet.lyrics
				sheet.position = tempSheet.position
				newCluster?.addToHasSheets(sheet)
			}
		}
		sheets = newSheets
		clusterTemp = newCluster
		isEdited = true
		updateWithAnimation()
	}
	
	private func getTextFromSheets() -> String {
		if let sheets = sheetsTemp as? [SheetTitleContentEntity], sheetsTemp.count != 0 {
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
		return ""
	}
	
	private func animate(cell: UICollectionViewCell) {
		if let cell = cell as? SheetCollectionCell {
			let transformAnim  = CAKeyframeAnimation(keyPath:"transform")
			transformAnim.values  = [NSValue(caTransform3D: CATransform3DMakeRotation(0.01, 0.0, 0.0, 1.0)),NSValue(caTransform3D: CATransform3DMakeRotation(-0.01 , 0, 0, 1))]
			transformAnim.autoreverses = true
			transformAnim.duration = 0.115
			transformAnim.repeatCount = Float.infinity
			cell.layer.add(transformAnim, forKey: "transform")
		}
	}
	
	private func updateWithAnimation() {
		self.collectionView.alpha = 0
		UIView.animate(withDuration: 0.3, animations: {
		}) { _ in
			self.update()
			self.collectionView.layer.setAffineTransform(CGAffineTransform(translationX: 1, y: -6))
			UIView.animate(withDuration: 1, animations: {
				self.collectionView.alpha = 1
				self.collectionView.layer.setAffineTransform(CGAffineTransform.identity)
			})
		}
	}
	
	private func hasTagSelected() -> Bool {
		if selectedTag != nil {
			removeRedBorder()
			return true
		} else {
			collectionViewTags.layer.borderColor = UIColor.red.cgColor
			collectionViewTags.layer.borderWidth = 2
			collectionViewTags.layer.cornerRadius = 5
			collectionViewTags.shake()
			return false
		}
	}
	
	private func removeRedBorder() {
		collectionViewTags.layer.borderColor = nil
		collectionViewTags.layer.borderWidth = 0
		collectionViewTags.layer.cornerRadius = 0
	}
	
	// MARK: - IBAction functions
	
	@IBAction func cancel(_ sender: UIBarButtonItem) {
		// remove all
		clusterTemp?.delete()
		for sheet in sheetsTemp {
			sheet.delete()
		}
		dismiss(animated: true)
	}
	
	@IBAction func savedPressed(_ sender: UIBarButtonItem) {
		if hasTagSelected() {
			performSegue(withIdentifier: "saveNewSongSegue", sender: self)
		}
	}
	
	
}
