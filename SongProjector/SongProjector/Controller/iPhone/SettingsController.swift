//
//  SettingsController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 27-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit
import GoogleSignIn

let SheetTimeOffsetKey = "SheetTimeOffsetKey"

class SettingsController: ChurchBeamTableViewController, GoogleCellDelegate, LabelTextFieldCellDelegate, GoogleSignedInCellDelegate {
	
	
	enum Section: Int {
		case songService = 0
		case googleAgenda = 1
		
		static let all = [songService, googleAgenda]
		
		static func `for`(_ section: Int) -> Section {
			return all[section]
		}
		
		var title: String {
			switch self {
			case .songService: return Text.Settings.SectionSongServiceSettings
			case .googleAgenda: return Text.Settings.SectionGmailAccount
			}
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		setup()
		self.becomeFirstResponder()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.all.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		switch Section.for(indexPath.section) {
		case .songService:
			let cell = tableView.dequeueReusableCell(withIdentifier: LabelTextFieldCell.identifier) as! LabelTextFieldCell
			cell.create(id: LabelTextViewCell.identifier, description: Text.Settings.sheetTimeOffset, placeholder: Text.Settings.sheetTimeOffsetPlaceholder)
			cell.delegate = self
			return cell
		case .googleAgenda:
			if GIDSignIn.sharedInstance()?.currentUser != nil {
				let cell = tableView.dequeueReusableCell(withIdentifier: GoogleCell.identifier) as! GoogleCell
				cell.setup(delegate: self, sender: self)
				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: GoogleSignedInCell.identifier) as! GoogleSignedInCell
				cell.delegate = self
				return cell
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch Section.for(indexPath.section) {
		case .songService:
			return 44
		case .googleAgenda:
			return GIDSignIn.sharedInstance()?.currentUser != nil ? GoogleSignedInCell.preferredHeight : GoogleCell.preferredHeight
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return Section.for(section).title
	}
	
	override var canBecomeFirstResponder: Bool {
		return true
	}

	// Enable detection of shake motion
	override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
			let alert = UIAlertController(title: "Voer code in:", message: nil, preferredStyle: .alert)
			alert.addTextField { (textField) in
				textField.placeholder = "Code"
			}
			alert.addAction(UIAlertAction(title: Text.Actions.ok, style: .default, handler: { (_) in
				if let secret = alert.textFields![0].text, secret != "" {
					UserDefaults.standard.setValue(secret, forKey: secretKey)
				}
			}))
		}
	}
	
	
	// MARK: - Delegate Functions
	
	// MARK: GoogleCellDelegate Functions
	
	func showInstructions(cell: GoogleCell) {
		present(UIViewController(), animated: true)
	}

	func didSuccesfullyLogin(googleIdToken: String, userName: String) {
		tableView.reloadRows(at: [IndexPath(row: 0, section: Section.googleAgenda.rawValue)], with: .fade)
	}
	
	// MARK: GoogleSignedInCellDelegate Functions
	
	func didSignedOut() {
		tableView.reloadRows(at: [IndexPath(row: 0, section: Section.googleAgenda.rawValue)], with: .fade)
	}
	
	// MARK: LabelTextFieldCellDelegate Functions
	
	func textFieldDidChange(cell: LabelTextFieldCell, text: String?) {
		if let value = text, let time = Double(value) {
			UserDefaults.standard.setValue(time, forKey: SheetTimeOffsetKey)
		} else {
			show(message: Text.Settings.sheetTimeOffsetError)
		}
	}

	private func setup() {
		tableView.register(cell: LabelTextFieldCell.identifier)
		tableView.register(cell: Cells.GoogleCell)
		tableView.reloadData()
	}
}
