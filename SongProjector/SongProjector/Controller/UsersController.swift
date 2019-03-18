//
//  UsersController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 09/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import MessageUI

class UsersController: ChurchBeamViewController, UITableViewDelegate, UITableViewDataSource, UserCellDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
	
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var addUserBarButton: UIBarButtonItem!
	
	
	enum Section {
		case activeUsers
		case inactiveUsers
		
		static let all = [activeUsers, inactiveUsers]
		
		static func `for`(_ section: Int) -> Section {
			return all[section]
		}
		
		var title: String {
			switch self {
			case .activeUsers: return Text.Users.ActiveUsers
			case .inactiveUsers: return Text.Users.InactiveUsers
			}
		}
	}
	
	
	// MARK: - Private properties

	private var activeUsers: [User] = []
	private var inactiveUsers: [User] = []
	private var indexPathDelete: IndexPath?
	
	
	// MARK: - UIViewController Functions
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.rowHeight = 80
		title = Text.Users.title
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		UserFetcher.addObserver(self)
		UserSubmitter.addObserver(self)
		UserFetcher.fetch(force: true)
	}
	
	
	
	// MARK: - TableView Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return Section.all.count
	}
    
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch Section.for(section) {
		case .activeUsers: return activeUsers.count
		case .inactiveUsers: return inactiveUsers.count
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier) as! UserCell
		switch Section.for(indexPath.section) {
		case .activeUsers: cell.apply(user: activeUsers[indexPath.row], delegate: self)
		case .inactiveUsers: cell.apply(user: inactiveUsers[indexPath.row], delegate: self)
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		switch Section.for(indexPath.section) {
		case .activeUsers: return .delete
		case .inactiveUsers: return .none
		}
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		switch editingStyle {
		case .delete:
			indexPathDelete = indexPath
			UserSubmitter.submit([activeUsers[indexPath.row]], requestMethod: .delete)
		default: break
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return Section.for(section).title
	}
	
	override func requestDidFinish(requesterID: String, response: ResponseType, result: AnyObject?) {
		Queues.main.async {
			self.hideLoader()
			switch response {
			case .error(_, _): super.show(error: response)
			case .OK(_):
				if requesterID == UserSubmitter.requesterId, let indexPath = self.indexPathDelete {
					self.activeUsers.remove(at: indexPath.row)
					self.tableView.deleteRow(at: indexPath, with: UITableViewRowAnimation.left)
				} else {
					self.activeUsers = CoreUser.getEntities().filter({ !$0.isMe })
					CoreUser.setSortDescriptor(attributeName: "deleteDate", ascending: false)
					self.inactiveUsers = CoreUser.getEntities(onlyDeleted: true)
					self.tableView.reloadData()
				}
			}
			self.indexPathDelete = nil
		}
	}
	
	
	
	// MARK: - UserCellDelegate Functions
	
	func didPressSendInvite(user: User) {
		
		guard let inviteToken = user.inviteToken else {
			showAlert(title: nil, message: Text.Users.noInviteToken, actionOne: Text.Actions.ok)
			return
		}
		if MFMailComposeViewController.canSendMail() {
			
			let message:String  = Text.Users.inviteTextBodyEmail(code: inviteToken)
			
			let composePicker = MFMailComposeViewController()
			
			composePicker.mailComposeDelegate = self
			
			composePicker.delegate = self
			
			composePicker.setToRecipients([])
			
			composePicker.setSubject(Text.Users.inviteEmailSubject)
			
			composePicker.setMessageBody(message, isHTML: false)
			
			self.present(composePicker, animated: true, completion: nil)
			
		} else {
			showAlert(title: nil, message: Text.Users.noEmail, actionOne: Text.Actions.ok)
		}
	}
	
	func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith didFinishWithResult:MFMailComposeResult, error:Error?) {
		presentedViewController?.dismiss(animated: true)
	}
	
	// MARK: - conformationViewDelegate Functions
	
}


protocol UserCellDelegate {
	func didPressSendInvite(user: User)
}

class UserCell: UITableViewCell {
	
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var codeLabel: UILabel!
	@IBOutlet var fromToDateLabel: UILabel!

	@IBOutlet var sendInviteCodeButton: UIButton!
	
	static let identifier = "UserCell"
	
	var user: User? = nil
	var delegate: UserCellDelegate?
	
	override func prepareForReuse() {
		super.prepareForReuse()
		fromToDateLabel.text = nil
	}
	
	override func awakeFromNib() {
		fromToDateLabel.text = nil
		codeLabel.text = nil
		nameLabel.text = nil
	}
	
	func apply(user: User, delegate: UserCellDelegate) {
		self.user = user
		self.delegate = delegate
		nameLabel.text = user.title
		codeLabel.text = user.inviteToken
		sendInviteCodeButton.setTitle(Text.Users.sendCode, for: .normal)
		sendInviteCodeButton.setTitleColor(themeHighlighted, for: .normal)
		
		if user.deleteDate != nil {
			styleAsInactive()
		}
	}
	
	private func styleAsInactive() {
		sendInviteCodeButton.setTitle(nil, for: .normal)
		sendInviteCodeButton.isHidden = true
		if let startDate = user?.createdAt?.date, let endDate = user?.deleteDate?.date {
			fromToDateLabel.text = Text.Generic.from.capitalized + " " + startDate.toString("dd-MM-yy") + " " + Text.Generic.to + " " + endDate.toString("dd-MM-yy")
			let extraMonth = endDate.day > 15 ? 1 : 0
			codeLabel.text = "\((endDate.monthsFrom(startDate) + extraMonth))" + " " + Text.Users.months
		}
	}
	
	@IBAction func didPressSendInviteCode(_ sender: UIButton) {
		if let user = user {
			delegate?.didPressSendInvite(user: user)
		}
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
	}
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
	}
	
}
