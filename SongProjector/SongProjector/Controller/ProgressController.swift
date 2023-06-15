//
//  ProgressController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/11/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import UIKit

class ProgressController: UIViewController {
    
    static let identifier = "ProgressController"
    
    @IBOutlet var progressView: CircleProgressView!
    @IBOutlet var checkView: CheckView!
    @IBOutlet var errorView: ErrorAnimationView!
    @IBOutlet var progressLabel: UILabel!

    private var effectView: UIVisualEffectView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        progressView.strokeWidth = 7
        progressView.progressColor = .green1
        progressLabel.text = ""
        progressLabel.font = .xxNormalBold
        progressLabel.textColor = .white
        let effect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: effect)
        view.addSubview(effectView)
        view.sendSubviewToBack(effectView)
        NSLayoutConstraint.activate([
            effectView.topAnchor.constraint(equalTo: view.topAnchor),
            effectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            effectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            effectView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        effectView.alpha = 1
        effectView.translatesAutoresizingMaskIntoConstraints = false
        self.effectView = effectView
        view.layoutIfNeeded()
        errorView.isHidden = true
        checkView.isHidden = true
        checkView.lineWidth = 6
    }
    
    func observe(requester: RequesterBase) {
        requester.addObserver(self)
    }
    
    fileprivate func setProgress(percentage: CGFloat) {
        print(percentage)
        progressView.setProgress(percentage: percentage * 100)
        progressLabel.text = "\(Double(percentage * 100).oneDecimal)"
    }
    
    fileprivate func finishAnimation(succes: Bool, completion: @escaping (() -> Void)) {
        progressLabel.isHidden = true
        if succes {
            checkView.isHidden = false
            checkView.drawLine(skipAnimation: false)
        } else {
            errorView.isHidden = false
            errorView.drawLine(skipAnimation: false)
        }
        Queues.main.asyncAfter(deadline: .now() + 0.8) {
            completion()
        }
    }
    
    
}

extension ProgressController: RequesterObserver1 {
    
    func requesterDidProgress(progress: CGFloat) {
        setProgress(percentage: progress)
    }
    
    func requesterDidFinish(requester: RequesterBase, result: RequestResult, isPartial: Bool) {
        finishAnimation(succes: result.isSuccess) {
            if let presentingViewController = self.presentingViewController?.unwrap() as? ChurchBeamViewController {
                presentingViewController.requesterDidFinish(requester: requester, result: result, isPartial: isPartial)
            }
            var info: [AnyHashable: Any] = [:]
            info["requester"] = requester
            info["result"] = result
            info["isPartial"] = isPartial
            NotificationCenter.default.post(name: .didFinishRequester, object: nil, userInfo: info)
            requester.removeObserver(self)
        }
    }


}
