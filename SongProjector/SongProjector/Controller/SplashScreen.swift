//
//  SplashScreen.swift
//  SongViewer
//
//  Created by Leo van der Zee on 05-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit
import UserNotifications

// authentication proces

// 1: check for user in local storage
// 2: if user found, update data and start app
// 3: if not found, check usertoken and appId
// 4: if correct: fetch user and start app
// 5: if incorrect: show message has install other phone

class SplashScreen: ChurchBeamViewController {
	
	override var requesterId: String {
		return "SplashScreen"
	}
	
	override var requesters: [RequesterType] {
		return [InitSubmitter, UserFetcher]
	}
	
	private var isRegistered: Bool {
		return VUser.list().first != nil
	}
	
	private var token: UserTokenAndAppInstallToken {
		return UserTokenAndAppInstallToken(userToken: AccountStore.icloudID, appInstallToken: UIDevice.current.identifierForVendor!.uuidString)
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(checkAccountStatus), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		checkAccountStatus()
	}
	
	private func fetchIcloudId() {
		let fetchIcloudIdOperation = FetchIdOperation()
		
		let finishOperationIcloudId = BlockOperation {
			if fetchIcloudIdOperation.isSuccess, AccountStore.icloudID != "" {
				Queues.main.async {
					InitSubmitter.request(userTokenAndAppToken: self.token, method: .get, isNewInstall: false)
				}
			} else {
				Queues.main.async {
					let alert = UIAlertController(title: "Log eerst in op icloud onder de instellingen op je iPhone", message: nil, preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: Text.Actions.ok, style: .default, handler: nil))
					self.present(alert, animated: true, completion: nil)
				}
			}
		}
		
		let operations : [Foundation.Operation] = [fetchIcloudIdOperation, finishOperationIcloudId]
		Operation.dependenciesInOrder(operations)
		Operation.Queue.addOperations(operations, waitUntilFinished: true)
	}
	
	@objc func checkAccountStatus(){
		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options: [.alert, .sound])
		{ (granted, error) in
			if self.isRegistered {
				UserFetcher.fetchMe(force: true)
			} else {
				self.fetchIcloudId()
			}
		}
	}
	
	func showIntro() {
		let introNav = Storyboard.Intro.instantiateViewController(withIdentifier: "IntroPageViewContainerNav")
		let controller = introNav.unwrap() as? IntroPageViewContainer
		controller?.setup(controllers: IntroPageViewContainer.introControllers())
		introNav.modalPresentationStyle = .fullScreen
		self.present(introNav, animated: true, completion: nil)
	}
	
	override func requestDidFinish(requesterID: String, response: ResponseType, result: AnyObject?) {
		Queues.main.async {
			self.hideLoader()
			switch response {
			case .error(_, _):
				self.show(error: response)
			case .OK(_):
				Queues.main.async {
					if let users = result as? [VUser], requesterID == UserFetcher.requesterId {
						if users.first?.appInstallToken == self.token.appInstallToken {
							self.performSegue(withIdentifier: "showApp", sender: self)
						} else {
							self.showReInstallationPopUp()
							self.deleteAllData()
						}
					} else if requesterID == InitSubmitter.requesterId && InitSubmitter.requestMethod == .post {
						UserFetcher.fetchMe(force: true)
					}
				}
			}
		}
	}
	
	override func show(error: ResponseType) {
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
			default:
				if isRegistered, VUser.list().first?.appInstallToken == self.token.appInstallToken {
					self.performSegue(withIdentifier: "showApp", sender: self)
				}
				super.show(error: error)
			}
		default:
			return
		}
	}
	
	private func deleteAllData() {
		let entities =  CoreEntity.getEntities()
		Entity.delete(entities: entities, save: false, isBackground: false, completion: { error in
			moc.performAndWait {
				do {
					try moc.save()
				} catch {
					print(error)
				}
			}
		})
	}
	
	private func showReInstallationPopUp() {
		let alert = UIAlertController(title: "(Her)installatie", message: "We zien dat je al een installatie hebt gedaan. Wil je Churchbeam (ook) installeren op dit apparaat? Een extra installatie kost extra geld, een herinstallatie zal betekenen dat je evenveel gaat betalen, daarmee vervalt eventueel een andere installatie als die er nog was.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Herinstalleer", style: .default, handler: { _ in
			print("installeer hierop")
			InitSubmitter.request(userTokenAndAppToken: self.token, method: .post, isNewInstall: false)
		}))
		alert.addAction((UIAlertAction(title: "Nieuwe installatie", style: .cancel, handler: { _ in
			InitSubmitter.request(userTokenAndAppToken: self.token, method: .post, isNewInstall: true)
		})))
		self.present(alert, animated: true, completion: nil)
	}

}
