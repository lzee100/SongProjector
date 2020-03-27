//
//  IntroGoogleSigninController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import UIKit
import CoreData

var signInContractSelection: SgnInContractSelection = {
	return SgnInContractSelection()
}()


class SgnInContractSelection: NSManagedObject {
	var contract: VContract?
}


class IntroGoogleSigninController: ChurchBeamViewController, UITableViewDelegate, UITableViewDataSource, GoogleCellDelegate {
	
	
	
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var tableView: UITableView!
		
	static let identifier = "IntroGoogleSigninController"
	
	enum Row {
		case SignInGoogle
		case SignInButton
		
		static let all: [Row] = [SignInGoogle, SignInButton]
		
		var identifier: String {
			switch self {
			case .SignInGoogle: return IntroGoogleSigninCell.identifier
			case .SignInButton: return GoogleCell.identifier
			}
		}
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = themeWhiteBlackBackground
		titleLabel.textColor = themeWhiteBlackTextColor
		descriptionLabel.textColor = themeWhiteBlackTextColor
		titleLabel.text = Text.Intro.GoogleSignIn
		descriptionLabel.text = Text.Intro.GoogleSignInDescription
		tableView.register(cell: GoogleCell.identifier)
	}
	
	

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Row.all.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = Row.all[indexPath.row]
		if row == .SignInButton {
			let cell = tableView.dequeueReusableCell(withIdentifier: row.identifier)! as! GoogleCell
			cell.setup(delegate: self, sender: self)
		}
		let cell = tableView.dequeueReusableCell(withIdentifier: row.identifier)!
		if let cell = cell as? IntroGoogleSigninCell {
			if row == .SignInGoogle {
				cell.descriptionLabel.text = Text.Intro.ClickOnButtonToLogin
			} else {
				cell.descriptionLabel.text = Text.Intro.NewAccountOnGoogleAccount
			}
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch Row.all[indexPath.row] {
		case .SignInButton: return GoogleCell.preferredHeight
		default: return UITableView.automaticDimension
		}
	}
	
	func showInstructions(cell: GoogleCell) {
		print("instructions google cell")
	}
	
	func didSuccesfullyLogin(googleIdToken: String, userName: String) {
		self.performSegue(withIdentifier: "presentSignUpOrganisationController", sender: self)
	}
	
	
}

class IntroGoogleSigninCell: UITableViewCell {
	@IBOutlet var descriptionLabel: UILabel!

	static let identifier = "IntroGoogleSigninCell"
	
}
