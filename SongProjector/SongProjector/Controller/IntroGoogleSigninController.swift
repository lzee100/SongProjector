//
//  IntroGoogleSigninController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import Foundation
import UIKit

var signInContractSelection: SgnInContractSelection = {
	return SgnInContractSelection()
}()


class SgnInContractSelection: NSObject {
	var contract: Contract = .free
}


class IntroGoogleSigninController: ChurchBeamViewController, UITableViewDelegate, UITableViewDataSource {
	
	
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var tableView: UITableView!
	
	let googleCell = GoogleCell.create(id: "GoogleCell", description: Text.Settings.descriptionGoogle)
	
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
		titleLabel.text = "Sign-In"
		descriptionLabel.text = "Bij deze app kan je inloggen met je google account. Heb je al een account aangemaakt bij Churchbeam?"
		tableView.register(cell: GoogleCell.identifier)
		googleCell.sender = self
	}
	
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Row.all.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = Row.all[indexPath.row]
		if row == .SignInButton {
			return googleCell
		}
		let cell = tableView.dequeueReusableCell(withIdentifier: row.identifier)!
		if let cell = cell as? IntroGoogleSigninCell {
			if row == .SignInGoogle {
				cell.descriptionLabel.text = "Klik op onderstaande knop om in te loggen met je Google account."
			} else {
				cell.descriptionLabel.text = "Klik op onderstaande knop om een nieuw account aan te maken op basis van je Google account."
			}
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch Row.all[indexPath.row] {
		case .SignInButton: return googleCell.preferredHeight
		default: return UITableViewAutomaticDimension
		}
	}
	
	
}

class IntroGoogleSigninCell: UITableViewCell {
	@IBOutlet var descriptionLabel: UILabel!

	static let identifier = "IntroGoogleSigninCell"
	
}
