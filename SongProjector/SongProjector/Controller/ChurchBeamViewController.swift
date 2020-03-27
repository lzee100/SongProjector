//
//  ChurchBeamViewController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UserNotifications
import UIKit
import CoreData


class ChurchBeamViewController: UIViewController, RequestObserver {
	
	
	
	// MARK: - Private properties
	
	private var animator: UIViewPropertyAnimator!
	private var timer: Timer?
	private var errorView: ErrorView?
	
	
	
	// MARK: properties
	
	var requesterId: String {
		return "ChurchBeamViewController"
	}
	var requesters: [RequesterType] {
		return []
	}
	var shouldRemoveObserversOnDissappear: Bool {
		return true
	}
	
	// MARK: UIViewController functions

    override func viewDidLoad() {
        super.viewDidLoad()
//		let iv = AnimatingBackgroundView(frame: view.bounds)
//		iv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//		self.view.addSubview(iv)
//		self.view.sendSubviewToBackiv)
//		self.view.bringSubviewToFront(toFront: iv)

		animator = UIViewPropertyAnimator(duration: 0.4, curve: .easeOut) { [errorView] in
			errorView?.center.x = -((errorView?.frame.height ?? 0) / 2)
		}
		view.backgroundColor = themeWhiteBlackBackground
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		requesters.forEach({ $0.addObserver(self) })
		print("################")
		print(self)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if shouldRemoveObserversOnDissappear {
			requesters.forEach({ $0.removeObserver(self) })
		}
	}
	
	// MARK: Public functions
	
	func showLoader() {
		Queues.main.async {
			let loadingView = LoadingView(frame: self.view.bounds)
			loadingView.alpha = 0
			loadingView.animator.startAnimating()
			self.view.addSubview(loadingView)
			self.view.bringSubviewToFront(loadingView)
			UIView.animate(withDuration: 0.1, animations: {
				loadingView.alpha = 0.3
			})
		}
	}
	
	func hideLoader() {
		UIView.animate(withDuration: 0.1, animations: {
			self.view.subviews.first(where: { $0 is LoadingView })?.alpha = 0
		}) { _ in
			self.view.subviews.first(where: { $0 is LoadingView })?.removeFromSuperview()
		}
	}
	
	func show(message: String) {
		createView(message: message)
	}
    

	func show(error: ResponseType) {
		switch error {
		case .error(let response, let error):
			let status = response?.statusCode.stringValue ?? "no status code"
			let errMessage = error?.localizedDescription ?? "no message"
			let message = "status: \(status):\n\(errMessage)"
			createView(message: message)
		default:
			return
		}
	}
	
	func handleRequestFinish(requesterId: String, result: AnyObject?) {
		
	}
	
	
	
	// MARK: RequestObserver functions
	
	func requesterDidStart() {
		showLoader()
	}
	
	func requestDidFinish(requesterID: String, response: ResponseType, result: AnyObject?) {
		Queues.main.async {
			self.hideLoader()
			switch response {
			case .error(_, _): self.show(error: response)
			case .OK(_): self.handleRequestFinish(requesterId: requesterID, result: result)
			}
		}
	}
	
	func showAlertWith(title: String?, message: String, actions: [UIAlertAction]) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		actions.forEach({ alert.addAction($0) })
		self.present(alert, animated: true)
	}
	
	// MARK: Private functions
	
	private func createView(message: String) {
		let content = UNMutableNotificationContent()
		content.body = message
		content.sound = .default
		let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
		UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
	}
	
}
