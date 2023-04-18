//
//  ThemeCodableExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/12/2022.
//  Copyright © 2022 iozee. All rights reserved.
//

import Foundation
import UIKit


extension ThemeCodable {
    
    var textColorTitle: UIColor? {
        get {
            guard let hex = titleTextColorHex else { return nil }
            return UIColor(hex: hex)
        }
        set(newColor) {
            if let newColor = newColor {
                titleTextColorHex = newColor.hexCode
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
                titleBackgroundColor = newColor.hexCode
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
                backgroundColor = newColor.hexCode
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
                titleBorderColorHex = newColor.hexCode
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
                contentTextColorHex = newColor.hexCode
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
                contentBorderColorHex = newColor.hexCode
            }
        }
    }
    
    func getTitleAttributes(_ scaleFactor: CGFloat = 1) -> [NSAttributedString.Key: Any] {
        var attributes : [NSAttributedString.Key: Any] = [:]
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
        if let textColor = self.titleTextColorHex {
            attributes[.foregroundColor] = UIColor(hex: textColor)
        } else {
            attributes[.foregroundColor] = UIColor.black
        }
        
        if let borderColor = self.titleBorderColorHex {
            attributes[.strokeColor] = UIColor(hex: borderColor)
        }
        
        if self.isTitleUnderlined {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            attributes[.underlineColor] = attributes[.foregroundColor]
        }
        
        return attributes
    }
    
    func getLyricsAttributes(_ scaleFactor: CGFloat = 1) -> [NSAttributedString.Key: Any] {
        var attributes : [NSAttributedString.Key: Any] = [:]
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
        
        if let textColor = self.contentTextColorHex {
            attributes[.foregroundColor] = UIColor(hex: textColor)
        } else {
            attributes[.foregroundColor] = UIColor.black
        }
        
        if let borderColor = self.contentBorderColorHex {
            attributes[.strokeColor] = UIColor(hex: borderColor)
        }
        
        if self.isContentUnderlined {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        return attributes
    }
    
    private(set) var backgroundImage: UIImage? {
        get {
            UIImage.get(imagePath: self.imagePath)
        }
        set {
        }
    }
    
    private(set) var thumbnail: UIImage? {
        get {
            UIImage.get(imagePath: self.imagePathThumbnail)
        }
        set {
        }
    }
    
    var backgroundTransparancy: Double {
        get { return backgroundTransparancyNumber }
        set { backgroundTransparancyNumber = newValue / 100 }
    }
}
