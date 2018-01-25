//
//  SheetPickerMenuController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class SheetPickerMenuController: UITableViewController {
	
	@IBOutlet var emptyView: UIView!
	var sender: NewOrEditIphoneControllerDelegate?
	var sendr: BibleStudyGeneratorDelegate?
	var selectedTag: Tag?

	private enum Sections: String {
		case additional
		case `default`
		
		static let all = [additional, `default`]
		
		static func `for`(_ section: Int) -> Sections {
			return all[section]
		}
	}
	
	private enum AdditionalFeatures: String {
		case bibleStudyGenerator
		
		static let all = [bibleStudyGenerator]
		
		static func `for`(_ indexPath: IndexPath) -> AdditionalFeatures {
			return all[indexPath.row]
		}
		
		static func iconFor(_ feature: AdditionalFeatures) -> UIImage {
			switch feature {
			case .bibleStudyGenerator:
				return Cells.bulletOpen
			}
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "BibleStudyGeneratorSegue" {
			let controller = segue.destination as! BibleStudyGeneratorIphoneController
			controller.delegate = sendr
			controller.selectedTag = selectedTag
		}
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.all.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Sections.for(section) {
		case .additional:
			return AdditionalFeatures.all.count
		case .default:
			return SheetType.all.count
		}
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath) as! BasicCell
		
		switch Sections.for(indexPath.section) {
		case .additional:
			switch AdditionalFeatures.for(indexPath) {
			case .bibleStudyGenerator:
				cell.setup(title: Text.SheetsMenu.bibleStudyGen, icon: AdditionalFeatures.iconFor(.bibleStudyGenerator))
				return cell
			}
		case .default:
			switch SheetType.for(indexPath){
			case .SheetTitleContent:
				cell.setup(title: Text.SheetsMenu.sheetTitleText, icon: SheetType.iconFor(type: .SheetTitleContent))
				return cell
			case .SheetTitleImage:
				cell.setup(title: Text.SheetsMenu.sheetTitleImage, icon: SheetType.iconFor(type: .SheetTitleImage))
				return cell
			case .SheetSplit:
				cell.setup(title: Text.SheetsMenu.sheetSplit, icon: SheetType.iconFor(type: .SheetSplit))
				return cell
			case .SheetEmpty:
				cell.setup(title: Text.SheetsMenu.sheetEmpty, icon: SheetType.iconFor(type: .SheetEmpty))
				return cell
			}
		}
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch Sections.for(indexPath.section) {
		case .additional:
			switch AdditionalFeatures.for(indexPath) {
			case .bibleStudyGenerator:
				performSegue(withIdentifier: "BibleStudyGeneratorSegue", sender: self)
			}
		case .default:
			let controller = storyboard?.instantiateViewController(withIdentifier: "NewOrEditIphoneController") as! NewOrEditIphoneController
			controller.delegate = sender
			switch SheetType.for(indexPath){
			case .SheetTitleContent:
				let sheet = CoreSheetTitleContent.createEntity()
				sheet.isTemp = true
				controller.sheet = sheet
			case .SheetTitleImage:
				let sheet = CoreSheetTitleImage.createEntity()
				sheet.isTemp = true
				controller.sheet = sheet
			case .SheetSplit:
				let sheet = CoreSheetSplit.createEntity()
				sheet.isTemp = true
				controller.sheet = sheet
			case .SheetEmpty:
				let sheet = CoreSheetEmptySheet.createEntity()
				sheet.isTemp = true
				controller.sheet = sheet
			}
			let nav = UINavigationController(rootViewController: controller)
			present(nav, animated: true)
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}

	private func setup() {
		tableView.register(cell: Cells.basicCellid)
		emptyView.backgroundColor = themeWhiteBlackBackground
	}
	
}
