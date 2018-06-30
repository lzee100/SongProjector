//
//  SaveNewSongTitleTimeVC.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22-06-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class SaveNewSongTitleTimeVC: UITableViewController, LabelTextFieldCellDelegate, LabelNumberPickerCellDelegate {
	
	
	@IBOutlet var saveButton: UIBarButtonItem!
	@IBOutlet var cancelButton: UIBarButtonItem!
	
	var songTitle = ""
	var time: Double = 0
	var isSong = false
	var selectedTag: Tag?
	
	var didSave: ((String, Double) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(cell: LabelTextFieldCell.identitier)
		tableView.register(cell: LabelNumberPickerCell.identitier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1 + (isSong ? 0 : 1)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: LabelTextFieldCell.identitier) as! LabelTextFieldCell
			cell.create(id: LabelTextFieldCell.identitier, description: Text.NewSong.title, placeholder: Text.NewSong.titlePlaceholder)
			cell.setName(name: songTitle)
			cell.delegate = self
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: LabelNumberPickerCell.identitier) as! LabelNumberPickerCell
			cell.create(id: LabelNumberPickerCell.identitier, description: Text.CustomSheets.descriptionTime, subtitle: Text.CustomSheets.descriptionTimeAdd)
			cell.delegate = self
			return cell
		}
	}
	
	func textFieldDidChange(cell: LabelTextFieldCell, text: String?) {
		songTitle = text ?? ""
	}
	
	func numberPickerValueChanged(cell: LabelNumberPickerCell, value: Int) {
		time = Double(value)
	}
	

	@IBAction func cancelButton(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true)
	}
	
	@IBAction func savePressed(_ sender: UIBarButtonItem) {
		if hasName() {
			didSave?(songTitle, time)
			self.dismiss(animated: true)
		}
	}
	
	private func hasName() -> Bool {
		let cellName = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! LabelTextFieldCell
		if songTitle != "" {
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
