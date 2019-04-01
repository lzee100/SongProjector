//
//  WizzardSectionTagsController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 27/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

class WizzardSectionTagsController: ChurchBeamViewController, UITableViewDataSource, UITableViewDelegate, LabelTextFieldCellDelegate, TagSelectionControllerDelegate {
	
	
	@IBOutlet var tableView: UITableView!
	
	
	
	// MARK: - Properties
	
	var songServiceObject: SongServiceSettings!
	
	private var selectedSection: Int?
	
	
	
	// MARK: - UIView Functions
	
	override func viewDidLoad() {
        super.viewDidLoad()
		tableView.register(cell: BasicCell.identifier)
		tableView.register(cell: AddButtonCell.identifier)
		tableView.register(cell: LabelTextFieldCell.identifier)
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
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		if self.isMovingFromParentViewController {
			songServiceObject.sections.forEach({ $0.delete(false) })
			songServiceObject?.delete(true)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let controller = segue.destination.unwrap() as? TagSelectionController, let selectedSection = selectedSection {
			controller.section = selectedSection
			controller.selectedTags = songServiceObject.sections[selectedSection].tags
			controller.delegate = self
		}
	}
	
	
	
	// MARK: - UITableView Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return songServiceObject.sections.count
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return songServiceObject.sections[section].tags.count + 2
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: getIdentifier(indexPath))
		if let cell = cell as? LabelTextFieldCell {
			cell.setup(description: Text.SongServiceManagement.nameSection, placeholder: Text.SongServiceManagement.name, delegate: self)
 		}
		if let cell = cell as? BasicCell {
			cell.setup(title: songServiceObject.sections[indexPath.section].tags[indexPath.row - 1].title, icon: nil, iconSelected: nil, textColor: themeWhiteBlackTextColor, hasPianoOnly: false)
			cell.data = songServiceObject.sections[indexPath.section].tags[indexPath.row - 1]
		}
		if let cell = cell as? AddButtonCell {
			cell.apply(title: Text.SongServiceManagement.addTags)
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
		if tableView.cellForRow(at: indexPath) is BasicCell {
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
		songServiceObject.sections[section].hasTags = NSSet(array: tags)
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
		return songServiceObject.sections[indexPath.section].tags.count + editTitleAndAddbutton == indexPath.row + 1
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
