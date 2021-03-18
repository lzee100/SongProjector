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
			case .activeUsers: return AppText.Users.ActiveUsers
			case .inactiveUsers: return AppText.Users.InactiveUsers
			}
		}
	}
	
//	override var requesters: [RequesterType] {
//		return [UserFetcher, UserSubmitter]
//	}
	
	
	
	// MARK: - Private properties

	private var activeUsers: [VUser] = []
	private var inactiveUsers: [VUser] = []
	private var indexPathDelete: IndexPath?
	
	
	
	// MARK: - UIViewController Functions
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.rowHeight = 80
		title = AppText.Users.title
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		UserFetcher.fetch()
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
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		switch Section.for(indexPath.section) {
		case .activeUsers: return .delete
		case .inactiveUsers: return .none
		}
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
	
//	override func requestDidFinish(requesterID: String, response: ResponseType, result: AnyObject?) {
//		Queues.main.async {
//			self.hideLoader()
//			switch response {
//			case .error(_, _): super.show(error: response)
//			case .OK(_):
//				if requesterID == UserSubmitter.requesterId, let indexPath = self.indexPathDelete {
//					self.activeUsers.remove(at: indexPath.row)
//					self.tableView.deleteRow(at: indexPath, with: UITableView.RowAnimation.left)
//				} else {
////					self.activeUsers = VUser.list().filter({ !$0.isMe })
//					CoreUser.predicates.append("isTemp", equals: false)
//					CoreUser.predicates.append(NSPredicate(format: "deleteDate != nil"))
//					self.inactiveUsers = VUser.list(sortOn: "deleteDate", ascending: false)
//					self.tableView.reloadData()
//				}
//			}
//			self.indexPathDelete = nil
//		}
//	}
	
	
	
	// MARK: - UserCellDelegate Functions
	
	func didPressSendInvite(user: VUser) {
		
//		guard let inviteToken = user.inviteToken else {
//			showAlertWith(title: nil, message: Text.Users.noInviteToken, actions: [UIAlertAction(title: Text.Actions.ok, style: .default, handler: nil)])
//			return
//		}
//		if MFMailComposeViewController.canSendMail() {
//
//			let message:String  = Text.Users.inviteTextBodyEmail(code: inviteToken)
//
//			let composePicker = MFMailComposeViewController()
//
//			composePicker.mailComposeDelegate = self
//
//			composePicker.delegate = self
//
//			composePicker.setToRecipients([])
//
//			composePicker.setSubject(Text.Users.inviteEmailSubject)
//
//			composePicker.setMessageBody(message, isHTML: false)
//
//			self.present(composePicker, animated: true, completion: nil)
//
//		} else {
//			showAlertWith(title: nil, message: Text.Users.noEmail, actions: [UIAlertAction(title: Text.Actions.ok, style: .default, handler: nil)])
//		}
	}
	
	func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith didFinishWithResult:MFMailComposeResult, error:Error?) {
		presentedViewController?.dismiss(animated: true)
	}
	
	// MARK: - conformationViewDelegate Functions
	
}


protocol UserCellDelegate {
	func didPressSendInvite(user: VUser)
}

class UserCell: UITableViewCell {
	
	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var codeLabel: UILabel!
	@IBOutlet var fromToDateLabel: UILabel!

	@IBOutlet var sendInviteCodeButton: UIButton!
	
	static let identifier = "UserCell"
	
	var user: VUser? = nil
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
	
	func apply(user: VUser, delegate: UserCellDelegate) {
		self.user = user
		self.delegate = delegate
		nameLabel.text = user.title
//		codeLabel.text = user.inviteToken
		sendInviteCodeButton.setTitle(AppText.Users.sendCode, for: .normal)
		sendInviteCodeButton.setTitleColor(themeHighlighted, for: .normal)
		
		if user.deleteDate != nil {
			styleAsInactive()
		}
	}
	
	private func styleAsInactive() {
		sendInviteCodeButton.setTitle(nil, for: .normal)
		sendInviteCodeButton.isHidden = true
		if let startDate = user?.createdAt.date, let endDate = user?.deleteDate?.date {
			fromToDateLabel.text = AppText.Generic.from.capitalized + " " + startDate.toString("dd-MM-yy") + " " + AppText.Generic.to + " " + endDate.toString("dd-MM-yy")
			let extraMonth = endDate.day > 15 ? 1 : 0
			codeLabel.text = "\((endDate.monthsFrom(startDate) + extraMonth))" + " " + AppText.Users.months
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
