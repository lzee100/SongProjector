//
//  PopUpViewController.swift
//  Parro
//
//  Created by Leo van der Zee on 25/06/2019.
//  Copyright © 2019 Topicus. All rights reserved.
//

import UIKit

protocol PopUpViewControllerDelegate: AnyObject {
	func didPerformAction(controller: PopUpViewController, action: PopUpViewControllerAction, store: AnyObject?, isCheckBoxSelected: Bool?)
}

enum PopUpViewControllerAction {
	case leftButton
	case rightButton
	case centerButton
	case tapOutside
}

class PopUpViewController: ChurchBeamViewController {
	
	@IBOutlet var containerView: UIView!
	@IBOutlet var darkBackgroundView: UIView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var contentLabel: UILabel!
	@IBOutlet var checkBoxView: UIView!
	@IBOutlet var checkBoxExplainLabel: UILabel!
	@IBOutlet var lineView: UIView!
	@IBOutlet var bottomView: UIView!
	
	@IBOutlet var buttonLeft: UIButton!
	@IBOutlet var buttonRight: UIButton!
	@IBOutlet var oneCenterButton: UIButton!
	
	@IBOutlet var checkBoxTopConstraint: NSLayoutConstraint!
	@IBOutlet var checkBoxHeightConstraint: NSLayoutConstraint!
	@IBOutlet var containerViewTopConstraint: NSLayoutConstraint!
	@IBOutlet var containerViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet var contentTopConstraint: NSLayoutConstraint!
	@IBOutlet var titleHeightConstraint: NSLayoutConstraint!
	@IBOutlet var titleTopConstraint: NSLayoutConstraint!
	
	enum PopOverPresentationStyle {
		case applicationScreen
		case viewControllerScreen
	}
	
	private let margin: CGFloat = 20
	private weak var delegate: PopUpViewControllerDelegate?
	
	// if you need any object reference in delegate
	var store: AnyObject?
	
	var titleText: String? = nil
	var contentText: String? = nil
	var buttonLeftText: String? = nil
	var buttonRightText: String? = nil
	var buttonCenterText: String? = nil
	var checkBoxExplainText: String? = nil
	var checkBoxDefaultValue: Bool = false
	
	
	@discardableResult
	static func showWithLeftRightButtons(title: String?, content: String?, buttonLeftTitle: String, buttonRightTitle: String, checkBoxExpainText: String? = nil, checkBoxDefaultValue: Bool? = false, store: AnyObject? = nil, parent: UIViewController, delegate: PopUpViewControllerDelegate, style: PopOverPresentationStyle) -> PopUpViewController {
		let vc = Storyboard.MainStoryboard.instantiateViewController(withIdentifier: "PopUpViewController") as! PopUpViewController
		vc.titleText = title
		vc.contentText = content
		vc.buttonLeftText = buttonLeftTitle
		vc.buttonRightText = buttonRightTitle
		vc.checkBoxExplainText = checkBoxExpainText
		vc.checkBoxDefaultValue = checkBoxDefaultValue ?? false
		vc.store = store
		vc.delegate = delegate
		if style == .applicationScreen {
			vc.modalPresentationStyle = .overFullScreen
		} else {
			vc.modalPresentationStyle = .overCurrentContext
		}
		parent.present(vc, animated: false) {
			vc.show()
		}
		return vc
	}
	
	@discardableResult
	static func showWithCenterButton(title: String?, content: String?, buttonCenterTitle: String, checkBoxExpainText: String? = nil, checkBoxDefaultValue: Bool? = false, store: AnyObject? = nil, parent: UIViewController, delegate: PopUpViewControllerDelegate, style: PopOverPresentationStyle) -> PopUpViewController {
		let vc = Storyboard.MainStoryboard.instantiateViewController(withIdentifier: "PopUpViewController") as! PopUpViewController
		vc.titleText = title
		vc.contentText = content
		vc.buttonCenterText = buttonCenterTitle
		vc.checkBoxExplainText = checkBoxExpainText
		vc.store = store
		vc.delegate = delegate
		vc.checkBoxDefaultValue = checkBoxDefaultValue ?? false
		if style == .applicationScreen {
			vc.modalPresentationStyle = .overFullScreen
		} else {
			vc.modalPresentationStyle = .currentContext
		}
		parent.present(vc, animated: false) {
			vc.show()
		}
		return vc
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupWith(title: titleText, content: contentText, buttonLeftTitle: buttonLeftText, buttonRightTitle: buttonRightText, buttonCenterTitle: buttonCenterText, checkBoxExpainText: checkBoxExplainText, checkBoxDefaultValue: checkBoxDefaultValue, store: store, delegate: delegate!)
		
		checkBoxView.ignoresInvertColors = true
		
		let tab = UITapGestureRecognizer(target: self, action: #selector(didTabOutsideContainer))
		tab.numberOfTapsRequired = 1
		darkBackgroundView.addGestureRecognizer(tab)
		titleLabel.textColor = .blackColor
		contentLabel.textColor = .blackColor
		checkBoxExplainLabel.textColor = .blackColor
		darkBackgroundView.alpha = 0
		containerViewTopConstraint.constant = 0
		bottomView.isHidden = UIDevice.current.userInterfaceIdiom == .pad
		styleButtons()
		containerViewWidthConstraint.constant = min(view.bounds.width, 450)
		self.view.layoutIfNeeded()
	}
	
	func setupWith(title: String?, content: String?, buttonLeftTitle: String? = nil, buttonRightTitle: String? = nil, buttonCenterTitle: String? = nil, checkBoxExpainText: String? = nil, checkBoxDefaultValue: Bool? = false, store: AnyObject? = nil, delegate: PopUpViewControllerDelegate) {
		
		titleLabel.text = title
		
		if let title = title {
			view.layoutIfNeeded()
			let titleHeight = title.height(withConstrainedWidth: view.bounds.width - (margin * 2), font: titleLabel.font)
			titleHeightConstraint.constant = titleHeight
			titleLabel.isHidden = false
			titleTopConstraint.constant = margin - 8
			contentTopConstraint.constant = 0
		} else {
			titleHeightConstraint.constant = 0
			titleTopConstraint.constant = 0
			titleLabel.isHidden = true
			contentTopConstraint.constant = margin - 3
		}
		
		
		contentLabel.text = content
		buttonLeft.setTitle(buttonLeftTitle, for: .normal)
		buttonRight.setTitle(buttonRightTitle, for: .normal)
		oneCenterButton.isHidden = buttonCenterTitle != nil
		buttonLeft.isHidden = buttonCenterTitle != nil
		buttonRight.isHidden = buttonCenterTitle != nil
		oneCenterButton.setTitle(buttonCenterTitle, for: UIControl.State())
		checkBoxExplainLabel.text = checkBoxExpainText
		oneCenterButton.isHidden = buttonCenterTitle == nil
		self.store = store
		self.delegate = delegate
		
		if checkBoxExpainText == nil {
			checkBoxTopConstraint.constant = 0
			checkBoxHeightConstraint.constant = 0
			checkBoxExplainLabel.isHidden = true
			checkBoxView.isHidden = true
		}
	}
	
	func show() {
		let iphoneXMargin: CGFloat = Device.isXtype ? 34 : 0
		self.view.layoutIfNeeded()
		if UIDevice.current.userInterfaceIdiom == .pad {
			let centerContainer = -containerView.bounds.height / 2
			let centerView = -view.bounds.height / 2
			containerViewTopConstraint.constant = (centerContainer + centerView)
			self.view.layoutIfNeeded()
		} else {
			containerViewTopConstraint.constant = -containerView.bounds.height - iphoneXMargin
		}
		self.styleRoundCornersContainer()
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options:
			UIView.AnimationOptions.curveEaseOut, animations: {
				self.darkBackgroundView.alpha = 0.3
				self.view.layoutIfNeeded()
		})
	}
	
	func hide(completion: @escaping (() -> Void)) {
		if UIDevice.current.userInterfaceIdiom == .phone {
			containerViewTopConstraint.constant = 0
		}
		UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
			self.view.layoutIfNeeded()
			self.view.alpha = 0
		}) { [weak self] (_) in
			self?.dismiss(animated: false, completion: {
				completion()
			})
		}
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
			if UIDevice.current.userInterfaceIdiom == .pad {
				let centerContainer = -self.containerView.bounds.height / 2
				let centerView = -self.view.bounds.height / 2
				self.containerViewTopConstraint.constant = (centerContainer + centerView)
			}
		}, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
			
		})
		super.viewWillTransition(to: size, with: coordinator)
	}
	
	
	@objc private func didTabOutsideContainer() {
		hide {
//			let checkBoxValue = self.checkBoxView.isHidden ? nil : self.checkBoxView.isEnabled
			self.delegate?.didPerformAction(controller: self, action: .tapOutside, store: self.store, isCheckBoxSelected: false)
		}
	}
	
	private func styleButtons() {
		buttonLeft.backgroundColor = UIColor.clear
		buttonLeft.layer.borderWidth = 2
		buttonLeft.layer.borderColor = UIColor.blackColor.cgColor
		buttonLeft.layer.cornerRadius = 5
		buttonLeft.ignoresInvertColors = true
		buttonLeft.setTitleColor(.blackColor, for: .normal)
		
		buttonRight.backgroundColor = .blackColor
		buttonRight.layer.cornerRadius = 5
		buttonRight.setTitleColor(.whiteColor, for: .normal)
		buttonRight.ignoresInvertColors = true
		
		oneCenterButton.backgroundColor = .blackColor
		oneCenterButton.layer.cornerRadius = 5
		oneCenterButton.setTitleColor(.whiteColor, for: .normal)
		oneCenterButton.ignoresInvertColors = true
	}
	
	private func styleRoundCornersContainer() {
		guard UIDevice.current.userInterfaceIdiom == .phone else {
			self.containerView.layer.cornerRadius = CGFloat(12)
			self.containerView.clipsToBounds = true
			return
		}
		
		if #available(iOS 11.0, *) {
			self.containerView.layer.cornerRadius = CGFloat(12)
			self.containerView.clipsToBounds = true
			self.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		} else {
			let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: containerView.bounds.width, height: self.view.bounds.height), byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 12, height: 12))
			let maskLayer = CAShapeLayer()
			maskLayer.frame = self.view.bounds
			maskLayer.path = path.cgPath
			containerView.layer.mask = maskLayer
		}
	}
	
	@IBAction func didPressCheckBox(_ sender: UIButton) {
//		checkBoxView.isEnabled = !checkBoxView.isEnabled
	}
	
	@IBAction func didPressLeftButton(_ sender: UIButton) {
		hide {
//			let checkBoxValue = self.checkBoxView.isHidden ? nil : self.checkBoxView.isEnabled
			self.delegate?.didPerformAction(controller: self, action: .leftButton, store: self.store, isCheckBoxSelected: false)
		}
	}
	
	@IBAction func didPressRightButton(_ sender: UIButton) {
		hide {
//			let checkBoxValue = self.checkBoxView.isHidden ? nil : self.checkBoxView.isEnabled
			self.delegate?.didPerformAction(controller: self, action: .rightButton, store: self.store, isCheckBoxSelected: false)
		}
	}
	
	@IBAction func didPressCenterButton(_ sender: UIButton) {
		hide {
//			let checkBoxValue = self.checkBoxView.isHidden ? nil : self.checkBoxView.isEnabled
			self.delegate?.didPerformAction(controller: self, action: .centerButton, store: self.store, isCheckBoxSelected: false)
		}
	}
}
