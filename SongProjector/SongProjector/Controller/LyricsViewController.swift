//
//  LyricsViewController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22-06-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

protocol LyricsControllerDelegate {
	func didPressDone(text: String)
}

class LyricsViewController: UIViewController {

	@IBOutlet var cancelButton: UIBarButtonItem!
	@IBOutlet var borderView: UIView!
	@IBOutlet var doneButton: UIBarButtonItem!
	@IBOutlet var lyricsTextView: UITextView!
	
	var text = ""
	var delegate: LyricsControllerDelegate?
	
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
		
//		if lyricsTextView.text == "" {
//			lyricsTextView.text = """
//			Heer, hoe talrijk zijn mijn vijanden
//
//			Heer, hoe talrijk zijn mijn vijanden
//			en velen die opstaan tegen mij.
//			Zij, die spotten en zeggen van mij
//			hij vindt geen hulp bij zijn God.
//
//			Maar U, o Heer bent een schild voor mij
//			mijn Redder en Bevrijder elke dag.
//			Want U, o Heer bent een schild voor mij
//			mijn Redder en Bevrijder elke dag.
//
//			Ik ben niet bang voor tienduizenden mensen
//			die zich stellen rondom mij.
//			Als ik luide roep tot God
//			dan antwoord Hij mij van Zijn heil’ge berg.
//
//			Maar U, o Heer bent een schild voor mij
//			mijn Redder en Bevrijder elke dag.
//			Want U, o Heer bent een schild voor mij
//			mijn Redder en Bevrijder elke dag.
//
//			Heer, hoe talrijk zijn mijn vijanden
//			en velen die opstaan tegen mij.
//			Zij, die spotten en zeggen van mij
//			hij vindt geen hulp bij zijn God.
//
//			Maar U, o Heer bent een schild voor mij
//			mijn Redder en Bevrijder elke dag.
//			Want U, o Heer bent een schild voor mij
//			mijn Redder en Bevrijder elke dag.
//
//			Ik ben niet bang voor tienduizenden mensen
//			die zich stellen rondom mij.
//			Als ik luide roep tot God
//			dan antwoord Hij mij van Zijn heil’ge berg.
//
//			Maar U, o Heer bent een schild voor mij
//			mijn Redder en Bevrijder elke dag.
//			Want U, o Heer bent een schild voor mij
//			mijn Redder en Bevrijder elke dag.
//			"""
//		}
    }

	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true)
	}
	
	@IBAction func donePressed(_ sender: UIBarButtonItem) {
		if let text = lyricsTextView.text {
			delegate?.didPressDone(text: text)
		}
		self.dismiss(animated: true)
	}
	
	
}
