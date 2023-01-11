//
//  SheetTitleContent.swift
//  SongProjector
//
//  Created by Leo van der Zee on 01-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit
import MessageUI

class SheetTitleContent: SheetView {
	
	@IBOutlet var sheetView: UIView!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var timeLabel: UILabel!
	@IBOutlet var titleBackground: UIView!
	@IBOutlet var contentTextView: UITextView!
	@IBOutlet var backgroundImageView: UIImageView!
	@IBOutlet var sheetBackground: UIView!
	@IBOutlet var titleHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet var titleLeftConstraint: NSLayoutConstraint!
	@IBOutlet var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet var titleRightConstraint: NSLayoutConstraint!
    @IBOutlet var timeRightConstraint: NSLayoutConstraint!
	@IBOutlet var contentLeftConstraint: NSLayoutConstraint!
	@IBOutlet var contentRightConstraint: NSLayoutConstraint!
	@IBOutlet var contentBottomConstraint: NSLayoutConstraint!
	@IBOutlet var contentTopToTitle: NSLayoutConstraint!
	
	var songTitle: String? {
        switch sheetCodable {
        case .sheetTitleContentCodable(let sheetCodable):
            if (sheetThemeCodable?.allHaveTitle ?? false || position == 0) {
                return cluster?.title ?? sheetCodable.title ?? sheetThemeCodable?.title
            } else {
                return nil
            }
        default:
            if ((sheetTheme?.allHaveTitle ?? true) || position == 0) {
                return cluster?.title ?? sheet?.title ?? sheetTheme?.title
            } else {
                return nil
            }
        }
	}
    
    var content: String? {
        switch sheetCodable {
        case .sheetTitleContentCodable(let sheetCodable):
            return sheetCodable.content
        default:
            if let sheet = sheet as? VSheetTitleContent {
                return sheet.content
            }
            return nil
        }
    }
	var zeroHeightConstraint: NSLayoutConstraint?
	
	override func customInit() {
		Bundle.main.loadNibNamed("SheetTitleContent", owner: self, options: [:])
		sheetView.frame = self.frame
		addSubview(sheetView)
	}
	
	override func update() {
		timeLabel.text = ""
        contentTextView.noPadding()
        contentTextView.isScrollEnabled = false
		if let scaleFactor = scaleFactor {
			
			titleLeftConstraint.constant = titleLeftConstraint.constant * scaleFactor
			titleTopConstraint.constant = titleTopConstraint.constant * scaleFactor
            titleRightConstraint.constant = titleRightConstraint.constant * scaleFactor
			timeRightConstraint.constant = timeRightConstraint.constant * scaleFactor
			contentLeftConstraint.constant = contentLeftConstraint.constant * scaleFactor
			contentBottomConstraint.constant = (contentBottomConstraint.constant * scaleFactor) - 1
			contentRightConstraint.constant = contentRightConstraint.constant * scaleFactor
			contentTopToTitle.constant = contentTopToTitle.constant * scaleFactor

			contentTextView.backgroundColor = .clear
			
            switch sheetCodable {
            case .sheetTitleContentCodable(let sheetCodable):
                if sheetCodable.isEmptySheet {
                    titleLabel.text = ""
                    contentTextView.text = ""
                } else {
                    updateTitle()
                    updateContent()
                }
            default:
                if sheet.isEmptySheet {
                    titleLabel.text = ""
                    contentTextView.text = ""
                } else {
                    updateTitle()
                    updateContent()
                }
            }
			
			updateBackgroundImage()
			updateBackgroundColor()
			updateOpacity()
            			
		}
	}
	
	override func updateTitle() {
        if sheetCodable != nil {
            updateTitleCodable()
        } else {
            updateVTitle()
        }
	}
	
	override func updateContent() {
        if let sheetCodableValue = sheetCodable {
            switch sheetCodableValue {
            case .sheetTitleContentCodable(let sheetCodable):
                if let content = sheetCodable.content {
                    if let theme = sheetThemeCodable {
                        contentTextView.attributedText = NSAttributedString(string: content, attributes: theme.getLyricsAttributes(scaleFactor ?? 1))
                    } else {
                        contentTextView.text = content
                    }
                } else {
                    contentTextView.text = nil
                }
            default:
                contentTextView.text = nil
            }
        } else {
            let sheet = self.sheet as! VSheetTitleContent
            if let content = sheet.content {
                if let theme = sheetTheme {
                    contentTextView.attributedText = NSAttributedString(string: content, attributes: theme.getLyricsAttributes(scaleFactor ?? 1))
                } else {
                    contentTextView.text = content
                }
            } else {
                contentTextView.text = nil
            }
        }
    }
	
	override func updateOpacity() {
        if let sheetThemeCodable = sheetThemeCodable {
            let image = isForExternalDispay ? sheetThemeCodable.tempSelectedImage ?? sheetThemeCodable.backgroundImage : sheetThemeCodable.tempSelectedImageThumbnail ?? sheetThemeCodable.thumbnail
            let alpha = sheetThemeCodable.backgroundTransparancy
            if image != nil {
                backgroundImageView.alpha = CGFloat(alpha)
                sheetBackground.alpha = 1
            } else {
                backgroundImageView.alpha = 0
                sheetBackground.alpha = CGFloat(alpha)
            }
        } else {
            let image = isForExternalDispay ? sheetTheme?.tempSelectedImage ?? sheetTheme?.backgroundImage : sheetTheme?.tempSelectedImageThumbNail ?? sheetTheme?.thumbnail
            if let alpha = sheetTheme?.backgroundTransparancy {
                if image != nil, !(sheetTheme?.isTempSelectedImageDeleted ?? true) {
                    backgroundImageView.alpha = CGFloat(alpha)
                    sheetBackground.alpha = 1
                } else {
                    backgroundImageView.alpha = 0
                    sheetBackground.alpha = CGFloat(alpha)
                }
            }
        }
	}
    
    override func updateBackgroundImage() {
        if let sheetThemeCodable = sheetThemeCodable {
            let image = isForExternalDispay ? sheetThemeCodable.tempSelectedImage ?? sheetThemeCodable.backgroundImage : sheetThemeCodable.tempSelectedImageThumbnail ?? sheetThemeCodable.thumbnail
            if let backgroundImage = image {
                backgroundImageView.isHidden = false
                backgroundImageView.contentMode = .scaleAspectFill
                backgroundImageView.image = backgroundImage
                backgroundImageView.clipsToBounds = true
                backgroundImageView.alpha = CGFloat(sheetThemeCodable.backgroundTransparancy)
            } else {
                backgroundImageView.isHidden = true
            }
        } else {
            let image = isForExternalDispay ? sheetTheme?.tempSelectedImage ?? sheetTheme?.backgroundImage : sheetTheme?.tempSelectedImageThumbNail ?? sheetTheme?.thumbnail
            if let backgroundImage = image, !(sheetTheme?.isTempSelectedImageDeleted ?? true) {
                backgroundImageView.isHidden = false
                backgroundImageView.contentMode = .scaleAspectFill
                backgroundImageView.image = backgroundImage
                backgroundImageView.clipsToBounds = true
                if let backgroundTransparency = sheetTheme?.backgroundTransparancy {
                    backgroundImageView.alpha = CGFloat(backgroundTransparency)
                }
            } else {
                backgroundImageView.isHidden = true
            }
        }
    }

	
	override func updateBackgroundColor() {
        if let sheetThemeCodable = sheetThemeCodable {
            if let titleBackgroundColor = sheetThemeCodable.backgroundColorTitle, let title = sheetThemeCodable.title, title != "" {
                if !sheetThemeCodable.allHaveTitle && position < 1 {
                    titleBackground.isHidden = false
                    titleBackground.backgroundColor = titleBackgroundColor
                } else if sheetThemeCodable.allHaveTitle {
                    titleBackground.isHidden = false
                    titleBackground.backgroundColor = titleBackgroundColor
                } else {
                    titleBackground.isHidden = true
                }
            } else {
                titleBackground.isHidden = true
            }
            
            if let backgroundColor = sheetThemeCodable.sheetBackgroundColor {
                self.sheetBackground.backgroundColor = backgroundColor
                self.sheetBackground.alpha = CGFloat(sheetThemeCodable.backgroundTransparancy > 0.0 ? sheetThemeCodable.backgroundTransparancy : 1.0)
            } else {
                self.sheetBackground.backgroundColor = .white
            }

        } else {
            if let titleBackgroundColor = sheetTheme?.backgroundColorTitle, let title = sheetTheme?.title, title != "" {
                if let allHaveTitle = sheetTheme?.allHaveTitle, allHaveTitle == false && position < 1 {
                    titleBackground.isHidden = false
                    titleBackground.backgroundColor = titleBackgroundColor
                } else if  let allHaveTitle = sheetTheme?.allHaveTitle, allHaveTitle == true {
                    titleBackground.isHidden = false
                    titleBackground.backgroundColor = titleBackgroundColor
                } else {
                    titleBackground.isHidden = true
                }
            } else {
                titleBackground.isHidden = true
            }
            
            if let backgroundColor = sheetTheme?.sheetBackgroundColor {
                self.sheetBackground.backgroundColor = backgroundColor
                self.sheetBackground.alpha = CGFloat((sheetTheme?.backgroundTransparancy  ?? 0.0) > 0.0 ? sheetTheme!.backgroundTransparancy : 1.0)
            } else {
                self.sheetBackground.backgroundColor = .white
            }
        }
	}
	
	override func updateTime(isOn: Bool) {
		
		let test = Date().time
		if !isOn {
            titleRightConstraint.constant = 0
			timeLabel.text = ""
			return
		}
		
		if let theme = sheetTheme, let scaleFactor = scaleFactor { // is custom sheet
			timeLabel.attributedText = NSAttributedString(string: test, attributes: theme.getTitleAttributes(scaleFactor))

		} else {
			timeLabel.text = test
		}
		
	}
    
    private func updateTitleCodable() {
        var isBibleVers: Bool {
            switch sheetCodable {
            case .sheetTitleContentCodable(let sheetCodable):
                return sheetCodable.isBibleVers
            default: return false
            }
        }
        if let songTitle = songTitle, !isBibleVers {
            if let theme = sheetThemeCodable, let titleLabel = titleLabel { // is custom sheet
                
                if !theme.allHaveTitle && position > 0 {
                    titleHeightConstraint.isActive = false
                    zeroHeightConstraint = NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
                    zeroHeightConstraint?.isActive = true
                    titleLabel.addConstraint(zeroHeightConstraint!)
                } else {
                    if let zeroHeightConstraint = zeroHeightConstraint {
                        titleLabel.removeConstraint(zeroHeightConstraint)
                    }
                    titleHeightConstraint.isActive = true
                }
                
                func height(attributedText: NSAttributedString) -> CGFloat {

                    let rect = attributedText.boundingRect(with: CGSize.init(width: .greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                                                 options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                 context: nil)
                    return ceil(rect.size.height)
                }
                
                let attTitle = NSAttributedString(string: songTitle, attributes: theme.getTitleAttributes(scaleFactor ?? 1))
                titleLabel.attributedText = attTitle
                titleHeightConstraint.constant = height(attributedText: attTitle)
                updateTime(isOn: theme.displayTime)
            } else {
                titleLabel.text = songTitle
            }
        } else {
            titleLabel.text = nil
            titleHeightConstraint.isActive = false
            zeroHeightConstraint = NSLayoutConstraint(item: titleLabel!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
            zeroHeightConstraint?.isActive = true
            titleLabel.addConstraint(zeroHeightConstraint!)
        }

    }
    
    private func updateVTitle() {
        var isBibleVers: Bool {
            guard let sheet = sheet as? VSheetTitleContent else {
                return true
            }
            return sheet.isBibleVers
        }
        if let songTitle = songTitle, !isBibleVers {
            if let theme = sheetTheme, let titleLabel = titleLabel { // is custom sheet
                
                if !theme.allHaveTitle && position > 0 {
                    titleHeightConstraint.isActive = false
                    zeroHeightConstraint = NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
                    zeroHeightConstraint?.isActive = true
                    titleLabel.addConstraint(zeroHeightConstraint!)
                } else {
                    if let zeroHeightConstraint = zeroHeightConstraint {
                        titleLabel.removeConstraint(zeroHeightConstraint)
                    }
                    titleHeightConstraint.isActive = true
                }
                
                func height(attributedText: NSAttributedString) -> CGFloat {

                    let rect = attributedText.boundingRect(with: CGSize.init(width: .greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                                                 options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                 context: nil)
                    return ceil(rect.size.height)
                }
                
                let attTitle = NSAttributedString(string: songTitle, attributes: theme.getTitleAttributes(scaleFactor ?? 1))
                titleLabel.attributedText = attTitle
                titleHeightConstraint.constant = height(attributedText: attTitle)
                updateTime(isOn: theme.displayTime)
            } else {
                titleLabel.text = songTitle
            }
        } else {
            titleLabel.text = nil
            titleHeightConstraint.isActive = false
            zeroHeightConstraint = NSLayoutConstraint(item: titleLabel!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
            zeroHeightConstraint?.isActive = true
            titleLabel.addConstraint(zeroHeightConstraint!)
        }
    }
	
}
