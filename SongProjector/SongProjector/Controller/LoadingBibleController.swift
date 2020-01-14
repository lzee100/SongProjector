//
//  LoadingBibleController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 02-04-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class LoadingBibleController: UIViewController {

	@IBOutlet var containerView: UIView!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	@IBOutlet var percentageLabel: UILabel!
	@IBOutlet var progressbar: UIProgressView!
	@IBOutlet var cancelButton: UIButton!
	
	private var totalChapters = 0 {
		didSet { updatePercentage(totalChapters) }
	}
	private var isCancelled = true
	
	var text: String?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setup()
    }
	
	private func setup() {
		
		containerView.backgroundColor = themeWhiteBlackBackground
		percentageLabel.textColor = themeWhiteBlackTextColor
		progressbar.tintColor = themeHighlighted
		progressbar.progress = Float(0)
		cancelButton.backgroundColor = themeWhiteBlackBackground
		cancelButton.tintColor = themeHighlighted
		cancelButton.setTitle(Text.Actions.cancel, for: .normal)
		activityIndicator.startAnimating()
	}

	@IBAction func cancelPressed(_ sender: UIButton) {
		activityIndicator.stopAnimating()
	}
	
	private func updatePercentage(_ chapter: Int) {
		// 1189
		DispatchQueue.main.async {
			let totalChapters = 50
			let percentage = Float(chapter * 100 / totalChapters)
			self.percentageLabel.text = "\(percentage) %"
			self.progressbar.setProgress(percentage, animated: true)
		}
		
	}
	
	private func generateBible() {
//		CoreBook.getEntities().forEach({ $0.delete(false) })
//		CoreChapter.getEntities().forEach({ $0.delete(false) })
//		CoreVers.getEntities().forEach({ $0.delete(false) })
//		CoreEntity.saveContext(fireNotification: false)

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
		
		var text = self.text ?? ""
		
		
		// find book range
		while let bookRange = text.range(of: "xxx"), !isCancelled {
			
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
			while let chapterRange = bookText.range(of: "hhh"), !isCancelled {
				
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
				
				while let range = chapterText.range(of: nextVersString), !isCancelled {
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
				
				totalChapters += 1
				
				versNumber = 0
				versString = "\(versNumber)"
				
			}
			
			bookText = text.trimmingCharacters(in: .whitespacesAndNewlines)
			bookNumber += 1
			
		}
		
		if isCancelled {
//			CoreBook.getEntities().forEach({ $0.delete(false) })
//			CoreChapter.getEntities().forEach({ $0.delete(false) })
//			CoreVers.getEntities().forEach({ $0.delete(false) })
			self.remove()
		} else {
			self.remove()
		}
//		CoreEntity.saveContext(fireNotification: false)
//
//		CoreChapter.predicates.append("hasBook.name", equals: "Genesis")
//		print(CoreChapter.getEntities().count)
//		CoreChapter.predicates.append("hasBook.name", equals: "Exodus")
//		print(CoreChapter.getEntities().count)
//
	}
	
}
