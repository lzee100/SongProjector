//
//  BibleStudyIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class BibleStudyIphoneController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BibleStudyGeneratorIphoneDelegate {
	
	

	@IBOutlet var tableView: UITableView!
	@IBOutlet var collectionViewSheets: UICollectionView!
	@IBOutlet var collectionViewTags: UICollectionView!
	@IBOutlet var saveButton: UIBarButtonItem!
	@IBOutlet var addButton: UIBarButtonItem!
	
	private var tags: [Tag] = []
	private var sheets: [Sheet] = []
	private var selectedTag: Tag?
	private var multiplier = externalDisplayWindowRatio
	private var delaySheetAimation = 0.0
	private var isFirstTime = true {
		willSet { if newValue == true { delaySheetAimation = 0.0 } }
	}
	private var sheetSize = CGSize(width: 375, height: 281)
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setup()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		update()
	}

	

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "SheetsPickerMenuSegue" {
			let controller = segue.destination as! SheetPickerMenuController
			controller.didCreateSheet = didCreate(sheet:)
			controller.bibleStudyGeneratorIphoneDelegate = self
			controller.selectedTag = selectedTag
		}
    }
	
	
	// MARK: - UITableview Functions

	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sheets.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath) as! BasicCell
		return cell
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		if collectionView == collectionViewSheets {
			return sheets.count
		} else {
			return 1
		}
	}
	
	
	
	
	// MARK: - UICollectionView Functions
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if collectionView == collectionViewSheets {
			return 1
		} else {
			return tags.count
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if collectionView == collectionViewTags {
			
			let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.tagCellCollection, for: indexPath)
			
			if let collectionCell = collectionCell as? TagCellCollection {
				collectionCell.setup(tagName: tags[indexPath.row].title ?? "")
				collectionCell.isSelectedCell = selectedTag?.id == tags[indexPath.row].id
			}
			return collectionCell
		
		} else {
			
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.sheetCollectionCell, for: indexPath) as! SheetCollectionCell
			
			return cell
			
		}
		
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == collectionViewSheets {
			return sheetSize
		} else {
			return CGSize(width: 200, height: 50)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView != collectionViewSheets {
			if selectedTag?.id != tags[indexPath.row].id {
				selectedTag = tags[indexPath.row]
				update()
			}
		}
	}
	
	
	
	// MARK: - Custom Delegate Functions
	
	func didCreate(sheet: Sheet) {
		
	}
	
	func didCloseNewOrEditIphoneController() {
		
	}
	
	func didFinishGeneratorWith(_ sheets: [Sheet]) {
		
	}
	
	
	// MARK: - Private Functions
	
	private func setup() {
		collectionViewTags.register(UINib(nibName: Cells.tagCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.tagCellCollection)
		collectionViewSheets.register(UINib(nibName: Cells.sheetCollectionCell, bundle: nil), forCellWithReuseIdentifier: Cells.sheetCollectionCell)
		
		let cellHeight = multiplier * (UIScreen.main.bounds.width - 20)
		sheetSize = CGSize(width: UIScreen.main.bounds.width - 20, height: cellHeight)

		update()
	}
	
	private func update() {
		CoreTag.setSortDescriptor(attributeName: "position", ascending: false)
		tags = CoreTag.getEntities()
		collectionViewTags.reloadData()
		collectionViewSheets.reloadData()
		isFirstTime = true
	}
	
	
	@IBAction func addToBibleStudy(_ sender: UIBarButtonItem) {
		performSegue(withIdentifier: "SheetsPickerMenuSegue", sender: self)
	}
	@IBAction func saveBibleStudy(_ sender: UIBarButtonItem) {
		
	}
	
}
