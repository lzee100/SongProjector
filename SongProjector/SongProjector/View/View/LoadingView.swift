//
//  LoadingView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01/02/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

class LoadingView: UIView {

	@IBOutlet var loadingView: UIView!
	@IBOutlet var animator: UIActivityIndicatorView!
    @IBOutlet var squareView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        squareView.layer.cornerRadius = 7
    }
    
    override func awakeFromNib() {
		super.awakeFromNib()
		backgroundColor = .blackColor
		alpha = 0.3
		animator.startAnimating()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		customInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		customInit()
	}
	
	func customInit() {
		Bundle.main.loadNibNamed("LoadingView", owner: self, options: [:])
		loadingView.frame = self.frame
		addSubview(loadingView)
        let effect = self.traitCollection.userInterfaceStyle == .dark ? UIBlurEffect(style: .light) : UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: effect)
        squareView.addSubview(effectView)
        squareView.leadingAnchor.constraint(equalTo: effectView.leadingAnchor).isActive = true
        squareView.topAnchor.constraint(equalTo: effectView.topAnchor).isActive = true
        squareView.trailingAnchor.constraint(equalTo: effectView.trailingAnchor).isActive = true
        squareView.bottomAnchor.constraint(equalTo: effectView.bottomAnchor).isActive = true
		backgroundColor = .blackColor
        animator.tintColor = .blackColor
		alpha = 0.3
	}
}
