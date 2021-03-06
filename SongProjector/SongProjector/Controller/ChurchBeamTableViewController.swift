//
//  ChurchBeamTableViewController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 02/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

class ChurchBeamTableViewController: UITableViewController, RequesterObserver1 {
    
    

	// MARK: - Private properties
	
	private var animator: UIViewPropertyAnimator!
	private var timer: Timer?
	private var errorView: ErrorView?
	
	
	
	// MARK: properties
	
	var requesterId: String {
		return "ChurchBeamViewController"
	}
	var requesters: [RequesterBase] {
		return []
	}
	var shouldRemoveObserversOnDissappear: Bool {
		return true
	}

    deinit {
        requesters.forEach({ $0.removeObserver(self) })
    }
	
	
	// MARK: UIViewController functions
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		animator = UIViewPropertyAnimator(duration: 0.4, curve: .easeOut) { [errorView] in
			errorView?.center.x = -((errorView?.frame.height ?? 0) / 2)
		}
		
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
		let loadingView = LoadingView(frame: view.bounds)
		loadingView.alpha = 0
		loadingView.animator.startAnimating()
		view.addSubview(loadingView)
		view.bringSubviewToFront(loadingView)
		UIView.animate(withDuration: 0.1, animations: {
			loadingView.alpha = 0.3
		})
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
    
    func handleRequestFinish(requesterId: String, result: Any?) {
		
	}
	
    
    
	// MARK: RequestObserver functions
	
	func requesterDidStart() {
		showLoader()
	}
    
    func requesterDidFinish(requester: RequesterBase, result: RequestResult, isPartial: Bool) {
        Queues.main.async {
            self.hideLoader()
            switch result {
            case .failed(let error): self.show(message: error.localizedDescription)
            case .success(let result): self.handleRequestFinish(requesterId: requester.id, result: result)
            }
        }
    }
	
    
	
	// MARK: Private functions
	
	private func createView(message: String) {
		let content = UNMutableNotificationContent()
		content.body = message
		content.sound = .default
		let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
		UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
	}
	
	private func hideView() {
		UIView.animate(withDuration: 0.4, animations: {
			if let err = self.errorView?.frame {
				self.errorView!.frame = CGRect(x: err.minX, y: -err.height, width: err.width, height: err.height)
			}
		}) { _ in
			self.errorView?.removeFromSuperview()
		}
	}
	
	@objc private func handlePan(recognizer:UIPanGestureRecognizer) {
		timer?.invalidate()
		let translation = recognizer.translation(in: self.view)
		
		if let view = recognizer.view as? ErrorView, view.frame.minY <= 20 {
			view.center = CGPoint(x:view.center.x,
								  y:view.center.y + translation.y)
			view.layoutIfNeeded()
			view.titleLabel.center = CGPoint(x:view.bounds.width / 2,
											 y:view.bounds.height / 2)
			recognizer.setTranslation(CGPoint.zero, in: self.view)
		}
		
		if recognizer.state == .ended {
			self.hideView()
		}
	}
	
}
