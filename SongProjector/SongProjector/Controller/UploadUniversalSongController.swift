//
//  UploadUniversalSongController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 15/01/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import FirebaseAuth
import UIKit
import AVFoundation

class InstrumentUploadObject: NSObject {
	var instrument: InstrumentType = .unKnown
	var amazonLocationURL: URL?
	var localURL: URL?
	var data: NSData?
	
}

enum UploadUniversalSongError: Error {
    case noChurchSelected
    
    var localizedDescription: String {
        switch self {
        case .noChurchSelected: return "Je hebt geen kerk geselecteerd"
        }
    }
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
	
	enum Row {
		case title
        case church
        case startTime
		case sheetRow
		case soundsRow
        
        static let titleSection = [title, church, startTime]
		
		static func `for`(_ indexPath: IndexPath) -> Row {
			switch Section.for(indexPath) {
            case .title: return titleSection[indexPath.row]
			case .sheet: return sheetRow
			case .sounds: return soundsRow
			}
		}
		
		var identifier: String {
			switch self {
			case .title: return LabelTextFieldCell.identifier
            case .church: return LabelPickerCell.identifier
            case .startTime: return LabelTextFieldCell.identifier
			case .sheetRow: return SongsUploadSheetCell.identifier
			case .soundsRow: return SoundPickerCell.identifier
			}
		}
	}
	
	override var requesters: [RequesterBase] {
		return [ChurchFetcher]
	}
	
	var sounds: [InstrumentUploadObject] = []
	var cluster = VCluster()
    var churches: [VChurch] = []
    var activeIndexPath: IndexPath?
    var selectedChurch: VChurch?
    var allInstruments: [InstrumentType] = [.bassGuitar, .drums, .guitar, .piano, .pianoSolo]
    
	override func viewDidLoad() {
        super.viewDidLoad()
		setup()
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        ChurchFetcher.fetch()
        SoundPlayer.stop()
		update()
        isForPreviewUniversalSongEditing = false
        becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resignFirstResponder()
    }
	
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination.unwrap() as? UploadUniTimesController {
            vc.cluster = cluster
        }
    }
    
    
	// MARK: UITableView Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return Section.all.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section.for(section) {
		case .sheet: return cluster.hasSheets.count
		case .sounds: return sounds.count
        case .title: return cluster.hasSheets.count == 0 ? 0 : Row.titleSection.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Row.for(indexPath).identifier)
		if let cell = cell as? LabelTextFieldCell {
            switch Row.for(indexPath) {
            case .startTime:
                cell.descriptionTitle?.text = "Start time"
                cell.textField.text = cluster.startTime.stringValue
                cell.textField.placeholder = "Start time"
                cell.valueDidChange = { cell in
                    if let cell = cell as? LabelTextFieldCell, let time = cell.textField.text {
                        self.cluster.startTime = Double(time) ?? 0.0
                    }
                }
                cell.textField.keyboardType = indexPath.row == 0 ? .default : .numberPad
            default:
                cell.apply(sheet: cluster.hasSheets[indexPath.row], sheetAttribute: .SheetTitle)
                cell.textField.text = cluster.title
                cell.textField.placeholder = AppText.UploadUniversalSong.titlePlaceholder
                cell.valueDidChange = { cell in
                    if let cell = cell as? LabelTextFieldCell {
                        
                        if indexPath.row == 0, case .title = Section.for(indexPath) {
                            self.cluster.title = cell.textField.text
                        } else {
                            self.cluster.hasSheets[indexPath.row].time = cell.textField.text?.doubleValue ?? 0.0
                        }
                    }
                }
                switch Section.for(indexPath) {
                case .title: cell.textField.keyboardType = .default
                case .sheet: cell.textField.keyboardType = .numberPad
                case .sounds: cell.textField.keyboardType = .default
                }
            }
        } else if let cell = cell as? LabelPickerCell {
            cell.descriptionTitel.text = AppText.UploadUniversalSong.selectChurch
            cell.pickerValues = churches.compactMap({ $0.title }).map({ ($0, $0) })
            cell.isActive = activeIndexPath?.row == indexPath.row && activeIndexPath?.section == indexPath.section
            cell.valueDidChange = { cell in
                if let cell = cell as? LabelPickerCell {
                    self.selectedChurch = self.churches[cell.selectedIndex]
                }
            }
            cell.pickerView(cell.picker, didSelectRow: 0, inComponent: 0)
        } else if let cell = cell as? SoundPickerCell {
			let sound = sounds[indexPath.row]
			cell.setup(sound, delegate: self)
		}
		return cell!
	}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activeIndexPath = activeIndexPath == indexPath ? nil : indexPath
        switch Row.for(indexPath) {
        case .church:
            if let cell = tableView.cellForRow(at: indexPath), cell is DynamicHeightCell {
                tableView.reloadData()
            }
        default: return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cell = self.tableView(tableView, cellForRowAt: indexPath) as? DynamicHeightCell {
            return cell.preferredHeight
        }
        return UITableView.automaticDimension
    }
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let cell = cell as? SoundPickerCell {
			cell.instrumentPicker.selectRow(indexPath.row, inComponent: 0, animated: false)
		}
        if let cell = cell as? SongsUploadSheetCell {
            cell.layoutIfNeeded()
            cell.setup(cluster, sheet: cluster.hasSheets[indexPath.row], sheetPosition: indexPath.row, scaleFactor: getScaleFactor(width: cell.sheetViewContainer.bounds.width), delegate: self)
        }
        tableView.style(cell, forRowAt: indexPath)
	}
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.basicHeaderView
        view?.descriptionLabel.text = Section.for(section).title + (Section.for(section) == Section.sheet ? ((cluster.hasSheets.count == 0 ? AppText.UploadUniversalSong.noSheets : "")) : "")
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HeaderView.height
    }
    
    
	
	// MARK: - Delegate Functions
	
	// MARK: SongsUploadSheetCellDelegate Functions
	
	override func handleRequestFinish(requesterId: String, result: Any?) {
        if requesterId == ChurchFetcher.id {
            let churches: [Church] = []
            self.churches = churches.map({ VChurch(church: $0, context: moc) })
            update()
        } else {
            presentedViewController?.dismiss(animated: false)
            cluster = VCluster()
            sounds = []
            for index in 0...4 {
                let instrument = InstrumentUploadObject()
                instrument.instrument = allInstruments[index]
                sounds.append(instrument)
            }
            update()
        }
        SoundPlayer.stop()
	}
	
	func errorParsingTime() {
		show(message: "Kon de tijd niet extracten")
	}
	
	// MARK: SoundPickerCellDelegate
	
	func didSelectDocumentPicker(uploadObject: InstrumentUploadObject?) {
//        let documentPicker = InstrumentSongDocumentPicker(documentTypes: ["com.apple.iwork.pages.pages", "com.apple.iwork.numbers.numbers", "com.apple.iwork.keynote.key","public.image", "com.apple.application", "public.item", "public.content", "public.audiovisual-content", "public.movie", "public.audiovisual-content", "public.video", "public.audio", "public.text", "public.data", "public.zip-archive", "com.pkware.zip-archive", "public.composite-content"], in: .import)
        
        let types = ["m4a", "mp3", "mp4"].compactMap({ UTType(filenameExtension: $0) })
        let documentPicker = InstrumentSongDocumentPicker(forOpeningContentTypes: types, asCopy: true)
        documentPicker.instrumentUploadObject = uploadObject
		documentPicker.delegate = self
		present(documentPicker, animated: true)
	}
	
    var player: AVPlayer?
	// MARK: UIDocumentMenuDelegate

	public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		guard let selectedUrl = urls.first else { return }
		if let controller = controller as? InstrumentSongDocumentPicker {
			do {
                
                let name = UUID().uuidString + "." + selectedUrl.pathExtension
                let newPath = GetFileURLUseCase(fileName: name).getURL(location: .persitent)
                try FileManager.default.moveItem(at: selectedUrl, to: newPath)
                controller.instrumentUploadObject?.localURL = newPath
                player = AVPlayer(url: newPath)
                player?.play()
                tableView.visibleCells.compactMap({ $0 as? SoundPickerCell }).first(where: { $0.uploadObject == controller.instrumentUploadObject })?.isSelectedImageView.isHidden = false
                
            } catch {
                show(message: error.localizedDescription)
			}
		}
	}
	
	// MARK: - Private Functions
	
	private func setup() {
        tableView.register(cells: [SongsUploadSheetCell.identifier, SoundPickerCell.identifier, LabelTextFieldCell.identifier, LabelPickerCell.identifier])
        tableView.register(header: BasicHeaderView.identifier)
		tableView.rowHeight = UITableView.automaticDimension
		optionsButton.title = AppText.UploadUniversalSong.new
		for index in 0...4 {
            let instrument = InstrumentUploadObject()
            instrument.instrument = allInstruments[index]
			sounds.append(instrument)
		}
        
        NotificationCenter.default.addObserver(forName: .didFinishRequester, object: nil, queue: .main) { (not) in
            if
                let info = not.userInfo,
                let requester = info["requester"] as? RequesterBase,
                let result = info["result"] as? RequestResult,
                let isPartial = info["isPartial"] as? Bool,
                !isPartial {
                self.requesterDidFinish(requester: requester, result: result, isPartial: isPartial)
            }
        }
	}
	
	override func update() {
		tableView.reloadData()
	}
	
	private func uploadASavedSong(_ cluster: VCluster) {
	}

    private func shareSheetTimes() {
        
        let message = cluster.hasSheets.compactMap({ $0.time.stringValue }).joined(separator: "\n")
        
        let activityViewController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view

        self.present(activityViewController, animated: true, completion: nil)

    }
	
	private func didSelectPreviewButton() {
		guard cluster.hasTheme(moc: moc) != nil else {
			show(message: AppText.UploadUniversalSong.noThemeWarning)
			return
		}
		if let sheet = cluster.hasSheets.first(where: { $0 is VSheetPastors }) {
			cluster.title = sheet.title
		}
		cluster.hasInstruments = sounds.compactMap({
			let instrument = VInstrument()
            guard $0.localURL != nil else { return nil }
            instrument.id = UUID().uuidString
            instrument.resourcePath = $0.localURL?.lastPathComponent
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
		let selectSheets = UIAlertAction(title: AppText.UploadUniversalSong.selecteerSheet, style: .default, handler: { _ in
			let nav = Storyboard.MainStoryboard.instantiateViewController(withIdentifier: "CustomSheetsIphoneNavController")
			let vc: CustomSheetsController? = nav.unwrap()
			vc?.cluster = self.cluster
			vc?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppText.Actions.done, style: .plain, target: self, action: #selector(self.didPressDone))
            vc?.navigationItem.leftBarButtonItem?.tintColor = themeHighlighted
            vc?.hasSaveOption = false
			self.present(nav, animated: true)

		})
		alertSheet.addAction(selectSheets)
        
        // ADD SHEET TIMES
        alertSheet.addAction(UIAlertAction(title: "voeg tijden toe", style: .default, handler: { (_) in
            self.performSegue(withIdentifier: "universalSongTimesControllerSegue", sender: self.cluster)
        }))
        
        // SHARE SHEET TIMES
        if cluster.hasSheets.compactMap({ $0.time }).count > 0 {
            alertSheet.addAction(UIAlertAction(title: AppText.UploadUniversalSong.shareSheetTimes, style: .default, handler: { (_) in
                self.shareSheetTimes()
            }))
        }
		
		// SELECT PREVIEW OPTION
		let selectPreview = UIAlertAction(title: AppText.UploadUniversalSong.showPreview, style: .cancel, handler: { _ in
            isForPreviewUniversalSongEditing = true
			self.didSelectPreviewButton()
            self.player = nil
            SoundPlayer.stop()
		})
		alertSheet.addAction(selectPreview)

		// SELECT SAVE OPTION
		if cluster.hasTheme(moc: moc) != nil, cluster.hasSheets.count > 0 {
			
			let selectUpload = UIAlertAction(title: AppText.Actions.upload, style: .destructive, handler: { _ in
                guard let church = self.selectedChurch else {
                    self.show(message: UploadUniversalSongError.noChurchSelected.localizedDescription)
                    return
                }
                
				self.showLoader()
				if self.sounds.contains(where: { $0.localURL != nil }) {
					self.cluster.hasInstruments = self.sounds.compactMap({
						guard $0.localURL != nil else { return nil }
 						let instrument = VInstrument()
                        instrument.id = UUID().uuidString
                        instrument.resourcePath = $0.localURL?.lastPathComponent
						instrument.typeString = $0.instrument.rawValue
						instrument.isLoop = $0.instrument == .pianoSolo
						return instrument
					})

				} else {
					self.cluster.hasInstruments = []
				}
                self.cluster.church = church.id
                self.cluster.hasSheetPastors = self.cluster.hasSheets.contains(where: { $0 is VSheetPastors })
                self.showProgress(requester: UniversalClusterSubmitter)
				UniversalClusterSubmitter.submit([self.cluster], requestMethod: .post)
			})
			alertSheet.addAction(selectUpload)
			
		}

        
		// SELECT CANCEL OPTION
		let cancel = UIAlertAction(title: AppText.Actions.cancel, style: .default, handler: nil)
		alertSheet.addAction(cancel)
		
		alertSheet.popoverPresentationController?.barButtonItem = sender
		present(alertSheet, animated: true)
	}
	
	@objc func didPressDone() {
		presentedViewController?.dismiss(animated: true)
		tableView.reloadData()
	}
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animate { _ in
            self.tableView.reloadData()
        } completion: { _ in
            
        }

    }
	
}

class InstrumentSongDocumentPicker: UIDocumentPickerViewController {
	var instrumentUploadObject: InstrumentUploadObject?
}
