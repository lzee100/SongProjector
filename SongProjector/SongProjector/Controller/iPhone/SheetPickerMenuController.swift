//
//  SheetPickerMenuController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

enum SheetPickerMenuOption {
    case sheet(sheet: VSheet)
    case bibleStudy
    case lyrics
}

protocol SheetPickerMenuControllerDelegate {
    func didSelectOption(option: SheetPickerMenuOption)
}

class SheetPickerMenuController: UITableViewController, NewOrEditIphoneControllerDelegate {
	
		
	@IBOutlet weak var cancelButton: UIBarButtonItem?
	
	var bibleStudyGeneratorIphoneDelegate: BibleStudyGeneratorIphoneDelegate?
	var bibleStudyGeneratorDelegate: BibleStudyGeneratorDelegate?
	var mode: Mode = .none
    var delegate: SheetPickerMenuControllerDelegate?
	
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
            case .songs: return AppText.SheetsMenu.sectionSongs
			case .custom: return AppText.SheetsMenu.sectionOther
			case .bible: return AppText.SheetsMenu.sectionBibleStudy
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
            case .song: return AppText.SheetsMenu.lyrics
			case .SheetTitleContent: return AppText.SheetsMenu.sheetTitleText
			case .SheetTitleImage: return AppText.SheetsMenu.sheetTitleImage
			case .SheetPastors: return AppText.SheetsMenu.sheetPastors
			case .SheetEmpty: return AppText.SheetsMenu.sheetEmpty
			case .SheetSplit: return AppText.SheetsMenu.sheetSplit
			case .SheetActivities: return AppText.SheetsMenu.sheetActivity
            case .bible: return AppText.SheetsMenu.bibleStudyGen
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
		cell.setup(title: Row.for(indexPath, mode: mode).title)
		return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let sheet: VSheet?
		var isBible = false
		switch Row.for(indexPath, mode: mode) {
		case .song: sheet = nil
		case .SheetTitleContent: sheet = VSheetTitleContent()
		case .SheetTitleImage: sheet = VSheetTitleImage()
		case .SheetPastors: sheet = VSheetPastors()
		case .SheetSplit: sheet = VSheetSplit()
		case .SheetEmpty: sheet = VSheetEmpty()
		case .SheetActivities: sheet = VSheetActivities()
		case .bible: sheet = nil
			isBible = true
		}
		
		// open edit sheet controller
		if let sheet = sheet {
            delegate?.didSelectOption(option: .sheet(sheet: sheet))
		} else if isBible { // open bible study
            delegate?.didSelectOption(option: .bibleStudy)
		} else { // open song
            delegate?.didSelectOption(option: .lyrics)
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return Section.for(section, mode: mode).title
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	
	// MARK: - NewOrEditIphoneControllerDelegate Functions
	
	func didCreate(sheet: VSheet) {
		
	}
	
	func didCloseNewOrEditIphoneController() {
		presentedViewController?.dismiss(animated: true, completion: nil)
	}

	private func setup() {
		tableView.register(cell: Cells.basicCellid)
        navigationItem.leftBarButtonItem?.tintColor = themeHighlighted
	}
	
	func dismissMenu() {
		dismiss(animated: false)
	}
	
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
	
}
