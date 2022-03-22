//
//  WizzardSectionTagsController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 27/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

class WizzardSectionTagsController: ChurchBeamViewController, UITableViewDataSource, UITableViewDelegate, LabelTextFieldCellDelegate, TagSelectionControllerDelegate, LabelNumberPickerCellDelegate {
	
	
	
	@IBOutlet var tableView: UITableView!
	
	enum Row {
		case nameSection
		case numberOfSongs
		case tag
		case addTag
		
		static func `for`(_ indexPath: IndexPath, tags: [VTag]) -> Row {
			if indexPath.row == 0 {
				return nameSection
			} else if indexPath.row == 1 {
				return numberOfSongs
			} else if (indexPath.row + 1 - 2) <= tags.count {
				return tag
			} else {
				return addTag
			}
		}
		
		var identifier: String {
			switch self {
			case .nameSection: return LabelTextFieldCell.identifier
			case .numberOfSongs: return LabelNumberPickerCell.identifier
			case .tag: return BasicCell.identifier
			case .addTag: return AddButtonCell.identifier
			}
		}
	}
	
	
	
	// MARK: - Properties
	
	var songServiceObject: VSongServiceSettings!
	override var requesters: [RequesterBase] {
		return [SongServiceSettingsSubmitter]
	}
	
	private var selectedSection: Int?
	
	
	
	// MARK: - UIView Functions
	
	override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .clear
        tableView.register(header: BasicHeaderView.identifier)
		tableView.register(cell: BasicCell.identifier)
		tableView.register(cell: AddButtonCell.identifier)
		tableView.register(cell: LabelTextFieldCell.identifier)
		tableView.register(cell: LabelNumberPickerCell.identifier)
		tableView.keyboardDismissMode = .interactive
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppText.Actions.save, style: .plain, target: self, action: #selector(didPressDone(_:)))
		navigationItem.rightBarButtonItem?.isEnabled = songServiceObject.isValid
		
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
		notificationCenter.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let controller = segue.destination.unwrap() as? TagSelectionController, let selectedSection = selectedSection {
			controller.section = selectedSection
			controller.selectedTags = songServiceObject.sections[selectedSection].hasTags(moc: moc)
			controller.delegate = self
		}
	}
	
	
	
	// MARK: - UITableView Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return songServiceObject.sections.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return songServiceObject.sections[section].hasTags(moc: moc).count + 3
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let tags = songServiceObject.sections[indexPath.section].hasTags(moc: moc)
		
		let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: Row.for(indexPath, tags: tags).identifier)
		if let cell = cell as? LabelTextFieldCell {
			cell.setup(description: AppText.SongServiceManagement.nameSection, placeholder: AppText.SongServiceManagement.name, delegate: self)
			cell.textField.text = songServiceObject.sections[indexPath.section].title
 		}
		if let cell = cell as? BasicCell {
			cell.setup(title: tags[indexPath.row - 2].title, textColor: .blackColor)
			cell.data = tags[indexPath.row - 2]
		}
		if let cell = cell as? AddButtonCell {
			cell.apply(title: AppText.SongServiceManagement.addTags)
		}
		if let cell = cell as? LabelNumberPickerCell {
			cell.create(id: "\(indexPath.row)", description: AppText.SongServiceManagement.numberOfSongs, subtitle: nil, initialValue: Int(songServiceObject.sections[indexPath.section].numberOfSongs), values: Array(0...20))
			cell.id = "\(indexPath.section)"
			cell.delegate = self
		}
		
		return cell
	}
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.backgroundColor = .grey1
        if (indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
            cell.setCornerRadiusAsMask(corners: .all)
//            cell.setCornerRadiusAsMask(corners: [.allCorners])
        } else if (indexPath.row == 0) {
            cell.setCornerRadiusAsMask(corners: .leftTopRightTop)
//            cell.setCornerRadiusAsMask(corners: [.topLeft, .topRight])
        } else if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
            cell.setCornerRadiusAsMask(corners: .leftBottomRightBottom)
//            cell.setCornerRadiusAsMask(corners: [.bottomLeft, .bottomRight])
        } else {
            cell.setBorderMask()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.basicHeaderView
        view?.descriptionLabel.text = AppText.SongServiceManagement.section + " \(section + 1)"
        return view
    }
        
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return BasicHeaderView.height
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView.cellForRow(at: indexPath) is AddButtonCell {
			addTagForSection(indexPath.section)
		}
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		let tagsForSection = songServiceObject.sections[indexPath.section].hasTags(moc: moc).count
		if tableView.cellForRow(at: indexPath) is BasicCell, tagsForSection > 1 {
			return .delete
		}
		return .none
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		let section = songServiceObject.sections[indexPath.section]
		if let cell = tableView.cellForRow(at: indexPath) as? BasicCell, let tag = cell.data as? VTag, let index = section.tagIds.firstIndex(of: tag.id) {
			section.tagIds.remove(at: index)
		}
		tableView.deleteRows(at: [indexPath], with: .left)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	// MARK: - Delegate Functions
	
	func textFieldDidChange(cell: LabelTextFieldCell, text: String?) {
		if let indexPath = tableView.indexPath(for: cell) {
			songServiceObject.sections[indexPath.section].title = text
		}
		navigationItem.rightBarButtonItem?.isEnabled = songServiceObject.isValid
	}
	
	func didSelectTagsFor(section: Int, tags: [VTag]) {
		songServiceObject.sections[section].tagIds = tags.compactMap({ $0.id })
		tableView.reloadData()
//		tableView.reloadSections(IndexSet([section]), with: .none)
//		tableView.updateHeights()
		navigationItem.rightBarButtonItem?.isEnabled = songServiceObject.isValid
	}
	
	override func handleRequestFinish(requesterId: String, result: Any?) {
        TempClustersModel.resetSavedValues()
        NotificationCenter.default.post(name: .didSubmitSongServiceSettings, object: nil)
        navigationController?.dismiss(animated: true)
	}
	
	func numberPickerValueChanged(cell: LabelNumberPickerCell, value: Int) {
		if let section = Int(cell.id) {
			songServiceObject.sections[section].numberOfSongs = Int16(value)
		}
        navigationItem.rightBarButtonItem?.isEnabled = songServiceObject.isValid
	}
	
//	@objc func adjustForKeyboard(notification: Notification) {
//		guard let keyboardValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
//
//		let keyboardScreenEndFrame = keyboardValue.cgRectValue
//		let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
//
//		if notification.name == NSNotification.Name.UIKeyboardWillHide {
//			tableView.contentInset = .zero
//		} else {
//			tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
//		}
//
//		tableView.scrollIndicatorInsets = tableView.contentInset
//
//		if let lastCell = tableView.visibleCells.last, let indexPath = tableView.indexPath(for: lastCell) {
//			tableView.scrollToRow(at: indexPath, at: .none, animated: true)
//		}
//
//	}
	@objc func keyboardWasShown (notification: NSNotification)
    {
        let info = notification.userInfo
		let keyboardSize = (info![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size

		var contentInsets: UIEdgeInsets

        if (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation.isPortrait ?? true) {
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0);
        } else {
            contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.width, right: 0.0);
        }
        
        tableView.contentInset = contentInsets
//		if let lastCell = tableView.visibleCells.last, let indexPath = tableView.indexPath(for: lastCell) {
//			tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//		}
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    

	
	// MARK: - Private Functions
	
	private func getIdentifier(_ indexPath: IndexPath) -> String {
		if indexPath.isFirst {
			return LabelTextFieldCell.identifier
		} else if isLast(indexPath) {
			return AddButtonCell.identifier
		} else {
			return BasicCell.identifier
		}
	}
	
	private func isLast(_ indexPath: IndexPath) -> Bool {
		let editTitleAndAddbutton = 2
		return songServiceObject.sections[indexPath.section].hasTags(moc: moc).count + editTitleAndAddbutton == indexPath.row + 1
	}
	
	private func addTagForSection(_ section: Int) {
		selectedSection = section
		performSegue(withIdentifier: "showTagSelectionSegue", sender: self)
	}
	
	@objc private func didPressDone(_ button: UIBarButtonItem) {
		if let songServiceObject = songServiceObject {
			SongServiceSettingsSubmitter.submit([songServiceObject], requestMethod: .post)
		}
	}
	
}

fileprivate extension IndexPath {
	var isFirst: Bool {
		return row == 0
	}
}
