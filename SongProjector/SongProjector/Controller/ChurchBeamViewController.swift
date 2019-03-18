//
//  ChurchBeamViewController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/01/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

class ChurchBeamViewController: UIViewController, RequestObserver {
	
	
	// MARK: - Private properties
	
	private var animator: UIViewPropertyAnimator!
	private var timer: Timer?
	private var errorView: ErrorView?
	
	
	
	// MARK: properties
	
	var requesterId: String {
		return "ChurchBeamViewController"
	}
	
	
	
	// MARK: UIViewController functions

    override func viewDidLoad() {
        super.viewDidLoad()
		
		animator = UIViewPropertyAnimator(duration: 0.4, curve: .easeOut) { [errorView] in
			errorView?.center.x = -((errorView?.frame.height ?? 0) / 2)
		}

    }
	
	
	// MARK: Public functions
	
	func showLoader() {
		let loadingView = LoadingView(frame: view.bounds)
		loadingView.alpha = 0
		loadingView.animator.startAnimating()
		view.addSubview(loadingView)
		view.bringSubview(toFront: loadingView)
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
	
	func show(message: String, time: TimeInterval = 4.0) {
		createView(message: message, time: time)
	}
    

	func show(error: ResponseType, time: TimeInterval = 4.0) {
		switch error {
		case .error(let response, let error):
			let status = response?.statusCode.stringValue() ?? "no status code"
			let errMessage = error?.localizedDescription ?? "no message"
			let message = "status: \(status):/n\(errMessage)"
			createView(message: message, time: time)
		default:
			return
		}
	}
	
	func handleRequestFinish(result: AnyObject?) {
		
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
			case .OK(_): self.handleRequestFinish(result: result)
			}
		}
	}
	
	
	
	// MARK: Private functions
	
	private func createView(message: String, time: TimeInterval) {
		let height = message.height(withConstrainedWidth: (self.view.bounds.width * 0.90) - 16, font: UIFont.systemFont(ofSize: 14)) + 16
		let frame = CGRect(x: (self.view.bounds.width * 0.1) / 2, y: -height, width: (self.view.bounds.width * 0.90), height: height)
		
		errorView = ErrorView(frame: frame, message: message, height: height)
		
		let swipe = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
		errorView?.addGestureRecognizer(swipe)
		
		UIApplication.shared.keyWindow?.addSubview(errorView!)
		let err = errorView!.frame
		UIView.animate(withDuration: 0.4) {
			self.errorView!.frame = CGRect(x: err.minX, y: 20, width: err.width, height: err.height)
		}
		timer = Timer.scheduledTimer(withTimeInterval: time, repeats: false, block: { _ in
			self.hideView()
		})
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
	
	func showAlert(title: String? = nil, message: String? = nil, actionOne: String, handler: ((UIAlertAction) -> Void)? = nil, actionTwo: String? = nil, handlerTwo: ((UIAlertAction) -> Void)? = nil) {
		
		let alertMessage = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
		
		let action = UIAlertAction(title:actionOne, style: UIAlertActionStyle.default, handler: handler)
		alertMessage.addAction(action)

		if let actionTwo = actionTwo {
			let addAction = UIAlertAction(title:actionTwo, style: UIAlertActionStyle.default, handler: handlerTwo)
			alertMessage.addAction(addAction)
		}
		
		self.present(alertMessage, animated: true, completion: nil)
		
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
