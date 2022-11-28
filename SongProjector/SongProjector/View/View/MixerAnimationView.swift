//
//  MixerAnimationView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 21/10/2018.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class MixerAnimationViewNew: UIView {
    
    let iconImageView = UIImageView()
    var timer: Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        iconImageView.image = UIImage(named: "Speaker")
        iconImageView.tintColor = .white
        addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        iconImageView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func startPlay() {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(animate), userInfo: nil, repeats: true)
    }
    
    func stopPlay() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func animate() {
        self.iconImageView.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.4, options: []) { [weak self] in
            guard let self = self else { return }
            self.iconImageView.transform = .identity
        } completion: { _ in }
    }
}


class MixerAnimationView: UIView {
	
	@IBOutlet var mixerAnimationView: UIView!
	
	@IBOutlet var barOne: UIView!
	@IBOutlet var barTwo: UIView!
	@IBOutlet var barThree: UIView!
	@IBOutlet var barFour: UIView!
	@IBOutlet var barFive: UIView!
	
	@IBOutlet var barOneTopConstraint: NSLayoutConstraint!
	@IBOutlet var barTwoTopConstraint: NSLayoutConstraint!
	@IBOutlet var barThreeTopConstraint: NSLayoutConstraint!
	@IBOutlet var barFourTopConstraint: NSLayoutConstraint!
	@IBOutlet var barFiveTopConstraint: NSLayoutConstraint!
	
	
	// MARK: - Private Properties
	
	private var timer: Timer?
	
	private var bars: [UIView] {
		return [barOne, barTwo, barThree, barFour, barFive]
	}
	
	private var barConstraints: [NSLayoutConstraint] {
		return [barOneTopConstraint, barTwoTopConstraint, barThreeTopConstraint, barFourTopConstraint, barFiveTopConstraint]
	}
	
	private var maxHeight: CGFloat {
		return bounds.height
	}
	
    
    // MARK: - Properties
    
    var isPlaying: Bool {
        return timer != nil
    }
    var mixerColor: UIColor = .clear
	
	
	// MARK: - UIView Functions

	
    override init(frame: CGRect) {
		super.init(frame: frame)
		customInit()
	}
	
    convenience init(frame: CGRect, mixerColor: UIColor) {
        self.init(frame: frame)
        self.mixerColor = mixerColor
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		customInit()
	}
	
	
	
	// MARK: - Public Functions

	func play() {
        bars.forEach({ $0.backgroundColor = mixerColor })
		timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true, block: { [weak self] _ in
            self?.barConstraints.forEach({
				let height = self?.getRandomHeight(current: $0.constant)
				$0.constant = height ?? 0
			})
			UIView.animate(withDuration: 0.7, animations: { [weak self]  in
				self?.layoutIfNeeded()
			})
		})
	}
	
	func stop() {
		timer?.invalidate()
        timer = nil
		self.barConstraints.forEach({
			$0.constant = maxHeight
		})
		UIView.animate(withDuration: 1, animations: { [weak self] in
			self?.layoutIfNeeded()
		})
	}
	
	
	// MARK: - Private Functions
	
	private func customInit() {
		Bundle.main.loadNibNamed("MixerAnimationView", owner: self, options: [:])
		mixerAnimationView.frame = self.bounds
		mixerAnimationView.backgroundColor = .clear
		addSubview(mixerAnimationView)
		bars.forEach({ $0.backgroundColor = mixerColor })
		barConstraints.forEach({ $0.constant = maxHeight })
	}
	
	private func getRandomHeight(current: CGFloat) -> CGFloat {
		let min = self.bounds.height * 0.3
        guard min > 0 else { return 0 }
		var height = CGFloat.random(in: 0..<maxHeight - min)
		while height == current {
			height = CGFloat.random(in: 0..<maxHeight - min)
		}
		return height
	}
	
}
