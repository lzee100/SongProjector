
//
//  SignUpPersonalInfoController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import UIKit

class SignUpPersonalInfoController: ChurchBeamViewController, UITableViewDelegate, UITableViewDataSource, SignUpTextFieldDelegate {
	
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var tableView: UITableView!
	
	
	var contract: Contract {
		return signInContractSelection.contract
	}
	var organizationName: String = ""
	var organization: Organization!
	var user: User!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let userDefaults = UserDefaults.standard
		UserSubmitter.addObserver(self)
		OrganizationSubmitter.addObserver(self)
		tableView.rowHeight = UITableViewAutomaticDimension
		view.backgroundColor = themeWhiteBlackBackground
		titleLabel.textColor = themeWhiteBlackTextColor
		organization = CoreOrganization.createEntityNOTsave()
		organization.title = "kerk"
		
		user = CoreUser.createEntityNOTsave()
		
		user.firstName = "Leo"
		user.lastName = "van der Zee"
		user.bankAccountName = "L. van der Zee"
		user.bankAccountNumber = "NL34INGB12345678"
		user.appInstallToken = UIDevice.current.identifierForVendor!.uuidString
		user.userToken = AccountStore.icloudID
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: Text.Actions.done, style: .plain, target: self, action: #selector(didSelectDone))
//		navigationItem.rightBarButtonItem?.isEnabled = false
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return contract == .free ? 1 : 2
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section.for(section, contract: contract) {
		case .general: return Row.general.count
		case .beam: return Row.beam.count
		case .song: return Row.song.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = Row.for(indexPath, contract: contract)
		let cell = tableView.dequeueReusableCell(withIdentifier: row.identifier)!
		if let cell = cell as? SignUpLabelCell {
			cell.row = row
		} else if let cell = cell as? SignUpTextFieldCell {
			cell.row = row
			cell.user = user
			cell.delegate = self
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		return nil
	}
	
	@objc func didSelectDone() {
		guard AccountStore.icloudID != "" else {
			let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: Text.Actions.ok, style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
			return
		}
		OrganizationSubmitter.submit([organization], requestMethod: .post)
	}
	
	override func handleRequestFinish(result: AnyObject?) {
		if ((result as? [Organization])?.first) != nil {
			UserSubmitter.submit([user], requestMethod: .post)
		} else if ((result as? [User]) != nil) {
			Queues.main.async {
				self.dismiss(animated: true, completion: {
					NotificationCenter.default.post(name: NotificationNames.didSignUpSuccessfully, object: nil)
				})
			}
		} else {
			show(message: "Something went wrong, try again")
		}
	}
	
	func textfieldDidChange() {
		let firstName = user.firstName != nil && user.firstName != ""
		let lastName = user.lastName != nil && user.lastName != ""
		let bankAccountName = user.bankAccountName != nil && user.bankAccountName != ""
		let bankAccountNumber = user.bankAccountNumber != nil && user.bankAccountNumber != ""
		let all = [firstName, lastName, bankAccountNumber, bankAccountName]

		navigationItem.rightBarButtonItem?.isEnabled = all.filter({ !$0 }).count == 0
	}
	
	
	
}

class SignUpLabelCell: UITableViewCell {
	
	@IBOutlet var contentLabel: UILabel!
	
	var row: Row = .generalInfo { didSet { update() } }
	var user: User? = nil


	static let identifier = "SignUpLabelCell"
	
	
	func update() {
		contentLabel.text = row.textValue
	}
}

protocol SignUpTextFieldDelegate {
	func textfieldDidChange()
}

class SignUpTextFieldCell: UITableViewCell {
	
	@IBOutlet var textField: UITextField!
	
	var row: Row = .generalInfo { didSet { update() } }
	var user: User? = nil
	var delegate: SignUpTextFieldDelegate?
	
	static let identifier = "SignUpTextFieldCell"
	
	func update() {
		switch row {
		case .firstName: textField.text = "Leo"
		case .lastName: textField.text = "van der Zee"
		case .banknumber: textField.text = "NL34INGB12345678"
		case .bankUsername: textField.text = "L. van der Zee"
		default: break
		}
		textField.placeholder = row.textValue
	}
	
	@IBAction func textFieldDidChange(_ sender: UITextField) {
		switch row {
		case .firstName: user?.firstName = textField.text
		case .lastName: user?.lastName = textField.text
		case .bankUsername: user?.bankAccountName = textField.text
		case .banknumber: user?.bankAccountNumber = textField.text
		default: return
		}
		delegate?.textfieldDidChange()
	}
	
}

enum Section {
	case general
	case beam
	case song
	
	static let beamSections = [general, beam]
	static let songSections = [general, song]
	
	static func `for`(_ section: Int, contract: Contract) -> Section {
		switch contract {
		case .free: return general
		case .beam: return beamSections[section]
		case .song: return songSections[section]
		}
	}
}


enum Row {
	case generalInfo
	case nameInfo
	case firstName
	case lastName
	case bankInfo
	case banknumber
	case bankUsername
	case agreementBeam
	case agreementSong
	
	static let general: [Row] = [generalInfo, nameInfo, firstName, lastName]
	static let beam: [Row] = [bankInfo, banknumber, bankUsername, agreementBeam]
	static let song: [Row] = [bankInfo, banknumber, bankUsername, agreementSong]
	
	static func `for`(_ indexPath: IndexPath, contract: Contract) -> Row {
		switch Section.for(indexPath.section, contract: contract) {
		case .general: return Row.general[indexPath.row]
		case .beam: return Row.beam[indexPath.row]
		case .song: return Row.song[indexPath.row]
		}
	}
	
	var textValue: String {
		switch self {
		case .generalInfo: return "Om je account te kunnen opzetten hebben we wat informatie van je nodig."
		case .nameInfo: return "Allereerst hebben we een voor en achternaam van je nodig. "
		case .firstName: return "Voornaam"
		case .lastName: return "Achternaam"
		case .bankInfo: return "Om je een tikkie te kunnen sturen hebben we je naam nodig die je gebruikt voor je rekening en je rekeningnummer."
		case .bankUsername: return "Naam bij bankrekening"
		case .banknumber: return "Bankrekeningnummer"
		case .agreementBeam: return "Ik ga akkoord met de voorwaarden van Beam en betaal 6 euro per maand"
		case .agreementSong: return "Ik ga akkoord met de voorwaarden van Song en betaal 10 euro per maand"
		}
	}
	
	var identifier: String {
		switch self {
		case .generalInfo: return SignUpLabelCell.identifier
		case .nameInfo: return SignUpLabelCell.identifier
		case .firstName: return SignUpTextFieldCell.identifier
		case .lastName: return SignUpTextFieldCell.identifier
		case .bankInfo: return SignUpLabelCell.identifier
		case .bankUsername: return SignUpTextFieldCell.identifier
		case .banknumber: return SignUpTextFieldCell.identifier
		case .agreementBeam: return SignUpTextFieldCell.identifier
		case .agreementSong: return SignUpTextFieldCell.identifier
			
		}
	}
}
