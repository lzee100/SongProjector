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
	
	override func awakeFromNib() {
		super.awakeFromNib()
		backgroundColor = .black
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

		backgroundColor = .black
		alpha = 0.3
	}
}
