//
//  ImportBibleController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 02-04-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit
import CoreData

class ImportBibleController: UIViewController {

	@IBOutlet var descriptionLabel: UILabel!
	@IBOutlet var textView: UITextView!
	@IBOutlet var importButton: UIBarButtonItem!
	@IBOutlet var containerView: UIView!
	
	
	@IBOutlet var coverView: UIView!
	@IBOutlet var containerViewDownload: UIView!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	@IBOutlet var percentageLabel: UILabel!
	@IBOutlet var progressBar: UIProgressView!
	@IBOutlet var cancelButton: UIButton!
	
	@IBOutlet var coverViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet var coverViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet var coverViewLeftConstraint: NSLayoutConstraint!
	
	var customLeftConstraint: NSLayoutConstraint?
	
	private var isCancelled = false
	var totalChapters = 0 {
		didSet { updatePercentage(totalChapters) }
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setup()
    }

	private func setup() {
				
		view.backgroundColor = themeWhiteBlackBackground
		descriptionLabel.text = Text.Import.description
		descriptionLabel.textColor = themeWhiteBlackTextColor
		textView.textColor = themeWhiteBlackTextColor
		importButton.title = Text.Actions.import
		
		containerView.layer.borderColor = themeHighlighted.cgColor
		containerView.backgroundColor = themeWhiteBlackBackground
		
		percentageLabel.textColor = themeWhiteBlackTextColor
		progressBar.tintColor = themeHighlighted
		progressBar.progress = Float(0)
		cancelButton.backgroundColor = themeWhiteBlackBackground
		cancelButton.tintColor = themeHighlighted
		cancelButton.setTitle(Text.Actions.cancel, for: .normal)
		activityIndicator.startAnimating()
		activityIndicator.tintColor = themeHighlighted
		activityIndicator.tintColorDidChange()
		
		containerViewDownload.backgroundColor = themeWhiteBlackBackground
		containerViewDownload.layer.cornerRadius = 8
		
		coverView.blurEffect()
		coverViewWidthConstraint.constant = UIScreen.main.bounds.width
		coverViewHeightConstraint.constant = UIScreen.main.bounds.height
		
		coverViewLeftConstraint.constant = UIScreen.main.bounds.width
		
	}
	
	@IBAction func importButtonPressed(_ sender: UIBarButtonItem) {
		
		progressBar.setProgress(0, animated: false)
		isCancelled = false
		totalChapters = 0
		
		textView.resignFirstResponder()
		coverViewLeftConstraint.constant = 0
		view.layoutIfNeeded()
		activityIndicator.startAnimating()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
			self.generateBible()
		}
	}
	
	@IBAction func cancelPressed(_ sender: UIButton) {
		activityIndicator.stopAnimating()
		isCancelled = true
		coverViewLeftConstraint.constant = UIScreen.main.bounds.width
	}
	
	private func updatePercentage(_ chapter: Int) {
		// 1189
		DispatchQueue.main.async {
			let totalChapters = 50
			let percentage = Float(chapter * 100 / totalChapters)
			self.percentageLabel.text = "\(percentage) %"
			self.progressBar.setProgress(percentage/100, animated: true)
			self.view.layoutIfNeeded()
		}
		
	}
	
	private func generateBible() {
		
		var text = self.textView.text ?? ""

		CoreEntity.getTemp = true
		CoreEntity.getEntities().forEach({ $0.delete(false) })
		CoreEntity.saveContext(fireNotification: false)
		
		mocBackground.perform {
			
			var hasNextBook = true
			var hasNextChapter = true
			var bookNumber = 0
			var chapterNumber: Int16 = 1
			var versNumber: Int16 = 1
			var versString = "\(1)"
			
			var nextVersNumber: Int16 {
				return versNumber + 1
			}
			var nextVersString: String {
				return "\(nextVersNumber)"
			}
			
			CoreBook.managedObjectContext = mocBackground
			CoreChapter.managedObjectContext = mocBackground
			CoreVers.managedObjectContext = mocBackground
			
			
			
			// find book range
			while let bookRange = text.range(of: "xxx"), !self.isCancelled {
				
				let book = CoreBook.createEntity()
				book.deleteDate = nil
				book.name = BibleIndex.getBookFor(index: bookNumber)
				book.title = book.name
				
				// get all text in book
				let start = text.index(text.startIndex, offsetBy: 0)
				let rangeBook = start..<bookRange.upperBound
				var bookText = String(text[rangeBook]).trimmingCharacters(in: .whitespacesAndNewlines)
				
				text.removeSubrange(rangeBook)
				
				// find chapter range
				while let chapterRange = bookText.range(of: "hhh"), !self.isCancelled {
					
					// prepare chapter
					let chapter = CoreChapter.createEntity()
					chapter.deleteDate = nil
					chapter.number = chapterNumber
					chapter.title = String(chapterNumber)
					
					print("chapter\(chapterNumber)")
					// get all text in book
					let start = bookText.index(bookText.startIndex, offsetBy: 0)
					let rangeChapter = start..<chapterRange.upperBound
					var chapterText = String(bookText[rangeChapter]).trimmingCharacters(in: .whitespacesAndNewlines)
					
					// remove text from total
					bookText.removeSubrange(rangeChapter)
					
					while let range = chapterText.range(of: nextVersString), !self.isCancelled {
						let start = text.index(text.startIndex, offsetBy: 0)
						let rangeVers = start..<range.lowerBound
						let rangeRemove = start..<range.upperBound
						
						let vers = CoreVers.createEntity()
						vers.deleteDate = nil
						vers.number = versNumber
						vers.title = String(versNumber)
						vers.text = String(chapterText[rangeVers]).trimmingCharacters(in: .whitespacesAndNewlines)
						vers.hasChapter = chapter
						chapterText.removeSubrange(rangeRemove)
						
						versNumber += 1
						versString = "\(versNumber)"
						
					}
					
					if chapterText.contains("hhh") {
						if let range = chapterText.range(of: "hhh") {
							chapterText.removeSubrange(range)
						}
						
					}
					if chapterText.contains("xxx") {
						if let range = chapterText.range(of: "xxx") {
							bookText.removeSubrange(range)
						}
					}
					
					let vers = CoreVers.createEntity()
					vers.deleteDate = nil
					vers.number = versNumber
					vers.title = String(versNumber)
					vers.text = chapterText.trimmingCharacters(in: .whitespacesAndNewlines)
					vers.hasChapter = chapter
					chapterText.removeAll()
					
					chapter.hasBook = book
					print(chapterNumber)
					chapterNumber += 1
					
					self.totalChapters += 1
					
					versNumber = 0
					versString = "\(versNumber)"
					
				}
				
				bookText = text.trimmingCharacters(in: .whitespacesAndNewlines)
				bookNumber += 1
				
			}
			
			if self.isCancelled {
				CoreEntity.getTemp = true
				CoreEntity.getEntities().forEach({ $0.delete(false) })
				CoreEntity.saveContext(fireNotification: false)
				DispatchQueue.main.async {
					self.coverViewLeftConstraint.constant = UIScreen.main.bounds.width
				}
			} else {
				_ = CoreChapter.saveContext()
				DispatchQueue.main.async {
					self.coverViewLeftConstraint.constant = UIScreen.main.bounds.width
				}
			}
			mocBackground.performAndWait {
				do {
					try mocBackground.save()
					try moc.save()
				} catch {
					fatalError("Failure to save context: \(error)")
				}
				CoreBook.managedObjectContext = moc
				CoreChapter.managedObjectContext = moc
				CoreVers.managedObjectContext = moc

			}
		
		}
		
		
		CoreChapter.predicates.append("hasBook.name", equals: "Genesis")
		print(CoreChapter.getEntities().count)
		CoreChapter.predicates.append("hasBook.name", equals: "Exodus")
		print(CoreChapter.getEntities().count)
		
	}
	
	
}
