//
//  BibleStudyIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit
import FirebaseAuth

class BibleStudyIphoneController: ChurchBeamViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BibleStudyGeneratorIphoneDelegate {
	
	

	@IBOutlet var tableView: UITableView!
	@IBOutlet var collectionViewSheets: UICollectionView!
	@IBOutlet var collectionViewThemes: UICollectionView!
	@IBOutlet var saveButton: UIBarButtonItem!
	@IBOutlet var addButton: UIBarButtonItem!
	
	private var themes: [VTheme] = []
	private var sheets: [VSheet] = []
	private var selectedTheme: VTheme?
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
        becomeFirstResponder()
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resignFirstResponder()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    // Enable detection of shake motion
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            do {
                try Auth.auth().signOut()
            } catch {
                print(error)
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "SheetsPickerMenuSegue" {
//			let controller = segue.destination as! SheetPickerMenuController
//			controller.didCreateSheet = didCreate(sheet:)
//			controller.bibleStudyGeneratorIphoneDelegate = self
//			controller.selectedTheme = selectedTheme
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
			return themes.count
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if collectionView == collectionViewThemes {
			
			let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.themeCellCollection, for: indexPath)
			
			if let collectionCell = collectionCell as? ThemeCellCollection {
				collectionCell.setup(themeName: themes[indexPath.row].title ?? "")
				collectionCell.isSelectedCell = selectedTheme?.id == themes[indexPath.row].id
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
			let font = UIFont.systemFont(ofSize: 17)
			let width = (themes[indexPath.row].title ?? "").width(withConstrainedHeight: 22, font: font) + 50
			return CGSize(width: width, height: 50)
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
	
	
	
	// MARK: - Custom Delegate Functions
	
	func didCreate(sheet: VSheet) {
		
	}
	
	func didCloseNewOrEditIphoneController() {
		
	}
	
	func didFinishGeneratorWith(_ sheets: [VSheet]) {
		
	}
	
	
	// MARK: - Private Functions
	
	private func setup() {
		collectionViewThemes.register(UINib(nibName: Cells.themeCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.themeCellCollection)
		collectionViewSheets.register(UINib(nibName: Cells.sheetCollectionCell, bundle: nil), forCellWithReuseIdentifier: Cells.sheetCollectionCell)
		
		let cellHeight = multiplier * (UIScreen.main.bounds.width - 20)
		sheetSize = CGSize(width: UIScreen.main.bounds.width - 20, height: cellHeight)

		update()
	}
	
    override func update() {
        moc.perform {
            let themes: [Theme] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "position", ascending: true))
            self.themes = themes.map({ VTheme(theme: $0, context: moc) })
            self.collectionViewThemes.reloadData()
            self.collectionViewSheets.reloadData()
            self.isFirstTime = true
            self.collectionViewThemes.reloadData()
        }
	}
	
	
	@IBAction func addToBibleStudy(_ sender: UIBarButtonItem) {
		performSegue(withIdentifier: "SheetsPickerMenuSegue", sender: self)
	}
	@IBAction func saveBibleStudy(_ sender: UIBarButtonItem) {
		
	}
	
}
