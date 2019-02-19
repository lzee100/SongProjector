//
//  SheetPickerMenuController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class SheetPickerMenuController: UITableViewController, NewOrEditIphoneControllerDelegate {
	
		
	@IBOutlet weak var cancelButton: UIBarButtonItem?
	
	var didCreateSheet: ((Sheet) -> Void)?
	var bibleStudyGeneratorIphoneDelegate: BibleStudyGeneratorIphoneDelegate?
	var bibleStudyGeneratorDelegate: BibleStudyGeneratorDelegate?
	var selectedTag: Tag?
	var delegate: NewOrEditIphoneControllerDelegate?
	var lyricsControllerDelegate: LyricsControllerDelegate?
	var text: String?
	var mode: Mode = .none
	
	enum Mode {
		case song
		case custom
		case bibleStudy
		case none
	}
	
	private enum Section: String {
		case songs
		case custom
		case bible
		
		static let all: [Section] = [songs, custom, bible]
		static let bibleStudySections: [Section] = [custom, bible]
		
		static func `for`(_ section: Int, mode: Mode) -> Section {
			switch mode {
			case .song: return .songs
			case .custom: return custom
			case .bibleStudy: return bibleStudySections[section]
			case .none: return all[section]
			}
		}
		
		var title: String {
			switch self {
			case .songs: return "Liedjes"
			case .custom: return "Andere dia's"
			case .bible: return "Bijbelstudie"
			}
		}
	}
	
	private enum Row: String {
		case song
		case SheetTitleContent
		case SheetTitleImage
		case SheetPastors
		case SheetSplit
		case SheetEmpty
		case SheetActivities
		case bible
		
		static let custom = [SheetTitleContent, SheetTitleImage, SheetPastors, SheetSplit, SheetEmpty, SheetActivities]

		static func iconFor(type: Row) -> UIImage {
			switch type {
			case .SheetTitleContent: return Cells.bulletOpen
			case .SheetTitleImage: return Cells.bulletOpen
			case .SheetPastors: return Cells.bulletOpen
			case .SheetSplit: return Cells.bulletOpen
			case .SheetEmpty: return Cells.bulletOpen
			case .SheetActivities: return Cells.bulletOpen
			case .song: return Cells.bulletOpen
			case .bible: return Cells.bulletOpen
			}
		}
		
		static func `for`(_ indexPath: IndexPath, mode: Mode) -> Row {
			switch Section.for(indexPath.section, mode: mode) {
			case .songs: return .song
			case .custom: return custom[indexPath.row]
			case .bible: return .bible
			}
		}
		
		var title: String {
			switch self {
			case .song: return "Liedje kjk"
			case .SheetTitleContent: return Text.SheetsMenu.sheetTitleText
			case .SheetTitleImage: return Text.SheetsMenu.sheetTitleImage
			case .SheetPastors: return Text.SheetsMenu.sheetPastors
			case .SheetEmpty: return Text.SheetsMenu.sheetSplit
			case .SheetSplit: return Text.SheetsMenu.sheetEmpty
			case .SheetActivities: return Text.SheetsMenu.sheetActivity
			case .bible: return "Bible study generator sdfksldfj"
			}
		}
		
		var icon: UIImage {
			switch self {
			case .song: return SheetType.iconFor(type: .SheetTitleContent)
			case .SheetTitleContent: return SheetType.iconFor(type: .SheetTitleContent)
			case .SheetTitleImage: return SheetType.iconFor(type: .SheetTitleImage)
			case .SheetPastors: return SheetType.iconFor(type: .SheetPastors)
			case .SheetEmpty: return SheetType.iconFor(type: .SheetEmpty)
			case .SheetSplit: return SheetType.iconFor(type: .SheetSplit)
			case .SheetActivities: return SheetType.iconFor(type: .SheetActivities)
			case .bible: return SheetType.iconFor(type: .SheetTitleContent)
			}
		}
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "BibleStudyIphoneGeneratorSegue" {
			let controller = segue.destination as! BibleStudyGeneratorIphoneController
			controller.delegate = bibleStudyGeneratorIphoneDelegate
			controller.selectedTag = selectedTag
		}
		if segue.identifier == "BibleStudyGeneratorSegue" {
			let nav = segue.destination as! UINavigationController
			let controller = nav.topViewController as! BibleStudyGeneratorController
			controller.delegate = bibleStudyGeneratorDelegate
			controller.selectedTag = selectedTag
		}
		
		if let vc = segue.destination.unwrap() as? LyricsViewController {
			vc.delegate = lyricsControllerDelegate
			vc.text = text ?? ""
		}
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
		switch mode {
		case .song, .custom: return 1
		case .bibleStudy: return 2
		case .none: return 3
		}
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section.for(section, mode: mode) {
		case .custom: return Row.custom.count
		default: return 1
		}
	}


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath) as! BasicCell
		cell.setup(title: Row.for(indexPath, mode: mode).title, icon: Row.for(indexPath, mode: mode).icon)
		return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let sheet: Sheet?
		var isBible = false
		switch Row.for(indexPath, mode: mode) {
		case .song: sheet = nil
		case .SheetTitleContent: sheet = CoreSheetTitleContent.createEntityNOTsave()
		case .SheetTitleImage: sheet = CoreSheetTitleImage.createEntityNOTsave()
		case .SheetPastors: sheet = CoreSheetPastors.createEntityNOTsave()
		case .SheetSplit: sheet = CoreSheetSplit.createEntityNOTsave()
		case .SheetEmpty: sheet = CoreSheetEmptySheet.createEntityNOTsave()
		case .SheetActivities: sheet = CoreSheetActivities.createEntityNOTsave()
		case .bible: sheet = nil
			isBible = true
		}
		
		// open edit sheet controller
		if let sheet = sheet {
			let controller = storyboard?.instantiateViewController(withIdentifier: "NewOrEditIphoneController") as! NewOrEditIphoneController
			controller.delegate = delegate
			controller.modificationMode = .newCustomSheet
			controller.dismissMenu = dismissMenu
			controller.sheet = sheet
			let nav = UINavigationController(rootViewController: controller)
			Queues.main.async {
				self.present(nav, animated: true)
			}
		} else if isBible { // open bible study
			if let device = UserDefaults.standard.value(forKey: "device") as? String, device == "ipad" {
				Queues.main.async {
					self.performSegue(withIdentifier: "BibleStudyGeneratorSegue", sender: self)
				}
			} else {
				Queues.main.async {
					self.performSegue(withIdentifier: "BibleStudyIphoneGeneratorSegue", sender: self)
				}
			}
		} else { // open song
			Queues.main.async {
				self.performSegue(withIdentifier: "ChangeLyricsSegue", sender: self)
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return Section.for(section, mode: mode).title
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	
	// MARK: - NewOrEditIphoneControllerDelegate Functions
	
	func didCreate(sheet: Sheet) {
		
	}
	
	func didCloseNewOrEditIphoneController() {
		presentedViewController?.dismiss(animated: true, completion: nil)
	}

	private func setup() {
		tableView.register(cell: Cells.basicCellid)
	}
	
	func dismissMenu() {
		dismiss(animated: false)
	}
	
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
	
}
