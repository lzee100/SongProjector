//
//  LyricsViewController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22-06-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class LyricsViewController: UIViewController {

	@IBOutlet var cancelButton: UIBarButtonItem!
	@IBOutlet var borderView: UIView!
	@IBOutlet var doneButton: UIBarButtonItem!
	@IBOutlet var lyricsTextView: UITextView!
	
	var text = ""
	var didPressDone: ((String) -> Void)?
	
	override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = themeWhiteBlackBackground
		cancelButton.title = Text.Actions.cancel
		doneButton.title = Text.Actions.done
		borderView.layer.borderWidth = 2
		borderView.layer.cornerRadius = 5
		borderView.layer.borderColor = themeHighlighted.cgColor
		
		lyricsTextView.textColor = themeWhiteBlackTextColor
		
		lyricsTextView.text = text
		
		lyricsTextView.text = """
		Cuppy Cake Song
		
		You're my honeybunch, sugar plum
		Pumpy-umpy-umpkin
		You're my sweetie pie
		You're my cuppycake, gumdrop
		Snoogums, boogums, you're
		The apple of my eye
		
		And I love you so
		And I want you to know
		That I'm always be right here
		And I want to sing
		Sweet songs to you
		Because you are so dear...
		"""
    }

	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true)
	}
	
	@IBAction func donePressed(_ sender: UIBarButtonItem) {
		if let text = lyricsTextView.text {
			didPressDone?(text)
		}
		self.dismiss(animated: true)
	}
	
	
}
