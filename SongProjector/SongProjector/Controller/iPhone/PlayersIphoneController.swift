//
//  PlayersIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 04-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

protocol CustomSheetsControllerDelegate {
	func didSaveSheets(sheets: [Sheet])
}

class PlayersIphoneController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, NewSheetTitleImageDelegate {

	@IBOutlet var new: UIBarButtonItem!
	@IBOutlet var save: UIBarButtonItem!
	@IBOutlet var clusterNameTextField: UITextField!
	@IBOutlet var segmentControl: UISegmentedControl!
	
	@IBOutlet var collectionViewTags: UICollectionView!
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var tableView: UITableView!
	
	var songTitle = ""
	var cluster: Cluster!
	var tags: [Tag] = []
	var selectedTag: Tag? { didSet { collectionViewTags.reloadData() }}
	var sheets: [Sheet] = [] {
		didSet { save.isEnabled = sheets.count > 0 }
	}
	var sheetsSorted: [Sheet] {
		return sheets.sorted{ $0.position < $1.position }
	}
	var delegate: CustomSheetsControllerDelegate?
	private var visibleCells: [IndexPath] = []
	private var delaySheetAimation = 0.0
	var multiplier: CGFloat = 9/16
	var sheetSize = CGSize(width: 375, height: 281)
	var sheetPreviewView = SheetView()
	var isFirstTime = true
	var delay = 0.0
	
	
	override func viewDidLoad() {
        super.viewDidLoad()

        setup()
		
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		update()
	}

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

			switch sheetsSorted[indexPath.section].type {
			case .SheetTitleImage:
				setViewFor(collectionCell: collectionCell, sheet: sheetsSorted[indexPath.section])
			case .SheetTitleContent:
				print("title content")
				
			case .SheetEmpty:
				print("empty")
			}
			let swipe = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
			swipe.direction = .left
			collectionCell.addGestureRecognizer(swipe)
			
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
		
		return collectionView == collectionViewTags ? CGSize(width: 200, height: 50) : sheetSize
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == collectionViewTags {
			selectedTag = selectedTag == tags[indexPath.row] ? nil : tags[indexPath.row]
		} else {
			let sheet = sheetsSorted[indexPath.section]
			switch sheet.type {
			case .SheetTitleImage:
				let sheetTitleImage = storyboard?.instantiateViewController(withIdentifier: "NewSheetTitleImage") as! NewSheetTitleImage
				sheetTitleImage.sheet = sheet as! SheetTitleImageEntity
				sheetTitleImage.delegate = self
				let nav = UINavigationController(rootViewController: sheetTitleImage)
				present(nav, animated: true)
			default:
				break
			}
		}
	}
	
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sheetsSorted.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath) as! BasicCell
		
		cell.setup(title: sheetsSorted[indexPath.row].title, icon: nil, iconSelected: nil)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return .delete
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
		return true
	}
	
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let itemToMove = sheets[sourceIndexPath.row]
		sheets.remove(at: sourceIndexPath.row)
		sheets.insert(itemToMove, at: destinationIndexPath.row)
		var index: Int16 = 0
		for sheet in sheets {
			sheet.position = index
			index += 1
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	// MARK: - Delegate Functions
	
	func didCreate(sheet: SheetTitleImageEntity) {
		if !sheets.contains(where: { $0.id == sheet.id }) {
			sheet.position = Int16(sheets.count)
			sheets.append(sheet)
		}
		isFirstTime = true
		visibleCells = collectionView.indexPathsForVisibleItems
//		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
			self.collectionView.reloadData()
//		}
	}
    

	private func setup() {
		
		navigationController?.title = Text.Players.title
		title = Text.Players.title
		view.backgroundColor = themeWhiteBlackBackground
		save.isEnabled = delegate != nil ? true : sheets.count > 0 ? true : false
		save.setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.gray], for: .disabled)
		
		hideKeyboardWhenTappedAround()
		
		clusterNameTextField.attributedPlaceholder = NSAttributedString(string: Text.Players.namePlaceHolder, attributes: [NSAttributedStringKey.foregroundColor: UIColor.init(red: 150, green: 150, blue: 150, alpha: 1)])
		clusterNameTextField.text = cluster?.title
		
		collectionView.register(UINib(nibName: Cells.sheetCollectionCell, bundle: nil), forCellWithReuseIdentifier: Cells.sheetCollectionCell)
		collectionViewTags.register(UINib(nibName: Cells.tagCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.tagCellCollection)
		tableView.register(cell: Cells.basicCellid)


//		CoreTag.predicates.append("isHidden", notEquals: true)
		tags = CoreTag.getEntities()
		
		segmentControl.setTitle(Text.Actions.edit, forSegmentAt: 0)
		segmentControl.setTitle(Text.Players.segmentSheets, forSegmentAt: 1)
		segmentControl.selectedSegmentIndex = 1
		
		let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		
		leftSwipe.direction = .left
		rightSwipe.direction = .right
		
		tableView.addGestureRecognizer(leftSwipe)
		collectionView.addGestureRecognizer(rightSwipe)
		
		let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		longPressGesture.minimumPressDuration = 0.7
		longPressGesture.delegate = self
		self.tableView.addGestureRecognizer(longPressGesture)
		
		let doubleTab = UITapGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		doubleTab.numberOfTapsRequired = 2
		view.addGestureRecognizer(doubleTab)
		
		new.title = Text.Actions.new
		
		let cellHeight = multiplier * (UIScreen.main.bounds.width - 20)
		sheetSize = CGSize(width: UIScreen.main.bounds.width - 20, height: cellHeight)
		
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
		
		update()
	}
	
	private func update() {
		collectionViewTags.reloadData()
		collectionView.reloadData()
		tableView.reloadData()
		isFirstTime = true
	}
	
	private func setViewFor(collectionCell: UICollectionViewCell, sheet: Sheet) {
		
		if let collectionCell = collectionCell as? SheetCollectionCell {
			
			collectionCell.setPreviewViewAspectRatioConstraint(multiplier: multiplier)
			
			for subview in collectionCell.previewView.subviews {
				subview.removeFromSuperview()
			}
			
			if let sheet = sheet as? SheetTitleImageEntity {
				let view = SheetTitleImage.createSheetTitleImageWith(frame: collectionCell.bounds, sheet: sheet, tag: sheet.hasTag)
				collectionCell.previewView.addSubview(view)
			}
		}
	}
	
	@objc private func respondToSwipeGesture(_ swipe: UISwipeGestureRecognizer) {
		
		swipe.cancelsTouchesInView = false
		if swipe.direction == .left {
			segmentControl.selectedSegmentIndex = 1
			segmentChanged(segmentControl)
		} else if swipe.direction == .right {
			segmentControl.selectedSegmentIndex = 0
			segmentChanged(segmentControl)
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
	
	private func hasName() -> Bool {
		if clusterNameTextField.text != "" {
			return true
		} else {
			let alert = UIAlertController(title: Text.Players.errorTitle, message: Text.Players.errorNoName, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: Text.Actions.ok, style: UIAlertActionStyle.default, handler: nil))
			self.present(alert, animated: true, completion: nil)
			
			return false
		}
	}
	
	@IBAction func segmentChanged(_ sender: UISegmentedControl) {
		
		if sender.selectedSegmentIndex == 1 {
			isFirstTime = false
			collectionView.isHidden = false
			clusterNameTextField.resignFirstResponder()
			update()
		} else {
			isFirstTime = true
			visibleCells = collectionView.indexPathsForVisibleItems
			isFirstTime = true
			collectionView.isHidden = true
			update()
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
	
	
	
	@IBAction func showMenu(_ sender: UIBarButtonItem) {
		Menu.showMenu(sender: self)
	}
	
	@IBAction func savedPressed(_ sender: UIBarButtonItem) {

		if hasTagSelected() {
			if hasName() {
				if cluster == nil {
					cluster = CoreCluster.createEntity()
				}
				
				var index: Int16 = 0
				for sheet in sheets {
					sheet.position = index
					cluster.addToHasSheets(sheet)
					index += 1
				}
				
				cluster.title = clusterNameTextField.text
				cluster.hasTag = selectedTag
				let _ = CoreCluster.saveContext()
				
				sheets = []
				
				update()
				
				if let delegate = delegate {
					delegate.didSaveSheets(sheets: sheets)
					DispatchQueue.main.async {
						self.dismiss(animated: true)
					}
				}
			}
		}
	}
	
	@IBAction func textfieldDidChange(_ sender: UITextField) {
		cluster.title = sender.text
	}
	
	
	
}
