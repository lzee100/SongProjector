//
//  SettingsController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 27-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

let SheetTimeOffsetKey = "SheetTimeOffsetKey"

class SettingsController: ChurchBeamViewController, UITableViewDelegate, UITableViewDataSource, GoogleCellDelegate, LabelTextFieldCellDelegate, GoogleSignedInCellDelegate {
	
    @IBOutlet var tableView: UITableView!
    
	enum Section: Int, CaseIterable {
//		case songService = 0
		case googleAccount = 0
        case googleCalendarId = 1
				
		static func `for`(_ section: Int) -> Section {
            return Section.allCases[section]
		}
		
		var title: String {
			switch self {
//			case .songService: return AppText.Settings.SectionSongServiceSettings
			case .googleAccount: return AppText.Settings.SectionGmailAccount
            case .googleCalendarId: return AppText.Settings.SectionCalendarId

			}
		}
	}
	
	override var requesters: [RequesterBase] {
		return [AdminFetcher, UserSubmitter]
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

    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
	
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		switch Section.for(indexPath.section) {
//		case .songService:
//			let cell = tableView.dequeueReusableCell(withIdentifier: LabelTextFieldCell.identifier) as! LabelTextFieldCell
//			cell.create(id: LabelTextViewCell.identifier, description: AppText.Settings.sheetTimeOffset, placeholder: AppText.Settings.sheetTimeOffsetPlaceholder)
//			cell.delegate = self
//			return cell
		case .googleAccount:
            if GIDSignIn.sharedInstance()?.currentUser != nil || Auth.auth().currentUser != nil {
				let cell = tableView.dequeueReusableCell(withIdentifier: GoogleSignedInCell.identifier) as! GoogleSignedInCell
				cell.setup(delegate: self, sender: self)
				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: GoogleCell.identifier) as! GoogleCell
				cell.setup(delegate: self, sender: self)
				return cell
			}
        case .googleCalendarId:
            let cell = tableView.dequeueReusableCell(withIdentifier: LabelTextFieldCell.identifier) as! LabelTextFieldCell
            cell.id = AppText.Settings.CalendarIdPlaceHolder
            cell.setup(description: "ID", placeholder: AppText.Settings.CalendarIdPlaceHolder, delegate: self)
            let user: User? = DataFetcher().getEntity(moc: moc)
            cell.textField.text = user?.googleCalendarId
            return cell
		}
	}
	
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch Section.for(indexPath.section) {
//        case .songService, .googleCalendarId:
        case .googleCalendarId:
            return UITableView.automaticDimension
		case .googleAccount:
			return GIDSignIn.sharedInstance()?.currentUser != nil ? GoogleSignedInCell.preferredHeight : GoogleCell.preferredHeight
		}
	}
	
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.style(cell, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HeaderView.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return HeaderView.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.basicHeaderView else { return nil }
        view.descriptionLabel.text = Section.for(section).title
        return view
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == Section.allCases.count - 1 {
            let view = tableView.basicFooterView
            let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            view?.setup(description: AppText.Settings.Appversion + (appVersion ?? ""))
            view?.descriptionLabel.textAlignment = .center
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == Section.allCases.count - 1 ? 100 : CGFloat.leastNonzeroMagnitude
    }
	
    override var canBecomeFirstResponder: Bool {
		return true
	}

	// Enable detection of shake motion
	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		if motion == .motionShake {
            AdminFetcher.fetch()
		}
	}
	
	
	// MARK: - Delegate Functions
	
	// MARK: RequestObserver Functions
    
    override func requesterDidFinish(requester: RequesterBase, result: RequestResult, isPartial: Bool) {
        switch result {
        case .success(let result):
            guard (result as? [VAdmin])?.count ?? 0 > 0 else {
                return
            }
            Queues.main.async {
                
                UserDefaults.standard.set("true", forKey: secretKey)
                let alert = UIAlertController(title: nil, message: "Wil je van omgeving wisselen? \(ChurchBeamConfiguration.environment.name)", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Wissel naar: \(ChurchBeamConfiguration.environment.next)", style: .default, handler: { (_) in
                    ChurchBeamConfiguration.environment = ChurchBeamConfiguration.environment.next
                    GIDSignIn.sharedInstance().signOut()
                    Queues.background.asyncAfter(deadline: .now() + 1) {
                        fatalError("Wissel van omgeving")
                    }
                }))
                alert.addAction(UIAlertAction(title: AppText.Actions.cancel, style: .cancel, handler: { (_) in
                    Queues.main.async {
                        NotificationCenter.default.post(name: .secretChanged, object: nil, userInfo: nil)
                    }
                }))
                alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 1, height: 1)
                alert.popoverPresentationController?.sourceView = UIView(frame: CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 1, height: 1))
                self.present(alert, animated: true)
            }
        case .failed(let error):
            if requester.id == UserSubmitter.id {
                show(error)
            }
            return
        }
    }
	
	// MARK: GoogleCellDelegate Functions
	
	func showInstructions(cell: GoogleCell) {
		present(UIViewController(), animated: true)
	}

	func didSuccesfullyLogin(googleIdToken: String, userName: String) {
		tableView.reloadRows(at: [IndexPath(row: 0, section: Section.googleAccount.rawValue)], with: .fade)
	}
	
	// MARK: GoogleSignedInCellDelegate Functions
	
	func didSignedOut() {
		tableView.reloadRows(at: [IndexPath(row: 0, section: Section.googleAccount.rawValue)], with: .fade)
	}
	
	// MARK: LabelTextFieldCellDelegate Functions
	
	func textFieldDidChange(cell: LabelTextFieldCell, text: String?) {
        if cell.id == AppText.Settings.CalendarIdPlaceHolder {
            let user: User? = DataFetcher().getEntity(moc: moc, predicates: [.skipDeleted])
            let vUser = [user].compactMap({ $0 }).map({ VUser(user: $0, context: moc) }).first
            if let user = vUser {
                user.googleCalendarId = text
                UserSubmitter.submit([user], requestMethod: .put)
            }
        } else {
            if let value = text, let time = Double(value) {
                let user: User? = DataFetcher().getEntity(moc: moc, predicates: [.skipDeleted])
                let vUser = [user].compactMap({ $0 }).map({ VUser(user: $0, context: moc) }).first
                if let user = vUser {
                    user.sheetTimeOffset = time
                    UserSubmitter.submit([user], requestMethod: .put)
                }
            } else {
                show(message: AppText.Settings.sheetTimeOffsetError)
            }
        }
	}

	private func setup() {
		tableView.register(cells: [LabelTextFieldCell.identifier, GoogleSignedInCell.identifier, Cells.GoogleCell])
        tableView.registerBasicHeaderView()
        tableView.registerTextFooterView()
		tableView.reloadData()
        title = AppText.Settings.title
	}
}
