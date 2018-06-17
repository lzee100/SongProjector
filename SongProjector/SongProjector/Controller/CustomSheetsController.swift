//
//  CustomSheetsController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10-02-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit


class CustomSheetsController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, NewOrEditIphoneControllerDelegate, LabelNumberPickerCellDelegate, LabelTextFieldCellDelegate {
	
	
	// MARK: - Properties
	
	@IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var save: UIBarButtonItem!
	
	@IBOutlet var collectionViewTags: UICollectionView!
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var tableView: UITableView!
	
	var isNew = true
	var cluster: Cluster!
	var tags: [Tag] = []
	var selectedTag: Tag? { didSet { collectionViewTags.reloadData() }}
	var sheets: [Sheet] = [] { didSet { save.isEnabled = sheets.count > 0 } }
	
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
	private let cellName = LabelTextFieldCell.create(id: "cellName", description: Text.CustomSheets.descriptionName, placeholder: Text.NewTag.descriptionTitlePlaceholder)
	private let cellAnimationTime = LabelNumberPickerCell.create(id: "cellAnimationTime", description: Text.CustomSheets.descriptionTime, subtitle: Text.CustomSheets.descriptionTimeAdd)
	
	
	
	
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
			controller.sender = self
			controller.selectedTag = selectedTag
		}
	}
	
	
	// MARK: - UICollectionView Functions
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return collectionView == collectionViewTags ? 1 : sheetsSorted.count
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionView == collectionViewTags ? tags.count : 1
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if collectionView == collectionViewTags {
			let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.tagCellCollection, for: indexPath) as! TagCellCollection
			collectionCell.setup(tagName: tags[indexPath.row].title ?? "")
			collectionCell.isSelectedCell = selectedTag == tags[indexPath.row]
			return collectionCell
		} else {
			
			let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.sheetCollectionCell, for: indexPath)
			
			setViewFor(collectionCell: collectionCell, sheet: sheetsSorted[indexPath.section])
			
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
	
	
	// MARK: - UItableView functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 2 : sheetsSorted.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if indexPath.section == 0 {
			
			return indexPath.row == 0 ? cellName : cellAnimationTime
			
		} else {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath) as! BasicCell
			cell.setup(title: sheetsSorted[indexPath.row].title, icon: nil, iconSelected: nil)
			return cell
			
		}
		
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return indexPath.section == 0 ? .none : .delete
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			if let tag = sheetsSorted[indexPath.row].hasTag {
				
				_ = CoreTag.delete(entity: tag)
			}
			_ = CoreSheet.delete(entity: sheetsSorted[indexPath.row])
			let id = sheetsSorted[indexPath.row].id
			if let index = sheets.index(where: { $0.id == id }) {
				sheets.remove(at: index)
			}
			tableView.deleteRows(at: [indexPath], with: .fade)
		}
	}
	
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return indexPath.section == 0 ? false : true
	}
	
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		if destinationIndexPath.section == 0 {
			tableView.reloadData()
			return
		}
		let itemToMove = sheets[sourceIndexPath.row]
		sheets.remove(at: sourceIndexPath.row)
		sheets.insert(itemToMove, at: destinationIndexPath.row)
		var index: Int16 = 0
		for sheet in sheets {
			sheet.position = index
			index += 1
		}
		collectionView.reloadData()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = HeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 60))
		view.descriptionLabel.text = section == 0 ? Text.CustomSheets.tableViewHeaderGeneral.uppercased() : Text.CustomSheets.tableViewHeaderSheets.uppercased()
		return view
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 60
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
			self.tableView.reloadData()
		}
	}
	
	
	func numberPickerValueChanged(cell: LabelNumberPickerCell, value: Int) {
		cluster.time = Double(value)
	}
	
	func textFieldDidChange(cell: LabelTextFieldCell, text: String?) {
		cluster.title = text
	}
	
	
	// MARK: - Private functions
	
	private func setup() {
		
		if cluster == nil {
			cluster = CoreCluster.createEntity()
			cluster.isTemp = true
		}
		save.title = Text.Actions.save
		cancel.title = Text.Actions.cancel
		
		navigationController?.title = Text.CustomSheets.title
		title = Text.CustomSheets.title
		view.backgroundColor = themeWhiteBlackBackground
		
		hideKeyboardWhenTappedAround()
		
		multiplier = externalDisplayWindowRatio
		
		sheetSize = CGSize(width: collectionView.bounds.width - 20, height: (collectionView.bounds.width - 20) * multiplier)
		
		cellName.delegate = self
		cellAnimationTime.delegate = self
		
		cellName.textField.attributedPlaceholder = NSAttributedString(string: Text.CustomSheets.namePlaceHolder, attributes: [NSAttributedStringKey.foregroundColor: UIColor.placeholderColor])
		
		if let title = cluster.title {
			cellName.setName(name: title)
		}
		cellAnimationTime.setValue(Int(cluster.time))
		
		collectionView.register(UINib(nibName: Cells.sheetCollectionCell, bundle: nil), forCellWithReuseIdentifier: Cells.sheetCollectionCell)
		collectionViewTags.register(UINib(nibName: Cells.tagCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.tagCellCollection)
		
		tableView.register(cell: Cells.basicCellid)
		tableView.keyboardDismissMode = .interactive
		
		CoreTag.predicates.append("isHidden", notEquals: true)
		tags = CoreTag.getEntities()
		
		
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
		collectionView!.collectionViewLayout = layout
		
		if cluster != nil {
			sheets = cluster.hasSheetsArray
			selectedTag = cluster.hasTag
		}
		
		collectionView.keyboardDismissMode = .interactive
		
		visibleCells = getMaxVisiblecells()
		
		update()
	}
	
	private func update() {
		collectionViewTags.reloadData()
		collectionView.reloadData()
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

			collectionCell.previewView.addSubview(SheetView.createWith(frame: collectionCell.bounds, cluster: nil, sheet: sheet, tag: sheet.hasTag, isPreview: true))
			
		}
	}
	
	
	private func hasTagSelected() -> Bool {
		if selectedTag != nil {
			collectionViewTags.layer.borderColor = nil
			collectionViewTags.layer.borderWidth = 0
			collectionViewTags.layer.cornerRadius = 0
			return true
		} else {
			let alert = UIAlertController(title: Text.NewSong.errorTitleNoTag, message: Text.NewSong.erorrMessageNoTag, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: Text.Actions.ok, style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
			collectionViewTags.layer.borderColor = UIColor.red.cgColor
			collectionViewTags.layer.borderWidth = 2
			collectionViewTags.layer.cornerRadius = 5
			return false
		}
	}
	
	private func hasName() -> Bool {
		if let title = cluster.title, title != "" {
			cellName.textField.layer.borderColor = nil
			cellName.textField.layer.borderWidth = 0
			cellName.textField.layer.cornerRadius = 0
			return true
		} else {
			let alert = UIAlertController(title: Text.CustomSheets.errorTitle, message: Text.CustomSheets.errorNoName, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: Text.Actions.ok, style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
			cellName.textField.layer.borderColor = UIColor.red.cgColor
			cellName.textField.layer.borderWidth = 2
			cellName.textField.layer.cornerRadius = 5
			return false
		}
	}
	
	@IBAction func segmentChanged(_ sender: UISegmentedControl) {
		
		if sender.selectedSegmentIndex == 1 {
			isFirstTime = false
			collectionView.isHidden = false
			cellName.textField.resignFirstResponder()
			update()
		} else {
			isFirstTime = true
			visibleCells = collectionView.indexPathsForVisibleItems
			isFirstTime = true
			collectionView.isHidden = true
			collectionViewTags.reloadData()
			tableView.reloadData()
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
	
	@IBAction func cancel(_ sender: UIBarButtonItem) {
		// remove all
		if isNew {
			managedObjectContext.rollback()
			for sheet in sheets {
				if let sheet = sheet as? SheetTitleImageEntity {
					sheet.delete()
				} else {
					sheet.delete()
				}
				let _ = CoreSheet.delete(entity: sheet)
			}
			
			if let cluster = cluster {
				let _ = CoreCluster.delete(entity: cluster)
			}
			let _ = CoreCluster.saveContext()
		} else {
			managedObjectContext.rollback()
		}
		dismiss(animated: true)
	}
	
	@IBAction func savedPressed(_ sender: UIBarButtonItem) {
		
		if hasTagSelected() {
			if hasName() {
				if cluster == nil {
					cluster = CoreCluster.createEntity()
				}
				cluster.isTemp = false
				cluster.hasTag = selectedTag
				
				var index: Int16 = 0
				for sheet in sheets {
					sheet.position = index
					sheet.hasCluster = cluster
					sheet.isTemp = false
					index += 1
				}
				
				CoreGoogleActivities.predicates.append("isTemp", equals: true)
				let activities = CoreGoogleActivities.getEntities()
				for activity in activities {
					activity.delete()
				}
				
				let _ = CoreCluster.saveContext()
				CoreSheet.predicates.append("isTemp", equals: true)
				let tempSheets = CoreSheet.getEntities()
				for sheet in tempSheets {
					sheet.delete()
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
		cluster.title = sender.text
	}
	
	
	
}
