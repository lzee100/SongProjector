//
//  SheetController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

class SheetController: UIViewController {
	
	@IBOutlet var titleSheet: UILabel!
	@IBOutlet var lyricsSheet: UITextView!
	
	
	
	var songTitle: String? { didSet { update() } }
	var lyrics: String? { didSet { update() } }
	var viewFrame: CGRect?

    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	override func viewDidLayoutSubviews() {
		if let viewFrame = viewFrame {
			view.frame = viewFrame
		}
	}
	
	func setView(_ view: CGRect) {
		viewFrame = view
		self.view.frame = view
	}
	
	private func update() {
		titleSheet.text = songTitle
		lyricsSheet.text = lyrics
	}
    
	func asImage() -> UIImage {
		return view.asImage()
	}

}
