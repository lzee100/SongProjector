//
//  SaveNewSongTitleTimeVC.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22-06-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

protocol SaveNewSongTitleTimeVCDelegate {
	func didSaveClusterWith(title: String, time: Double, tagIds: [Int64])
}

class SaveNewSongTitleTimeVC: ChurchBeamTableViewController {
	
	
	@IBOutlet var saveButton: UIBarButtonItem!
	@IBOutlet var cancelButton: UIBarButtonItem!
	
	enum Section {
		case song
		case custom
		case tags
		static let all = [song, custom, tags]
	}
	
	
	enum Row {
		case title
		case time
		case tag
		
		static func `for`(indexPath: IndexPath) -> Row {
			switch Section.all[indexPath.section] {
			case .song: return title
			case .custom: return time
			case .tags: return tag
			}
		}
		
		var identifier: String {
			switch self {
			case .title: return TextFieldCell.identifier
			case .time: return PickerCell.identifier
			case .tag: return BasicCell.identifier
			}
		}
		
	}
	
	private var tags: [Tag] = []
	private var selectedTags: [Tag] = []
	
	weak var cluster: Cluster?
	weak var selectedTheme: Theme?
	
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
	var clusterTitle: String = ""
	var clusterTime: Double = 0

	var didSave: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
		cancelButton.title = Text.Actions.cancel
		saveButton.title = Text.Actions.save
		tableView.register(cells: [TextFieldCell.identifier, PickerCell.identifier, BasicCell.identifier])
		title = cluster?.title ?? Text.NewSong.title
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.tableFooterView = UIView()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		TagFetcher.addObserver(self)
		TagFetcher.fetch(force: false)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		TagFetcher.removeObserver(self)
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return Section.all.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section.all[section] {
		case .song:
			return 1
		case .custom:
			return (cluster?.isTypeSong ?? false) ? 0 : 1
		case .tags:
			return tags.count
		}
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Row.for(indexPath: indexPath).identifier)!
		
		switch Row.for(indexPath: indexPath) {
		case .title:
			(cell as! TextFieldCell).setup(description: Text.NewSong.title, content: cluster?.title ?? "", textFieldDidChange: textFieldDidChange(text:))
		case .time:
			(cell as! PickerCell).setupWith(description: Text.CustomSheets.descriptionTime, values: timeValues, selectedIndex: selectedIndex, didSelectValue: pickerDidChange(value:))
		case .tag:
			(cell as! BasicCell).setup(title: tags[indexPath.row].title, icon: Cells.bulletOpen, iconSelected: Cells.bulletFilled, textColor: themeWhiteBlackTextColor, hasPianoOnly: false)
			(cell as! BasicCell).selectedCell = selectedTags.contains(entity: tags[indexPath.row])
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if Section.all[indexPath.section] == .tags {
			if selectedTags.contains(entity: tags[indexPath.row]) {
				selectedTags.delete(entity: tags[indexPath.row])
			} else {
				selectedTags.append(tags[indexPath.row])
			}
			if let cell = tableView.cellForRow(at: indexPath) as? BasicCell {
				cell.selectedCell = selectedTags.contains(entity: tags[indexPath.row])
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if Section.all[indexPath.section] == .tags {
			return 60
		}
		return UITableViewAutomaticDimension
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if Section.all[section] == .tags {
			let view = HeaderView(frame: HeaderView.basicSize)
			view.descriptionLabel.text = "Tags"
			return view
		}
		return nil
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if Section.all[section] == .tags {
			return HeaderView.basicSize.height
		}
		return CGFloat.leastNormalMagnitude
	}
	
	override func handleRequestFinish(requesterId: String, result: AnyObject?) {
		Queues.main.async {
			self.tags = CoreTag.getEntities()
			self.tableView.reloadData()
		}
	}

	
	func textFieldDidChange(text: String?) {
		clusterTitle = text ?? ""
	}
	
	func pickerDidChange(value: Any) {
		if let value = value as? Int {
			clusterTime = Double(value)
		}
	}
	
	@IBAction func cancelButton(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true)
	}
	
	@IBAction func savePressed(_ sender: UIBarButtonItem) {
		if hasName() {
			var tagIds: [TagId] = []
			
			if let tagIds = cluster?.hasTagIds?.allObjects as? [TagId] {
				let deletedTagIds = tagIds.filter({ (tagId) -> Bool in
					return selectedTags.contains(where: { $0.id != tagId.tagId })
				})
				deletedTagIds.forEach({ moc.delete($0) })
			}
			
			selectedTags.forEach({
				let tagId = CoreTagId.createEntityNOTsave()
				tagId.tagId = $0.id
				tagIds.append(tagId)
			})
			
			cluster?.addToHasTagIds(NSSet(array: tagIds))
			
			cluster?.title = clusterTitle
			cluster?.time = clusterTime
			
			self.dismiss(animated: true) {
				self.didSave?()
			}
		}
		
	}
	
	private func hasName() -> Bool {
		let cellName = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! TextFieldCell
		if clusterTitle != "" {
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
