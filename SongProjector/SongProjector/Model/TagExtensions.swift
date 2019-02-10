//
//  TagExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import Foundation
import UIKit

enum TagAttribute {
	case asTag
	
	case title
	
	case allHaveTitle
	case displayTime
	case hasEmptySheet
	case isEmptySheetFirst
	case isContentBold
	case isContentItalic
	case isContentUnderlined
	case isTitleBold
	case isTitleItalic
	case isTitleUnderlined
	
	case backgroundColor
	case backgroundImage
	case backgroundTransparancy

	case contentAlignment
	case contentBorderColor
	case contentFontName
	case contentTextColorHex
	case contentTextSize
	case contentBorderSize
	
	case titleAlignment
	case titleBackgroundColor
	case titleBorderColorHex
	case titleFontName
	case titleTextColorHex
	case titleTextSize
	case titleBorderSize
	
	var description: String {
		switch self {
		case .asTag: return Text.NewTag.descriptionAsTag
		case .title: return Text.NewTag.descriptionTitle
		case .allHaveTitle: return Text.NewTag.descriptionAllTitle
		case .displayTime: return Text.NewTag.descriptionDisplayTime
		case .hasEmptySheet: return Text.NewTag.descriptionHasEmptySheet
		case .isEmptySheetFirst: return Text.NewTag.descriptionPositionEmptySheet
		case .isContentBold: return Text.NewTag.bold
		case .isContentItalic: return Text.NewTag.italic
		case .isContentUnderlined: return Text.NewTag.underlined
		case .isTitleBold: return Text.NewTag.bold
		case .isTitleItalic: return Text.NewTag.italic
		case .isTitleUnderlined: return Text.NewTag.underlined
			
		case .backgroundColor: return Text.NewTag.descriptionBackgroundColor
		case .backgroundImage: return Text.NewTag.backgroundImage
		case .backgroundTransparancy: return Text.NewTag.descriptionBackgroundTransparency
		case .contentAlignment: return Text.NewTag.descriptionAlignment
		case .contentBorderColor: return Text.NewTag.borderColor
		case .contentBorderSize: return Text.NewTag.borderSizeDescription
		case .contentFontName: return Text.NewTag.fontFamilyDescription
		case .contentTextColorHex: return Text.NewTag.textColor
		case .contentTextSize: return Text.NewTag.fontSizeDescription
			
		case .titleAlignment: return Text.NewTag.descriptionAlignment
		case .titleBackgroundColor: return Text.NewTag.descriptionBackgroundColor
		case .titleBorderColorHex: return Text.NewTag.borderColor
		case .titleTextSize: return Text.NewTag.fontSizeDescription
		case .titleFontName: return Text.NewTag.fontFamilyDescription
		case .titleTextColorHex: return Text.NewTag.textColor
		case .titleBorderSize: return Text.NewTag.borderSizeDescription
			
		}
	}
}

extension Tag {
	
	var textColorTitle: UIColor? {
		get {
			guard let hex = titleTextColorHex else { return nil }
			return UIColor(hex: hex)
		}
		set(newColor) {
			if let newColor = newColor {
				titleTextColorHex = newColor.toHex
			}
		}
	}
	
	var backgroundColorTitle: UIColor? {
		get {
			guard let hex = titleBackgroundColor else { return nil }
			return UIColor(hex: hex)
		}
		set(newColor) {
			if let newColor = newColor {
				titleBackgroundColor = newColor.toHex
			}
		}
	}
	
	var sheetBackgroundColor: UIColor? {
		get {
			guard let hex = backgroundColor else { return nil }
			return UIColor(hex: hex)
		}
		set(newColor) {
			if let newColor = newColor {
				backgroundColor = newColor.toHex
			}
		}
	}
	
	var borderColorTitle: UIColor? {
		get {
			guard let hex = titleBorderColorHex else { return nil }
			return UIColor(hex: hex)
		}
		set(newColor) {
			if let newColor = newColor {
				titleBorderColorHex = newColor.toHex
			}
		}
	}
	
	var textColorLyrics: UIColor? {
		get {
			guard let hex = contentTextColorHex else { return nil }
			return UIColor(hex: hex)
		}
		set(newColor) {
			if let newColor = newColor {
				contentTextColorHex = newColor.toHex
			}
		}
	}
	
	var borderColorLyrics: UIColor? {
		get {
			guard let hex = contentBorderColorHex else { return nil }
			return UIColor(hex: hex)
		}
		set(newColor) {
			if let newColor = newColor {
				contentBorderColorHex = newColor.toHex
			}
		}
	}
	var backgroundImage: UIImage? {
		get {
			if let imagePath = imagePath {
				let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
				let filePath = documentsDirectory.appendingPathComponent(imagePath).path
				return UIImage(contentsOfFile: filePath)
			} else {
				return nil
			}
		}
		set {
			if let newValue = newValue, let data = UIImageJPEGRepresentation(newValue, 1.0), let resizedImage = newValue.resized(toWidth: 500), let dataResized = UIImageJPEGRepresentation(resizedImage, 0.5) {
				if let path = self.imagePath {
					let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
					let url = documentsDirectory.appendingPathComponent(path)
					do {
						try FileManager.default.removeItem(at: url)
						self.imagePath = nil
					} catch let error as NSError {
						print("Error: \(error.domain)")
					}
				}
				
				if let path = self.imagePathThumbnail {
					let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
					let url = documentsDirectory.appendingPathComponent(path)
					do {
						try FileManager.default.removeItem(at: url)
					} catch let error as NSError {
						print("Error: \(error.domain)")
					}
				}
				
				
				
				
				let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
				let imagePath = UUID().uuidString + ".jpg"
				let imagePathThumbnail = UUID().uuidString + "thumb.jpg"

				let filename = documentsDirectory.appendingPathComponent(imagePath)
				let filenameThumb = documentsDirectory.appendingPathComponent(imagePathThumbnail)

				try? data.write(to: filename)
				try? dataResized.write(to: filenameThumb)
				self.imagePath = imagePath
				self.imagePathThumbnail = imagePathThumbnail

			}
			else if newValue == nil {
				if let path = self.imagePath {
					let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
					let url = documentsDirectory.appendingPathComponent(path)
					do {
						try FileManager.default.removeItem(at: url)
					} catch let error as NSError {
						print("Error: \(error.domain)")
					}
				}
				if let path = self.imagePathThumbnail {
					let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
					let url = documentsDirectory.appendingPathComponent(path)
					do {
						try FileManager.default.removeItem(at: url)
					} catch let error as NSError {
						print("Error: \(error.domain)")
					}
				}
			}
		}
	}
	
	private(set) var thumbnail: UIImage? {
		get {
			if let imagePath = imagePathThumbnail {
				let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
				let filePath = documentsDirectory.appendingPathComponent(imagePath).path
				return UIImage(contentsOfFile: filePath)
			} else {
				return nil
			}
		}
		set {
		}
	}
	
	func getTitleAttributes(_ scaleFactor: CGFloat = 1) -> [NSAttributedStringKey: Any] {
		var attributes : [NSAttributedStringKey: Any] = [:]
		if let fontFamily = self.titleFontName {
			var font = UIFont(name: fontFamily, size: (CGFloat(self.titleTextSize) * scaleFactor))
			if self.isTitleBold {
				font = font?.setBoldFnc()
			}
			if self.isTitleItalic {
				font = font?.setItalicFnc()
			}
			attributes[.font] = font
		}

		let paragraph = NSMutableParagraphStyle()
		
		switch titleAlignmentNumber {
		case 0:
			paragraph.alignment = .left
			attributes[.paragraphStyle] = paragraph
		case 1:
			paragraph.alignment = .center
			attributes[.paragraphStyle] = paragraph
		case 2:
			paragraph.alignment = .right
			attributes[.paragraphStyle] = paragraph
		default:
			break
		}
		
		attributes[.strokeWidth] = Int(self.titleBorderSize)
		
		if let textColor = self.textColorTitle {
			attributes[.foregroundColor] = textColor
		} else {
			attributes[.foregroundColor] = UIColor.black
		}
		
		if let borderColor = self.borderColorTitle {
			attributes[.strokeColor] = borderColor
		}
		
		if self.isTitleUnderlined {
			attributes[.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
			attributes[.underlineColor] = attributes[.foregroundColor]
		}
		
		
		
		return attributes
	}
	
	func getLyricsAttributes(_ scaleFactor: CGFloat = 1) -> [NSAttributedStringKey: Any] {
		var attributes : [NSAttributedStringKey: Any] = [:]
		if let fontFamily = self.contentFontName {
			var font = UIFont(name: fontFamily, size: (CGFloat(self.contentTextSize) * scaleFactor))
			if self.isContentBold {
				font = font?.setBoldFnc()
			}
			if self.isContentItalic {
				font = font?.setItalicFnc()
			}
			attributes[.font] = font
		}
		
		let paragraph = NSMutableParagraphStyle()
		
		switch contentAlignmentNumber {
		case 0:
			paragraph.alignment = .left
			attributes[.paragraphStyle] = paragraph
		case 1:
			paragraph.alignment = .center
			attributes[.paragraphStyle] = paragraph
		case 2:
			paragraph.alignment = .right
			attributes[.paragraphStyle] = paragraph
		default:
			break
		}

		attributes[.strokeWidth] = Int(self.contentBorderSize)
		
		if let textColor = self.textColorLyrics {
			attributes[.foregroundColor] = textColor
		} else {
			attributes[.foregroundColor] = UIColor.black
		}
		
		if let borderColor = self.borderColorLyrics {
			attributes[.strokeColor] = borderColor
		}
		
		if self.isContentUnderlined {
			attributes[.underlineStyle] = NSUnderlineStyle.styleSingle.rawValue
		}
		return attributes
	}
	
	var backgroundTransparancy: Float {
		get { return Float(backgroundTransparancyNumber) }
		set { backgroundTransparancyNumber = newValue / 100 }
	}
	
//	@objc override public func delete() {
//		backgroundImage = nil
//		super.delete()
//	}
	
	func getTemp() -> Tag {
		let tempTag = CoreTag.createEntityNOTsave()
		tempTag.isTemp = true
		tempTag.title = title
		tempTag.allHaveTitle = allHaveTitle
		tempTag.hasEmptySheet = hasEmptySheet
		tempTag.isEmptySheetFirst = isEmptySheetFirst
		tempTag.backgroundColor = backgroundColor
		let cgfloatValue = CGFloat(backgroundTransparancy)
		tempTag.backgroundTransparancy = Float(cgfloatValue) * 100
		tempTag.displayTime = displayTime
		
		tempTag.titleFontName = titleFontName ?? "Avenir"
		tempTag.titleTextSize = titleTextSize
		tempTag.titleBackgroundColor = titleBackgroundColor
		tempTag.titleAlignmentNumber = titleAlignmentNumber
		tempTag.titleBorderSize = titleBorderSize
		tempTag.titleBorderColorHex = titleBorderColorHex
		tempTag.titleTextColorHex = titleTextColorHex
		tempTag.isTitleBold = isTitleBold
		tempTag.isTitleItalic = isTitleItalic
		tempTag.isTitleUnderlined = isTitleUnderlined
		
		tempTag.contentFontName = contentFontName ?? "Avenir"
		tempTag.contentTextSize = contentTextSize
		tempTag.contentAlignmentNumber = contentAlignmentNumber
		tempTag.contentBorderSize = contentBorderSize
		tempTag.contentBorderColorHex = contentBorderColorHex
		tempTag.contentTextColorHex = contentTextColorHex
		tempTag.isContentBold = isContentBold
		tempTag.isContentItalic = isContentItalic
		tempTag.isContentUnderlined = isContentUnderlined
		tempTag.isBackgroundImageDeleted = isBackgroundImageDeleted
		
		tempTag.imagePath = imagePath
		tempTag.imagePathThumbnail = imagePathThumbnail
		tempTag.isHidden = isHidden
		return tempTag
	}
	
	func mergeSelfInto(tag: Tag, isTemp: NSDate? = nil, sheetType: SheetType) {
		tag.deleteDate = isTemp
		tag.title = title
		tag.allHaveTitle = allHaveTitle
		tag.hasEmptySheet = hasEmptySheet
		tag.isEmptySheetFirst = isEmptySheetFirst
		tag.backgroundColor = backgroundColor
		let cgfloatValue = CGFloat(backgroundTransparancy)
		tag.backgroundTransparancy = Float(cgfloatValue) * 100
		tag.displayTime = displayTime
		
		tag.titleFontName = titleFontName ?? "Avenir"
		tag.titleTextSize = titleTextSize
		if sheetType != .SheetPastors {
			tag.titleBackgroundColor = titleBackgroundColor
			tag.titleAlignmentNumber = titleAlignmentNumber
		}
		tag.titleBorderSize = titleBorderSize
		tag.titleBorderColorHex = titleBorderColorHex
		tag.titleTextColorHex = titleTextColorHex
		tag.isTitleBold = isTitleBold
		tag.isTitleItalic = isTitleItalic
		tag.isTitleUnderlined = isTitleUnderlined
		
		tag.contentFontName = contentFontName ?? "Avenir"
		tag.contentTextSize = contentTextSize
		if sheetType != .SheetPastors {
			tag.contentAlignmentNumber = contentAlignmentNumber
		}
		tag.contentBorderSize = contentBorderSize
		tag.contentBorderColorHex = contentBorderColorHex
		tag.contentTextColorHex = contentTextColorHex
		tag.isContentBold = isContentBold
		tag.isContentItalic = isContentItalic
		tag.isContentUnderlined = isContentUnderlined
		tag.isBackgroundImageDeleted = isBackgroundImageDeleted
		
		tag.imagePath = imagePath
		tag.imagePathThumbnail = imagePathThumbnail
		
		if isBackgroundImageDeleted {
			tag.backgroundImage = nil
			tag.isBackgroundImageDeleted = false
		}
		
		print("merged tag")

	}
	
	public override func delete(_ save: Bool) {
		imagePath = nil
		moc.delete(self)
		if save {
			do {
				try moc.save()
			} catch {
				print(error)
			}
		}
	}
	
	public override func deleteBackground(_ save: Bool) {
		imagePath = nil
		mocBackground.delete(self)
		mocBackground.performAndWait {
			do {
				try mocBackground.save()
				try moc.save()
			} catch {
				print(error)
			}
		}
	}

}
