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

class UploadUniversalSongController: ChurchBeamViewController, UITableViewDelegate, UITableViewDataSource, SongsUploadSheetCellDelegate, SoundPickerCellDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate {
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var optionsButton: UIBarButtonItem!
	
	enum Section: Int {
		case title = 0
		case sheet = 1
		case sounds = 2
		
		static let all = [title, sheet, sounds]
		
		static func `for`(_ indexPath: IndexPath) -> Section {
			return all[indexPath.section]
		}
		
		static func `for`(_ section: Int) -> Section {
			return all[section]
		}
		
		var title: String {
			switch self{
			case .title: return "Titel"
			case .sheet: return "Sheets"
			case .sounds: return "Sounds"
			}
		}
	}
	
	enum Row: Int {
		case title = 0
		case sheetRow = 1
		case soundsRow = 2
		
		static func `for`(_ indexPath: IndexPath) -> Row {
			switch Section.for(indexPath) {
			case .title: return title
			case .sheet: return sheetRow
			case .sounds: return soundsRow
			}
		}
		
		var identifier: String {
			switch self {
			case .title: return LabelTextFieldCell.identifier
			case .sheetRow: return SongsUploadSheetCell.identifier
			case .soundsRow: return SoundPickerCell.identifier
			}
		}
	}
	
	override var requesters: [RequesterType] {
		return [ClusterSubmitter]
	}
	
	var sounds: [InstrumentUploadObject] = []
	let cluster = VCluster()
	
	override func viewDidLoad() {
        super.viewDidLoad()
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
		case .sheet: return cluster.hasSheets.count
		case .sounds: return sounds.count
		case .title: return cluster.hasSheets.count == 0 ? 0 : 1
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Row.for(indexPath).identifier)
		if let cell = cell as? LabelTextFieldCell {
			cell.apply(sheet: cluster.hasSheets[indexPath.row], sheetAttribute: .SheetTitle)
			cell.textField.placeholder = Text.UploadUniversalSong.titlePlaceholder
			cell.valueDidChange = { cell in
				if let cell = cell as? LabelTextFieldCell {
					self.cluster.title = cell.textField.text
				}
			}
		} else if let cell = cell as? SongsUploadSheetCell {
			cell.setup(cluster, sheet: cluster.hasSheets[indexPath.row], sheetPosition: indexPath.row, delegate: self)
		} else if let cell = cell as? SoundPickerCell {
			let sound = sounds[indexPath.row]
			sound.instrument = cell.allInstruments[indexPath.row]
			cell.setup(sound, delegate: self)
		}
		return cell!
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return Section.for(section).title + (Section.for(section) == Section.sheet ? ((cluster.hasSheets.count == 0 ? Text.UploadUniversalSong.noSheets : "")) : "")
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return HeaderView.basicSize.height
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let cell = cell as? SoundPickerCell {
			cell.instrumentPicker.selectRow(indexPath.row, inComponent: 0, animated: false)
			cell.selectInstrumentButton.setTitle(cell.allInstruments[indexPath.row].rawValue, for: UIControl.State())
		}
	}
	
	
	// MARK: - Delegate Functions
	
	// MARK: SongsUploadSheetCellDelegate Functions
	
	override func handleRequestFinish(requesterId: String, result: AnyObject?) {
		show(message: "Het nummer is succesvol geupload")
	}
	
	func errorParsingTime() {
		show(message: "Kon de tijd niet extracten")
	}
	
	// MARK: SoundPickerCellDelegate
	
	func didSelectDocumentPicker(uploadObject: InstrumentUploadObject?) {
		let documentPicker = InstrumentSongDocumentPicker(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content"], in: .import)
		documentPicker.instrumentUploadObject = uploadObject
		documentPicker.delegate = self
		present(documentPicker, animated: true)
	}
	
	// MARK: UIDocumentMenuDelegate

	public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		guard let selectedUrl = urls.first else { return }
		if let controller = controller as? InstrumentSongDocumentPicker {
			do {
//				let data = try Data(contentsOf: selectedUrl)
//				let localUrl = try FileManager.set(data: data, existingPath: nil, fileType: selectedUrl.pathExtension)
				let newURL = UUID().uuidString + "." + selectedUrl.pathExtension
				if let newPath = URL(string: FileManager.appFullPathTemp(existingPath: newURL)) {
					try FileManager.default.moveItem(at: selectedUrl, to: newPath)
					controller.instrumentUploadObject?.localURL = URL(string: newURL)
					tableView.visibleCells.compactMap({ $0 as? SoundPickerCell }).first(where: { $0.uploadObject == controller.instrumentUploadObject })?.fileLocationLabel.text = newURL
				}


			} catch {
				show(message: error.localizedDescription)
			}
		}
	}

	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
				dismiss(animated: true, completion: nil)
		}
	
	
	// MARK: - Private Functions
	
	private func setup() {
		tableView.register(cells: [SongsUploadSheetCell.identifier, SoundPickerCell.identifier, LabelTextFieldCell.identifier])
		tableView.rowHeight = UITableView.automaticDimension
		optionsButton.title = Text.UploadUniversalSong.new
		for _ in 0...3 {
			sounds.append(InstrumentUploadObject())
		}
	}
	
	private func update() {
		tableView.reloadData()
	}
	
	private func uploadASavedSong(_ cluster: VCluster) {
	}

	
	private func didSelectPreviewButton() {
		guard cluster.hasTheme != nil else {
			show(message: Text.UploadUniversalSong.noThemeWarning)
			return
		}
		for (index, sheet) in cluster.hasSheets.enumerated() {
			sheet.id = Int64(index)
		}
		if let sheet = cluster.hasSheets.first(where: { $0 is VSheetPastors }) {
			cluster.title = sheet.title
		}
		cluster.hasInstruments = sounds.compactMap({
			let instrument = VInstrument()
			instrument.id = Int64.random(in: 0...999999999999999)
			instrument.resourcePath = $0.localURL?.absoluteString
			instrument.typeString = $0.instrument.rawValue
			instrument.isLoop = $0.instrument == .pianoSolo
			return instrument
		})
				
		let nav = Storyboard.MainStoryboard.instantiateViewController(withIdentifier: "SongServiceNavController")
		let controller = nav.unwrap() as? SongServiceIphoneController
		controller?.previewCluster = cluster
		nav.modalPresentationStyle = .fullScreen
		present(nav, animated: true)
	}
	
	@IBAction func didSelectOptionsButton(_ sender: UIBarButtonItem) {
		let alertSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
		// SELECT SHEETS OPTION
		let selectSheets = UIAlertAction(title: Text.UploadUniversalSong.selecteerSheet, style: .default, handler: { _ in
			let nav = Storyboard.MainStoryboard.instantiateViewController(withIdentifier: "CustomSheetsIphoneNavController")
			let vc: CustomSheetsController? = nav.unwrap()
			vc?.cluster = self.cluster
			vc?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: Text.Actions.done, style: .plain, target: self, action: #selector(self.didPressDone))
			self.present(nav, animated: true)

		})
		alertSheet.addAction(selectSheets)

		
		// SELECT PREVIEW OPTION
		let selectPreview = UIAlertAction(title: Text.UploadUniversalSong.showPreview, style: .default, handler: { _ in
			self.didSelectPreviewButton()
		})
		alertSheet.addAction(selectPreview)

		// SELECT SAVE OPTION
		if cluster.hasTheme != nil, cluster.hasSheets.count > 0 {
			
			let selectUpload = UIAlertAction(title: Text.Actions.upload, style: .default, handler: { _ in
				self.showLoader()
				if self.sounds.contains(where: { $0.localURL != nil }) {
					self.cluster.hasInstruments = self.sounds.compactMap({
						guard $0.localURL != nil || $0.instrument != .unKnown else { return nil }
 						let instrument = VInstrument()
						instrument.id = Int64.random(in: 0...999999999999999)
						instrument.resourcePath = $0.localURL?.absoluteString
						instrument.typeString = $0.instrument.rawValue
						instrument.isLoop = $0.instrument == .pianoSolo
						return instrument
					})

				} else {
					self.cluster.hasInstruments = []
				}
				ClusterSubmitter.submit([self.cluster], requestMethod: .post)
			})
			alertSheet.addAction(selectUpload)
			
		}
		
		// SELECT CANCEL OPTION
		let cancel = UIAlertAction(title: Text.Actions.cancel, style: .cancel, handler: nil)
		alertSheet.addAction(cancel)
		
		alertSheet.popoverPresentationController?.barButtonItem = sender
		present(alertSheet, animated: true)
	}
	
	@objc func didPressDone() {
		for sheet in cluster.hasSheets {
			sheet.time = 33
		}
		presentedViewController?.dismiss(animated: true)
		tableView.reloadData()
	}
	
}

class InstrumentSongDocumentPicker: UIDocumentPickerViewController {
	var instrumentUploadObject: InstrumentUploadObject?
}
