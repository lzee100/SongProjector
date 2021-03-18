//
//  InviteCodeController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 09/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

class InviteCodeController: ChurchBeamViewController {

	@IBOutlet var cancelButton: UIBarButtonItem!
	@IBOutlet var doneButton: UIBarButtonItem!
	
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var contentLabel: UILabel!
	@IBOutlet var inviteCodeTextField: UITextField!
	
	@IBOutlet var titleLabelRightConstraint: NSLayoutConstraint!
	@IBOutlet var contentLabelLeftConstraint: NSLayoutConstraint!
	
	var code = ""
	var user: VUser = {
		return VUser()
	}()
//	override var requesters: [RequesterType] {
//		return [OrganizationFetcher, InitSubmitter]
//	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(false, animated: false)
			doneButton.isEnabled = code != ""
	}
	
	@IBAction func inviteCodeTextFieldDidChange(_ sender: UITextField) {
		code = sender.text ?? ""
		doneButton.isEnabled = code != ""
	}
	
	@IBAction func didPressDone(_ sender: UIBarButtonItem) {
//		InitSubmitter.submit([user], requestMethod: .post)
	}
	
//	override func requestDidFinish(requesterID: String, response: ResponseType, result: AnyObject?) {
//		self.hideLoader()
//		switch response {
//		case .OK(_):
//			if requesterID == InitSubmitter.requesterId {
//				UserFetcher.fetchMe(force: true)
//			} else if requesterID == OrganizationFetcher.requesterId {
//				Queues.main.async {
//					self.dismiss(animated: true, completion: {
//						NotificationCenter.default.post(name: .didSignUpSuccessfully, object: nil)
//					})
//				}
//			}
//		case .error(let httpResponse, _):
//			switch httpResponse?.statusCode {
//			case .some(404):
//				Queues.main.async {
//					self.show(message: "Deze koppelcode is niet geldig")
//				}
//			default: show(error: response)
//			}
//		}
//	}
	
	@IBAction func didPressCancel(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true)
	}
	
}
