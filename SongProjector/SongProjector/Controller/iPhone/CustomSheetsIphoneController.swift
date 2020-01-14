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
	
	@IBOutlet var collectionViewThemes: UICollectionView!
	@IBOutlet var collectionView: UICollectionView!
	
	var isNew = true
	var themes: [VTheme] = []
	var selectedTheme: VTheme? {
		didSet {
			if let themeId = selectedTheme?.id {
				cluster?.themeId = themeId
			}
			collectionView.reloadData()
		}
	}
	
	var isEdited = false
	
	var cluster: VCluster? {
		didSet {
			if let cluster = cluster {
				sheets = cluster.hasSheets
			}
		}
	}
		
	var sheets: [VSheet] = [] {
		didSet {
			save.isEnabled = sheets.count > 0
		}
	}
	
	// MARK: Private properties
	private var visibleCells: [IndexPath] = []
	private var sheetsSorted: [VSheet] { return sheets.sorted { $0.position < $1.position } }
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
			controller.selectedTheme = selectedTheme
		}
	}
	
	
	// MARK: - UICollectionView Functions

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionView == collectionViewThemes ? themes.count : sheets.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if collectionView == collectionViewThemes {
			let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.themeCellCollection, for: indexPath) as! ThemeCellCollection
			collectionCell.setup(themeName: themes[indexPath.row].title ?? "")
			collectionCell.isSelectedCell = selectedTheme == themes[indexPath.row]
			return collectionCell
		} else {
			
			let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.sheetCollectionCell, for: indexPath) as! SheetCollectionCell
			
			collectionCell.setupWith(
				cluster: cluster,
				sheet: sheets[indexPath.row],
				theme: sheets[indexPath.row].hasTheme ?? cluster?.hasTheme,
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
		if collectionView == collectionViewThemes {
			return CGSize(width: 200, height: 50)
		} else {
			return sheetSize
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == collectionViewThemes {
			selectedTheme = selectedTheme == themes[indexPath.row] ? nil : themes[indexPath.row]
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
		let sourceItem = sheets[sourceIndexPath.row]
		sheets.remove(at: sourceIndexPath.row)
		sheets.insert(sourceItem, at: destinationIndexPath.row)
		collectionView.visibleCells.forEach { $0.layer.removeAllAnimations() }
	}
	
	
	
	// MARK: - Delegate Functions
	
	func didCreate(sheet: VSheet) {
		
		if !sheets.contains(where: { $0.id == sheet.id }) {
			sheet.position = sheets.count
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
	
	func didDeleteSheet(sheet: VSheet) {
		
	}
	
	
	// MARK: - Private functions

	private func setup() {
		
		if cluster == nil {
			cluster = VCluster()
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
		collectionViewThemes.register(UINib(nibName: Cells.themeCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.themeCellCollection)

		CoreTheme.predicates.append("isHidden", notEquals: true)
		themes = VTheme.list(sortOn: "position", ascending: true)
		
		let cellHeight = multiplier * (UIScreen.main.bounds.width - 20)
		sheetSize = CGSize(width: UIScreen.main.bounds.width - 20, height: cellHeight)
		
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
		layout.itemSize = sheetSize
		layout.minimumInteritemSpacing = 30
		layout.minimumLineSpacing = 0
		collectionView!.collectionViewLayout = layout
		
		if cluster != nil {
			sheets = cluster?.hasSheets ?? []
			selectedTheme = cluster?.hasTheme
		}
		
		collectionView.keyboardDismissMode = .interactive
		
		visibleCells = getMaxVisiblecells()
		
		update()
	}
	
	private func update() {
		collectionViewThemes.reloadData()
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
	
	private func hasThemeSelected() -> Bool {
		if selectedTheme != nil {
			return true
		} else {
			let alert = UIAlertController(title: Text.NewSong.errorTitleNoTheme, message: Text.NewSong.erorrMessageNoTheme, preferredStyle: .alert)
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
		
		if sheets.count == 0 {
			optionsMenu.addAction(addSheet)
			optionsMenu.addAction(changeLyrics)
		} else {
			if sheets.contains(where: { $0.hasTheme?.isHidden == true }) {
				optionsMenu.addAction(addSheet)
				optionsMenu.addAction(changeGeneralSettings)
			} else {
				optionsMenu.addAction(changeLyrics)
			}
		}
		present(optionsMenu, animated: true)
	}
	
	@IBAction func savedPressed(_ sender: UIBarButtonItem) {

		if hasThemeSelected() {
			if hasName() {
				if cluster == nil {
					cluster = VCluster()
				}
				if let themeId = selectedTheme?.id {
					cluster?.themeId = themeId
				}
				
				var index = 0
				for sheet in sheets {
					sheet.position = index
					sheet.hasCluster = cluster
					index += 1
				}
				
				sheets = []
								
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
