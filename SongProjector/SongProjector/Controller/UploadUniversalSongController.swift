//
//  UploadUniversalSongController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/01/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit

class InstrumentUploadObject: NSObject {
	var instrument: InstrumentType = .unKnown
	var amazonLocationURL: URL?
	var localURL: URL?
	var data: NSData?
}

class UploadUniversalSongController: ChurchBeamViewController, UITableViewDelegate, UITableViewDataSource, SongsUploadSheetCellDelegate, SoundPickerCellDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate {
	
	enum Section: Int {
		case sheet = 0
		case sounds = 1
		case upload = 2
		
		static let all = [sheet, upload]
		
		static func `for`(_ indexPath: IndexPath) -> Section {
			return all[indexPath.section]
		}
		
		static func `for`(_ section: Int) -> Section {
			return all[section]
		}
		
		var title: String {
			switch self{
			case .sheet: return "Sheets"
			case .sounds: return "Sounds"
			case .upload: return ""
			}
		}
	}
	
	enum Row: Int {
		case sheetRow = 0
		case soundsRow = 1
		case uploadRow = 2
		
		static let sheets = [sheetRow]
		static let sounds = [soundsRow]
		static let upload = [uploadRow]
		
		static func `for`(_ indexPath: IndexPath) -> Row {
			switch Section.for(indexPath) {
			case .sheet: return sheetRow
			case .sounds: return soundsRow
			case .upload: return uploadRow
			}
		}
		
		var identifier: String {
			switch self {
			case .sheetRow: return SongsUploadSheetCell.identifier
			case .soundsRow: return SoundPickerCell.identifier
			case .uploadRow: return AddButtonCell.identifier
			}
		}
	}
	
	var sheets: [VSheetTitleContent] = []
	var sounds: [InstrumentUploadObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
		for _ in 0...3 {
			sounds.append(InstrumentUploadObject())
		}
		setup()
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		update()
	}
	
	
	// MARK: UITableView Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return Section.all.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section.for(section) {
		case .sheet: return sheets.count
		case .sounds: return sounds.count
		case .upload: return 1
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Row.for(indexPath).identifier)
		if let cell = cell as? SongsUploadSheetCell {
			let sheet = sheets[indexPath.row]
			cell.setup(sheet, delegate: self)
		} else if let cell = cell as? SoundPickerCell {
			cell.setup(sounds[indexPath.row], delegate: self)
		} else if let cell = cell as? AddButtonCell {
			cell.apply(title: "Upload nummer")
			return cell
		}
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch Section.for(indexPath) {
		case .upload: uploadSong()
		default: return
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch Section.for(indexPath) {
		case .sheet: return UITableViewAutomaticDimension
		case .sounds: return 100
		case .upload: return 100
		}
	}
	
	
	
	// MARK: - Delegate Functions
	
	// MARK: SongsUploadSheetCellDelegate Functions
	
	func errorParsingTime() {
		show(message: "Kon de tijd niet parsen")
	}
	
	// MARK: SoundPickerCellDelegate
	
	func didSelectDocumentPicker(uploadObject: InstrumentUploadObject?) {
		let documentPicker = InstrumentSongDocumentPicker(documentTypes: [String("public.data")], in: .import)
		documentPicker.instrumentUploadObject = uploadObject
		present(documentPicker, animated: true)
	}
	
	// MARK: UIDocumentMenuDelegate
	
	public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		guard let selectedUrl = urls.first else { return }
		print("import result : \(selectedUrl)")
		if let controller = controller as? InstrumentSongDocumentPicker {
			controller.instrumentUploadObject?.localURL = selectedUrl
		}
	}

	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
				print("view was cancelled")
				dismiss(animated: true, completion: nil)
		}
	
	
	// MARK: - Private Functions
	
	private func setup() {
		tableView.register(cell: SongsUploadSheetCell.identifier)
		tableView.register(cell: AddButtonCell.identifier)
	}
	
	private func update() {
		tableView.reloadData()
	}
	
	private func uploadSong() {
		
	}

}

class InstrumentSongDocumentPicker: UIDocumentPickerViewController {
	var instrumentUploadObject: InstrumentUploadObject?
}
