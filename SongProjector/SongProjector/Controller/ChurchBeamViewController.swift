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


class ChurchBeamViewController: UIViewController, RequesterObserver1 {
    
    
    
    // MARK: - Private properties
    
    private var animator: UIViewPropertyAnimator!
    private var timer: Timer?
    
    // MARK: properties
    
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
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .whiteColor
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance

        navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = themeWhiteBlackBackground
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requesters.forEach({ $0.addObserver(self) })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if shouldRemoveObserversOnDissappear {
            requesters.forEach({ $0.removeObserver(self) })
        }
    }
    
    // MARK: Public functions
    
    func showProgress(requester: RequesterBase) {
        let progressController = Storyboard.MainStoryboard.instantiateViewController(identifier: ProgressController.identifier) as! ProgressController
        progressController.modalPresentationStyle = .overFullScreen
        progressController.observe(requester: requester)
        self.present(progressController, animated: false)
    }
    
    func showLoader() {
        guard self.view.subviews.first(where: { $0 is LoadingView }) == nil else { return }
        Queues.main.async {
            self.view.layoutIfNeeded()
            let loadingView = LoadingView(frame: self.view.bounds)
            loadingView.backgroundColor = .blackColor
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
        self.view.subviews.first(where: { $0 is LoadingView })?.removeFromSuperview()
    }
    
//    func show(message: String) {
//        createView(message: message)
//    }
    
    func show(_ requestError: RequestError) {
        createView(message: requestError.localizedDescription)
    }
    
    func show(message: String) {
        createView(message: message)
    }

    
    func update() {
        
    }
    
    
    // MARK: RequestObserver functions
    
    func requesterDidStart() {
        showLoader()
        navigationItem.rightBarButtonItems?.forEach({ $0.isEnabled = false })
    }
    
    func handleRequestFinish(requesterId: String, result: Any?) {
        
    }
     
    func requesterDidFinish(requester: RequesterBase, result: RequestResult, isPartial: Bool) {
        Queues.main.async {
            self.navigationItem.rightBarButtonItems?.forEach({ $0.isEnabled = true })
            self.hideLoader()
            switch result {
            case .failed(let error): self.show(error)
            case .success(let result): self.handleRequestFinish(requesterId: requester.id, result: result)
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
