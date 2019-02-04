//
//  SaveNewSongTitleTimeVC.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22-06-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class SaveNewSongTitleTimeVC: UITableViewController {
	
	
	@IBOutlet var saveButton: UIBarButtonItem!
	@IBOutlet var cancelButton: UIBarButtonItem!
	
	enum Section {
		case song
		case custom
		
		static let all = [song, custom]
	}
	
	
	enum Row {
		case title
		case time
		
		static func `for`(indexPath: IndexPath) -> Row {
			switch Section.all[indexPath.section] {
			case .song: return title
			case .custom: return time
			}
		}
		
		var identifier: String {
			switch self {
			case .title: return TextFieldCell.identifier
			case .time: return PickerCell.identifier
			}
		}
		
	}
	
	weak var cluster: Cluster?
	weak var selectedTag: Tag?
	
	var timeValues: [Int] {
		var values: [Int] = []
		for int in 0...60 {
			values.append(int)
		}
		return values
	}
	var selectedIndex: Int {
		if let index = timeValues.index(where: { $0 == Int(cluster?.time ?? 0) }) {
			return index
		}
		return 0
	}
	
	var didSave: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
		cancelButton.title = Text.Actions.cancel
		saveButton.title = Text.Actions.save
		tableView.register(cells: [TextFieldCell.identifier, PickerCell.identifier])
		title = cluster?.title ?? Text.NewSong.title
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.tableFooterView = UIView()
    }
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section.all[section] {
		case .song:
			return 1
		case .custom:
			return (cluster?.isTypeSong ?? false) ? 0 : 1
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Row.for(indexPath: indexPath).identifier)!
		
		switch Row.for(indexPath: indexPath) {
		case .title:
			(cell as! TextFieldCell).setup(description: Text.NewSong.title, content: cluster?.title ?? "", textFieldDidChange: textFieldDidChange(text:))
		case .time:
			(cell as! PickerCell).setupWith(description: Text.CustomSheets.descriptionTime, values: timeValues, selectedIndex: selectedIndex, didSelectValue: pickerDidChange(value:))
		}
		return cell
	}

	
	func textFieldDidChange(text: String?) {
		cluster?.title = text ?? ""
	}
	
	func pickerDidChange(value: Any) {
		if let value = value as? Int {
			cluster?.time = Double(value)
		}
	}
	
	@IBAction func cancelButton(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true)
	}
	
	@IBAction func savePressed(_ sender: UIBarButtonItem) {
		if hasName() {
			self.dismiss(animated: true) {
				self.didSave?()
			}
		}
	}
	
	private func hasName() -> Bool {
		let cellName = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextFieldCell
		if cluster?.title != "" {
			cellName.textField.layer.borderColor = nil
			cellName.textField.layer.borderWidth = 0
			cellName.textField.layer.cornerRadius = 0
			cellName.setNeedsLayout()
			return true
		} else {
			cellName.textField.layer.borderColor = UIColor.red.cgColor
			cellName.textField.layer.borderWidth = 2
			cellName.textField.layer.cornerRadius = 5
			cellName.setNeedsLayout()
			cellName.shake()
			return false
		}
	}
}
