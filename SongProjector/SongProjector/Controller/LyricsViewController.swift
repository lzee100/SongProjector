//
//  LyricsViewController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 22-06-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

protocol LyricsControllerDelegate {
    func didPressDone(text: String, isCompleted: Bool)
}

class LyricsViewController: UIViewController {

	@IBOutlet var cancelButton: UIBarButtonItem!
	@IBOutlet var borderView: UIView!
	@IBOutlet var doneButton: UIBarButtonItem!
	@IBOutlet var lyricsTextView: UITextView!
	
	var text = ""
	var delegate: LyricsControllerDelegate?
    var isBibleTextGenerator = true
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        borderView.setCornerRadius(corners: .allCorners, radius: 5)
        if let placeholder = lyricsTextView.subviews.compactMap({ $0 as? UILabel }).first {
            let height = placeholder.text!.height(withConstrainedWidth: lyricsTextView.bounds.width - 6, font: .normal)
            placeholder.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
	override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .whiteColor
		cancelButton.title = AppText.Actions.cancel
		doneButton.title = AppText.Actions.done
        cancelButton.tintColor = themeHighlighted
        doneButton.tintColor = themeHighlighted
        borderView.backgroundColor = .grey0
		lyricsTextView.textColor = .blackColor
		lyricsTextView.text = text
        lyricsTextView.delegate = self
        lyricsTextView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
		let placeholder = lyricsPlaceholder
        placeholder.isHidden = !text.isEmpty
        title = isBibleTextGenerator ? AppText.Lyrics.titleBibleText : AppText.Lyrics.titleLyrics
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: .closeSheetPickerMenuPopUp, object: nil)
        (presentingViewController?.unwrap() as? CustomSheetsController)?.viewWillAppear(animated)
    }
    
    var lyricsPlaceholder: UILabel {
        if let placeholder = lyricsTextView.subviews.compactMap({ $0 as? UILabel }).first {
            return placeholder
        } else {
            let placeholder = UILabel(frame: CGRect(x: 0, y: 0, width: lyricsTextView.bounds.width, height: 21))
            placeholder.text = isBibleTextGenerator ? AppText.Lyrics.placeholderBibleText : AppText.Lyrics.placeholderLyrics
            placeholder.font = .normal
            placeholder.textColor = .placeholder
            lyricsTextView.addSubview(placeholder)
            view.layoutIfNeeded()
            let height = placeholder.text!.height(withConstrainedWidth: lyricsTextView.bounds.width - 6, font: .normal)
            placeholder.numberOfLines = 0
            placeholder.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                placeholder.topAnchor.constraint(equalTo: lyricsTextView.topAnchor, constant: 7),
                placeholder.leftAnchor.constraint(equalTo: lyricsTextView.leftAnchor, constant: 3),
                placeholder.widthAnchor.constraint(equalTo: lyricsTextView.widthAnchor, constant: 3),
                placeholder.heightAnchor.constraint(equalToConstant: height)
            ])
            return placeholder
        }
    }
    
	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true)
	}
	
	@IBAction func donePressed(_ sender: UIBarButtonItem) {
        self.delegate?.didPressDone(text: text, isCompleted: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let text = self.lyricsTextView.text {
                self.delegate?.didPressDone(text: text, isCompleted: true)
            }
        }
        self.dismiss(animated: true)
	}
	
}

extension LyricsViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text, !text.isEmpty {
            lyricsPlaceholder.isHidden = true
        } else {
            lyricsPlaceholder.isHidden = false
        }
    }
   
    func textViewDidEndEditing(_ textView: UITextView) {
        if let text = textView.text, !text.isEmpty {
            lyricsPlaceholder.isHidden = true
        } else {
            lyricsPlaceholder.isHidden = false
        }
    }
    
}
