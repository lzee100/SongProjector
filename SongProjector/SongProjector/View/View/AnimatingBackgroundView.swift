//
//  AnimatingBackgroundView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 07/09/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit


class AnimatingBackgroundView: UIView, AnimatedComponentDelegate {
	
	var timer: Timer?
	var components: [AnimatedComponent] = []
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
			self.checkComponents()
		})
		backgroundColor = UIColor(hex: "#cff2ff")
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func addComponents(_ amount: Int) {
		for _ in 1...amount {
			components.append(AnimatedComponent(superView: self, delegate: self))
		}
	}
	
	func didDie(component: AnimatedComponent) {
		self.components.removeAll(where: { $0 === component })
	}
	
	func checkComponents() {
		if components.count < 13 {
			addComponents(Int.random(in: 2...8))
		}
	}
	
}

protocol AnimatedComponentDelegate {
	func didDie(component: AnimatedComponent)
}

class AnimatedComponent: UIView {
	
	private var moveTimer: Timer?
	private var lifeTime: Timer?
	private var delegate: AnimatedComponentDelegate?
	private var lifeSpan: TimeInterval!
	private var customAlpha: CGFloat!
	private var randomX: CGFloat!
	private var randomY: CGFloat!
	private var colors: [UIColor] = [UIColor(hex: "#a62103") ?? .red]

	private var scale: CGFloat = 0

	convenience init(superView: UIView, delegate: AnimatedComponentDelegate) {
		let lifeSpan = TimeInterval.random(in: 20...80)
		let randomLenght: CGFloat = CGFloat.random(in: (CGFloat(lifeSpan) * 6)...(CGFloat(lifeSpan) * 15))
		
		let boundries = UIScreen.main.bounds
		let randomX = CGFloat.random(in: 0...boundries.width)
		let randomY = CGFloat.random(in: 0...boundries.height)

		self.init(frame: CGRect(x: randomX, y: randomY, width: randomLenght, height: randomLenght))
		
		self.delegate = delegate
		self.lifeSpan = lifeSpan
		customAlpha = 5 / CGFloat(lifeSpan)
		self.lifeTime = Timer.scheduledTimer(withTimeInterval: lifeSpan, repeats: false, block: { (_) in
			self.die()
		})
		backgroundColor = colors[Int.random(in: 0..<colors.count)]
		alpha = 8 / CGFloat(lifeSpan)

		self.randomX = randomX
		self.randomY = randomY
		self.transform = CGAffineTransform(scaleX: 0, y: 0)
		superView.addSubview(self)
		startAnimation()
		animateMovement()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		layer.cornerRadius = bounds.width > bounds.height ? bounds.width / 2 : bounds.height / 2
	}
	
	private func startAnimation() {
		UIView.animate(withDuration: lifeSpan / 2, delay: 0, options: [.repeat, .autoreverse], animations: { [weak self] in
			guard let `self` = self else {
				return
			}
			self.scale = self.scale < 0.5 ? CGFloat.random(in: 0.5...1) : CGFloat.random(in: 0...0.5)
			self.alpha = self.customAlpha
			self.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
		}, completion: nil)
	}
	
	private func animateMovement() {
		move()
		moveTimer = Timer.scheduledTimer(withTimeInterval: lifeSpan / 2, repeats: false, block: { (_) in
			self.move()
		})
	}
	
	private func move() {
		let randomX = Bool.random() ? self.frame.origin.x - CGFloat.random(in: 10...25) : self.frame.origin.x + CGFloat.random(in: 10...25)
		let randomY = Bool.random() ? self.frame.origin.y - CGFloat.random(in: 10...25) : self.frame.origin.y + CGFloat.random(in: 10...25)
		let newCenter = CGPoint(x: randomX, y: randomY)
		
		UIView.animate(withDuration: lifeSpan / 2) {
			self.layer.position = newCenter
		}
	}
	
	private func die() {
		removeFromSuperview()
		delegate?.didDie(component: self)
	}
	
}
