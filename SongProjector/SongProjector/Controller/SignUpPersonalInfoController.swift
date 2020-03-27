
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
	
	
	var contract: VContract? {
		return signInContractSelection.contract
	}
	var organizationName: String = ""
	var organization: VOrganization!
	var user: VUser!
	var contractLedger: VContractLedger!
	override var requesterId: String {
		return "SignUpPersonalInfoController"
	}
	override var requesters: [RequesterType] {
		return [UserFetcher]
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.becomeFirstResponder()
		tableView.rowHeight = UITableView.automaticDimension
		view.backgroundColor = themeWhiteBlackBackground
		titleLabel.textColor = themeWhiteBlackTextColor
		
		organization = VOrganization()
		contractLedger = VContractLedger()
		user = VUser()

		organization.title = organizationName == "" ? "Upload organization" : organizationName
		contractLedger.phoneNumber = "0612345678"
		contractLedger.userName = "Upload user"

		user.appInstallToken = UIDevice.current.identifierForVendor!.uuidString
		user.userToken = AccountStore.icloudID
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: Text.Actions.done, style: .plain, target: self, action: #selector(didSelectDone))
	}

	override var canBecomeFirstResponder: Bool {
		return true
	}

	// Enable detection of shake motion
	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
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
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return contract?.id == 1 ? 1 : 2
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let contract = contract else {
			return 0
		}
		switch Section.for(section, contract: contract) {
		case .general: return Row.general.count
		case .beam: return Row.beam.count
		case .song: return Row.song.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let contract = contract else { return UITableViewCell() }
		
		let row = Row.for(indexPath, contract: contract)
		let cell = tableView.dequeueReusableCell(withIdentifier: row.identifier)!
		if let cell = cell as? SignUpLabelCell {
			cell.row = row
		} else if let cell = cell as? SignUpTextFieldCell {
			cell.row = row
			cell.contractLedger = contractLedger
			cell.delegate = self
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		return nil
	}
	
	@objc func didSelectDone() {
		guard AccountStore.icloudID != "" else {
			let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertController.Style.alert)
			alert.addAction(UIAlertAction(title: Text.Actions.ok, style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
			return
		}
		
		guard let contract = contract else {
			let alert = UIAlertController(title: nil, message: "Please select a contract", preferredStyle: UIAlertController.Style.alert)
			alert.addAction(UIAlertAction(title: Text.Actions.ok, style: .default, handler: nil))
			present(alert, animated: true, completion: nil)
			return
		}
		
		contractLedger.contractId = contract.id
		// not yet known
		// contractLedger.organizationId = organization.id
		let userInitInfo = UserInitInfo(organizationTitle: organization.title!, phoneNumber: contractLedger.phoneNumber, userName: contractLedger.userName, appInstallToken: user.appInstallToken!, userToken: user.userToken!, contractId: contract.id, hasApplePay: false)
		navigationItem.rightBarButtonItem?.isEnabled = false
		InitSubmitter.submitUserInit(userInitInfo, success: { (response, result) in
			Queues.main.async {
				UserFetcher.fetchMe(force: true)
			}
		}) { (error, response, result) in
			Queues.main.async {
				self.navigationItem.rightBarButtonItem?.isEnabled = true
				let restError = error ?? (result != nil ? NSError(domain: result!.errorMessage, code: 0, userInfo: nil) : nil)
				self.show(error: .error(response, restError))
			}
		}
	}
	
	override func handleRequestFinish(requesterId: String, result: AnyObject?) {
		navigationItem.rightBarButtonItem?.isEnabled = true
		if let organization = (result as? [VOrganization])?.first, let role = organization.hasRoles.first {
			Queues.main.async {
				self.user.roleId = role.id
				UserSubmitter.submit([self.user], requestMethod: .post)
			}
		} else if requesterId == UserFetcher.requesterId {
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
		let userName = contractLedger.userName != ""
		let phoneNumber = contractLedger.phoneNumber != ""
		let all = [userName, phoneNumber]

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
	var contractLedger: VContractLedger? = nil
	var delegate: SignUpTextFieldDelegate?
	
	static let identifier = "SignUpTextFieldCell"
	
	func update() {
		switch row {
		case .userName: textField.text = "Upload user"
		case .phoneNumber: textField.text = "0612345678"
		default: break
		}
		textField.placeholder = row.textValue
	}
	
	@IBAction func textFieldDidChange(_ sender: UITextField) {
		switch row {
		case .userName:
			if let value = textField.text {
				contractLedger?.userName = value
			}
		case .phoneNumber:
			if let value = textField.text {
				contractLedger?.phoneNumber = value
			}
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
	
	static func `for`(_ section: Int, contract: VContract) -> Section {
		switch contract.id {
		case 0: return general
		case 1: return beamSections[section]
		case 2: return songSections[section]
		default: return general
		}
	}
}


enum Row {
	case generalInfo
	case nameInfo
	case userName
	case phoneNumber
	case agreementBeam
	case agreementSong
	
	static let general: [Row] = [generalInfo, nameInfo, userName, phoneNumber]
	static let beam: [Row] = [agreementBeam]
	static let song: [Row] = [agreementSong]
	
	static func `for`(_ indexPath: IndexPath, contract: VContract) -> Row {
		switch Section.for(indexPath.section, contract: contract) {
		case .general: return Row.general[indexPath.row]
		case .beam: return Row.beam[indexPath.row]
		case .song: return Row.song[indexPath.row]
		}
	}
	
	var textValue: String {
		switch self {
		case .generalInfo: return "Om je account te kunnen opzetten hebben we wat informatie van je nodig."
		case .nameInfo: return "Allereerst hebben we een voor en achternaam en telefoonnummer van je nodig. Het telefoonnummer wordt gebruikt voor de betaling door middel van Tikkie"
		case .userName: return "Gebruikersnaam"
		case .phoneNumber: return "Telefoonnummer"
		case .agreementBeam: return "Ik ga akkoord met de voorwaarden van Beam en betaal 6 euro per maand"
		case .agreementSong: return "Ik ga akkoord met de voorwaarden van Song en betaal 10 euro per maand"
		}
	}
	
	var identifier: String {
		switch self {
		case .generalInfo: return SignUpLabelCell.identifier
		case .nameInfo: return SignUpLabelCell.identifier
		case .userName: return SignUpTextFieldCell.identifier
		case .phoneNumber: return SignUpTextFieldCell.identifier
		case .agreementBeam: return SignUpTextFieldCell.identifier
		case .agreementSong: return SignUpTextFieldCell.identifier
		}
	}
}
