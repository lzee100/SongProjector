//
//  SplashScreen.swift
//  SongViewer
//
//  Created by Leo van der Zee on 05-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit

// authentication proces

// 1: check for user in local storage
// 2: if user found, update data and start app
// 3: if not found, check usertoken and appId
// 4: if correct: fetch user and start app
// 5: if incorrect: show message has install other phone

class SplashScreen: ChurchBeamViewController {
	
	private var isRegistered: Bool {
		return CoreUser.getEntities().first != nil
	}
	
	private var token: UserTokenAndAppInstallToken {
		return UserTokenAndAppInstallToken(userToken: AccountStore.icloudID, appInstallToken: UIDevice.current.identifierForVendor!.uuidString)
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		UserFetcher.addObserver(self)
		InitFetcher.addObserver(self)
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if isRegistered {
			UserFetcher.fetch(force: true)
		} else {
			fetchIcloudId()
		}
	}
	
	
	
	private func fetchIcloudId() {
		let fetchIcloudIdOperation = FetchIdOperation()
		
		let finishOperationIcloudId = BlockOperation {
			if fetchIcloudIdOperation.isSuccess {
				Queues.main.async {
					self.getUserInit()
				}
			} else {
				Queues.main.async {
					let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: Text.Actions.ok, style: .default, handler: nil))
					self.present(alert, animated: true, completion: nil)
				}
			}
		}
		
		let operations : [Foundation.Operation] = [fetchIcloudIdOperation, finishOperationIcloudId]
		Operation.dependenciesInOrder(operations)
		Operation.Queue.addOperations(operations, waitUntilFinished: true)
	}
	
	func getUserInit() {
		print(token)
		InitFetcher.request(userTokenAndAppToken: token, method: .get)
	}
	
	func showIntro() {
		let intro = Storyboard.Intro.instantiateViewController(withIdentifier: IntroPageViewContainer.identifier) as! IntroPageViewContainer
		intro.setup(controllers: IntroPageViewContainer.introControllers())
		self.present(intro, animated: true, completion: nil)
	}
	
	override func handleRequestFinish(result: AnyObject?) {
		Queues.main.async {
			if let users = result as? [User]{
				if users.first?.appInstallToken == self.token.appInstallToken {
					self.performSegue(withIdentifier: "showApp", sender: self)
				} else {
					self.showReInstallationPopUp()
					self.deleteAllData()
				}
			}
		}
	}
	
	override func show(error: ResponseType, time: TimeInterval) {
		switch error {
		case .error(let response, _):
			switch response?.statusCode {
			case .some(400):
				Queues.main.async {
					self.showIntro()
				}
			case .some(424):
				Queues.main.async {
					self.showReInstallationPopUp()
					self.deleteAllData()
				}
			default: super.show(error: error, time: time)
			}
		default:
			return
		}
	}
	
	private func deleteAllData() {
		let entities = CoreEntity.getEntities()
		entities.forEach({ $0.delete(false) })
		moc.performAndWait {
			do {
				try moc.save()
			} catch {
				print(error)
			}
		}
	}
	
	private func showReInstallationPopUp() {
		let alert = UIAlertController(title: "(Her)installatie", message: "We zien dat je al een installatie hebt gedaan. Mocht je Churchbeam al geinstalleerd hebben op een ander apparaat zal die installatie ongeldig worden. Wil je Churchbeam installeren op dit apparaat?", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Installeer hierop", style: .default, handler: { _ in
			print("installeer hierop")
			InitFetcher.request(userTokenAndAppToken: self.token, method: .post)
		}))
		alert.addAction((UIAlertAction(title: "Annuleer", style: .cancel, handler: { _ in
			print("annuleer")
		})))
		self.present(alert, animated: true, completion: nil)
	}

}
