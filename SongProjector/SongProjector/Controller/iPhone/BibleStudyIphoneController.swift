//
//  BibleStudyIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class BibleStudyIphoneController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BibleStudyGeneratorIphoneDelegate, NewOrEditIphoneControllerDelegate {
	

	@IBOutlet var tableView: UITableView!
	@IBOutlet var collectionViewSheets: UICollectionView!
	@IBOutlet var collectionViewTags: UICollectionView!
	@IBOutlet var saveButton: UIBarButtonItem!
	@IBOutlet var addButton: UIBarButtonItem!
	
	private var tags: [Tag] = []
	private var sheets: [Sheet] = []
	private var selectedTag: Tag?
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "SheetsPickerMenuSegue" {
			let controller = segue.destination as! SheetPickerMenuController
			controller.sender = self
			controller.bibleStudyGeneratorIphoneDelegate = self
			controller.selectedTag = selectedTag
		}
    }
	
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
		return sheets.count
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.sheetCollectionCell, for: indexPath) as! SheetCollectionCell
		return cell
	}
	
	
	// MARK: - Custom Delegate Functions
	
	func didCreate(sheet: Sheet) {
		
	}
	
	func didFinishGeneratorWith(_ sheets: [Sheet]) {
		
	}
	
	
	@IBAction func addToBibleStudy(_ sender: UIBarButtonItem) {
		performSegue(withIdentifier: "SheetsPickerMenuSegue", sender: self)
	}
	@IBAction func saveBibleStudy(_ sender: UIBarButtonItem) {
		
	}
	
}
