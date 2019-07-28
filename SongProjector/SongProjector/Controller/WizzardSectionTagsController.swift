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
		
		static func `for`(_ indexPath: IndexPath, tags: [Tag]) -> Row {
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
	
	var songServiceObject: SongServiceSettings!
	
	private var selectedSection: Int?
	
	
	
	// MARK: - UIView Functions
	
	override func viewDidLoad() {
        super.viewDidLoad()
		tableView.register(cell: BasicCell.identifier)
		tableView.register(cell: AddButtonCell.identifier)
		tableView.register(cell: LabelTextFieldCell.identifier)
		tableView.register(cell: LabelNumberPickerCell.identifier)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
		SongServiceSettingsSubmitter.addObserver(self)
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: Text.Actions.save, style: .plain, target: self, action: #selector(didPressDone(_:)))
		navigationItem.rightBarButtonItem?.isEnabled = songServiceObject.isValid
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		SongServiceSettingsSubmitter.removeObserver(self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let controller = segue.destination.unwrap() as? TagSelectionController, let selectedSection = selectedSection {
			controller.section = selectedSection
			controller.selectedTags = songServiceObject.sections[selectedSection].hasTags
			controller.delegate = self
		}
	}
	
	
	
	// MARK: - UITableView Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return songServiceObject.sections.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return songServiceObject.sections[section].hasTags.count + 3
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let tags = songServiceObject.sections[indexPath.section].hasTags
		
		let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: Row.for(indexPath, tags: tags).identifier)
		if let cell = cell as? LabelTextFieldCell {
			cell.setup(description: Text.SongServiceManagement.nameSection, placeholder: Text.SongServiceManagement.name, delegate: self)
			cell.textField.text = songServiceObject.sections[indexPath.section].title
 		}
		if let cell = cell as? BasicCell {
			cell.setup(title: songServiceObject.sections[indexPath.section].hasTags[indexPath.row - 2].title, icon: nil, iconSelected: nil, textColor: themeWhiteBlackTextColor, hasPianoOnly: false)
			cell.data = songServiceObject.sections[indexPath.section].hasTags[indexPath.row - 2]
		}
		if let cell = cell as? AddButtonCell {
			cell.apply(title: Text.SongServiceManagement.addTags)
		}
		if let cell = cell as? LabelNumberPickerCell {
			cell.create(id: "\(indexPath.row)", description: Text.SongServiceManagement.numberOfSongs, subtitle: nil, initialValue: Int(songServiceObject.sections[indexPath.section].numberOfSongs), values: Array(0...20))
			cell.id = "\(indexPath.section)"
			cell.delegate = self
		}
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return Text.SongServiceManagement.section + " \(section + 1)"
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView.cellForRow(at: indexPath) is AddButtonCell {
			addTagForSection(indexPath.section)
		}
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		let tagsForSection = songServiceObject.sections[indexPath.section].hasTags.count
		if tableView.cellForRow(at: indexPath) is BasicCell, tagsForSection > 1 {
			return .delete
		}
		return .none
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if let cell = tableView.cellForRow(at: indexPath) as? BasicCell, let tag = cell.data as? Tag {
			songServiceObject.sections[indexPath.section].removeFromHasTags(tag)
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
	
	func didSelectTagsFor(section: Int, tags: [Tag]) {
		songServiceObject.sections[section].tagIds = tags.compactMap({ NSNumber(value: $0.id) })
		navigationItem.rightBarButtonItem?.isEnabled = songServiceObject.isValid
	}
	
	override func handleRequestFinish(requesterId: String, result: AnyObject?) {
		Queues.main.async { [weak self] in
			if let zelf = self {
				NotificationCenter.default.post(Notification(name: NotificationNames.didSubmitSongServiceSettings))
				zelf.navigationController?.popToRootViewController(animated: true)
			}
		}
	}
	
	func numberPickerValueChanged(cell: LabelNumberPickerCell, value: Int) {
		if let section = Int(cell.id) {
			songServiceObject.sections[section].numberOfSongs = Int16(value)
		}
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
		return songServiceObject.sections[indexPath.section].hasTags.count + editTitleAndAddbutton == indexPath.row + 1
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
