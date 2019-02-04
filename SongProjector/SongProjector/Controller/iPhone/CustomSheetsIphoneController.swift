//
//  CustomSheetsIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 04-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class CustomSheetsIphoneController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, NewOrEditIphoneControllerDelegate {
	
	
	
	// MARK: - Properties

	@IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var edit: UIBarButtonItem!
	@IBOutlet var save: UIBarButtonItem!
	
	@IBOutlet var collectionViewTags: UICollectionView!
	@IBOutlet var collectionView: UICollectionView!
	
	var isNew = true
	var tags: [Tag] = []
	var selectedTag: Tag? {
		didSet {
			clusterTemp?.hasTag = selectedTag
			collectionView.reloadData()
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
	
	private var clusterTemp: Cluster?
	
	var sheets: [Sheet] = [] {
		didSet {
			sheetsTemp = []
			sheetHasSheet = []
			save.isEnabled = sheets.count > 0
			for (index, sheet) in sheets.enumerated() {
				sheet.position = Int16(index)
				let tempSheet = sheet.getTemp
				sheetHasSheet.append(SheetHasSheet(sheetId: sheet.id, sheetTempId: tempSheet.id))
				sheetsTemp.append(tempSheet)
			}
		}
	}
	
	private var sheetsTemp: [Sheet] = [] {
		didSet {
			sheetsTemp.forEach({ $0.hasCluster = clusterTemp })
			var index: Int16 = 0
			sheetsTemp.forEach({
				$0.hasCluster = clusterTemp
				$0.position = index
				index += 1
			})
			sheetsTemp.sort(by: { $0.position < $1.position })
			save.isEnabled = sheetsTemp.count > 0
		}
	}
	
	var sheetHasSheet: [SheetHasSheet] = []
	
	
	// MARK: Private properties
	private var visibleCells: [IndexPath] = []
	private var sheetsSorted: [Sheet] { return sheets.sorted { $0.position < $1.position } }
	private var delaySheetAimation = 0.0
	private var multiplier: CGFloat = 9/16
	private var sheetSize = CGSize(width: 375, height: 281)
	
	private var isFirstTime = true {
		willSet { if newValue == true { delaySheetAimation = 0.0 } }
	}
	private var delay = 0.0
	
	
	
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
		if segue.identifier == "SheetPickerMenuControllerSegue" {
			let controller = segue.destination as! SheetPickerMenuController
			controller.didCreateSheet = didCreate(sheet:)
			controller.selectedTag = selectedTag
		}
	}
	
	
	// MARK: - UICollectionView Functions

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionView == collectionViewTags ? tags.count : sheets.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if collectionView == collectionViewTags {
			let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.tagCellCollection, for: indexPath) as! TagCellCollection
			collectionCell.setup(tagName: tags[indexPath.row].title ?? "")
			collectionCell.isSelectedCell = selectedTag == tags[indexPath.row]
			return collectionCell
		} else {
			
			let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.sheetCollectionCell, for: indexPath) as! SheetCollectionCell
			
			collectionCell.setupWith(
				cluster: clusterTemp,
				sheet: sheetsTemp[indexPath.row],
				tag: sheetsTemp[indexPath.row].hasTag ?? clusterTemp?.hasTag,
				didDeleteSheet: didDeleteSheet(sheet:))
			
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
			
			if let index = visibleCells.index(of: indexPath) {
				visibleCells.remove(at: index) // remove cell for one time animation
			}

			return collectionCell
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == collectionViewTags {
			return CGSize(width: 200, height: 50)
		} else {
			return sheetSize
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == collectionViewTags {
			selectedTag = selectedTag == tags[indexPath.row] ? nil : tags[indexPath.row]
		} else {
			let sheet = sheetsSorted[indexPath.section]
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
		
		if !sheets.contains(where: { $0.id == sheet.id }) {
			sheet.position = Int16(sheets.count)
			sheets.append(sheet)
		}
		isFirstTime = true
		
		var maxVisibleCells = getMaxVisiblecells()
		
		let tooMuchCells = (maxVisibleCells.count - sheets.count)
		
		if tooMuchCells > 0 {
			for _ in 0..<tooMuchCells {
				maxVisibleCells.removeLast()
			}
		}
		
		visibleCells = getMaxVisiblecells()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
			self.collectionView.reloadData()
		}
	}
	
	func didCloseNewOrEditIphoneController() {
		presentedViewController?.dismiss(animated: true, completion: nil)
	}
	
	func numberPickerValueChanged(cell: LabelNumberPickerCell, value: Int) {
		cluster?.time = Double(value)
	}
	
	func textFieldDidChange(cell: LabelTextFieldCell, text: String?) {
		cluster?.title = text
	}
	
	func didDeleteSheet(sheet: Sheet) {
		
	}
	
	
	// MARK: - Private functions

	private func setup() {
		
		if cluster == nil {
			cluster = CoreCluster.createEntity()
			cluster?.deleteDate = NSDate()
		}
		save.title = Text.Actions.save
		cancel.title = Text.Actions.cancel

		navigationController?.title = Text.CustomSheets.title
		title = Text.CustomSheets.title
		view.backgroundColor = themeWhiteBlackBackground
		
		hideKeyboardWhenTappedAround()
		
		multiplier = externalDisplayWindowRatio
		
		sheetSize = getSizeWith(height: nil, width: collectionView.frame.width)
		
//		cellName.textField.attributedPlaceholder = NSAttributedString(string: Text.CustomSheets.namePlaceHolder, attributes: [NSAttributedStringKey.foregroundColor: UIColor.placeholderColor])
//
//		if let title = cluster.title {
//			cellName.setName(name: title)
//		}
//		cellAnimationTime.setValue(Int(cluster.time))
		
		collectionView.register(UINib(nibName: Cells.sheetCollectionCell, bundle: nil), forCellWithReuseIdentifier: Cells.sheetCollectionCell)
		collectionViewTags.register(UINib(nibName: Cells.tagCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.tagCellCollection)

		CoreTag.predicates.append("isHidden", notEquals: true)
		tags = CoreTag.getEntities()
		
		let cellHeight = multiplier * (UIScreen.main.bounds.width - 20)
		sheetSize = CGSize(width: UIScreen.main.bounds.width - 20, height: cellHeight)
		
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
		layout.itemSize = sheetSize
		layout.minimumInteritemSpacing = 30
		layout.minimumLineSpacing = 0
		collectionView!.collectionViewLayout = layout
		
		if cluster != nil {
			sheets = cluster?.hasSheetsArray ?? []
			selectedTag = cluster?.hasTag
		}
		
		collectionView.keyboardDismissMode = .interactive
		
		visibleCells = getMaxVisiblecells()
		
		update()
	}
	
	private func update() {
		collectionViewTags.reloadData()
		collectionView.reloadData()
		isFirstTime = true
	}
	
	private func getMaxVisiblecells() -> [IndexPath] {
		
		let completeCellsVisible = Int(collectionView.bounds.height / sheetSize.height)
		let remainder = collectionView.bounds.height.truncatingRemainder(dividingBy: sheetSize.height)
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
	
	private func hasName() -> Bool {
		if let title = cluster?.title, title != "" {
			return true
		} else {
			let alert = UIAlertController(title: Text.CustomSheets.errorTitle, message: Text.CustomSheets.errorNoName, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: Text.Actions.ok, style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
			
			return false
		}
	}
	
	
	
	@IBAction func cancel(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
	
	@IBAction func edit(_ sender: UIBarButtonItem) {
		let optionsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		let changeGeneralSettings = UIAlertAction(title: Text.NewSong.changeTitleTime, style: .default) { _ in
			self.performSegue(withIdentifier: "changeTitleTimeSegue", sender: self)
		}
		let addSheet = UIAlertAction(title: Text.NewSong.addSheet, style: .default) { _ in
			self.performSegue(withIdentifier: "SheetPickerMenuControllerSegue", sender: self)
		}
		let changeLyrics = UIAlertAction(title: Text.NewSong.changeLyrics, style: .default) { _ in
			self.performSegue(withIdentifier: "ChangeLyricsSegue", sender: self)
		}
		
		if sheetsTemp.count == 0 {
			optionsMenu.addAction(addSheet)
			optionsMenu.addAction(changeLyrics)
		} else {
			if sheetsTemp.contains(where: { $0.hasTag?.isHidden == true }) {
				optionsMenu.addAction(addSheet)
				optionsMenu.addAction(changeGeneralSettings)
			} else {
				optionsMenu.addAction(changeLyrics)
			}
		}
		present(optionsMenu, animated: true)
	}
	
	@IBAction func savedPressed(_ sender: UIBarButtonItem) {

		if hasTagSelected() {
			if hasName() {
				if cluster == nil {
					cluster = CoreCluster.createEntity()
				}
				cluster?.hasTag = selectedTag
				
				var index: Int16 = 0
				for sheet in sheets {
					sheet.position = index
					sheet.hasCluster = cluster
					index += 1
				}
				CoreGoogleActivities.predicates.append("deleteDate", isNotNil: true)
				let activities = CoreGoogleActivities.getEntities()
				for activity in activities {
					activity.delete()
				}

				let _ = CoreCluster.saveContext()
				CoreSheet.predicates.append("deleteDate", isNotNil: true)
				let tempSheets = CoreSheet.getEntities()
				for sheet in tempSheets {
					sheet.delete()
				}
				
				sheets = []
				
				CoreEntity.saveContext()
				
				update()
				
				DispatchQueue.main.async {
					self.dismiss(animated: true)
				}
			}
		}
	}
	
	@IBAction func textfieldDidChange(_ sender: UITextField) {
		cluster?.title = sender.text
	}
	
	
	
}
