//
//  UIFontExtensions.swift
//  SongViewer
//
//  Created by Leo van der Zee on 04-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import Foundation
import UIKit



extension UIFont {
	
	// MARK: - Types
	
	enum Fonts: String {
		case heavy = "HelveticaNeue-CondensedBlack"
		case bold = "HelveticaNeue-Bold"
		case normal = "GillSans"
		case light = "GillSans-Light"
	}
	
	enum Size: CGFloat {
		case xxxLarge = 35.0
		case xxLarge = 30.0
		case xLarge = 25.0
		case large = 20.0
		case xxNormal = 18
		case xNormal = 16.0
		case normal = 14.0
		case small = 12.0
	}
	
	
	
	// MARK: - Properties
	
	var fontSizeText:CGFloat { return 14.0 }
	var fontSizeTextSmall:CGFloat { return 12.0 }
	
	
	var fontSizeIntroHeader:CGFloat { return 35.0 }
	var fontSizeIntroFooter:CGFloat { return 20.0 }
	
	static let introHeader = fontWith(name: .bold, size: .xxLarge)
	static let introFooter = fontWith(name: .light, size: .xLarge)
	
	static let xLarge = fontWith(name: .normal, size: .xLarge)
	static let xLargeBold = fontWith(name: .bold, size: .xLarge)
	static let xLargeLight = fontWith(name: .light, size: .xLarge)
	
	static let large = fontWith(name: .normal, size: .large)
	static let largeBold = fontWith(name: .bold, size: .large)
	static let largeLight = fontWith(name: .light, size: .large)
	
	static let xxNormal = fontWith(name: .normal, size: .xxNormal)
	static let xxNormalBold = fontWith(name: .bold, size: .xxNormal)
	static let xxNormalLight = fontWith(name: .light, size: .xxNormal)
	
	static let xNormal = fontWith(name: .normal, size: .xNormal)
	static let xNormalBold = fontWith(name: .bold, size: .xNormal)
	static let xNormalLight = fontWith(name: .light, size: .xNormal)
	
	static let normal = fontWith(name: .normal, size: .normal)
	static let normalBold = fontWith(name: .bold, size: .normal)
	static let normalLight = fontWith(name: .light, size: .normal)
	
	static let small = fontWith(name: .normal, size: .small)
	static let smallBold = fontWith(name: .bold, size: .small)
	static let smallLight = fontWith(name: .light, size: .small)
	
	
	
	// MARK: - Functions
	
	static func fontWith(name: Fonts = .normal, size: Size = .normal) -> UIFont {
		return UIFont(name: name.rawValue, size: size.rawValue)!
	}
	
	var isBold: Bool
	{
		return fontDescriptor.symbolicTraits.contains(.traitBold)
	}
	
	var isItalic: Bool
	{
		return fontDescriptor.symbolicTraits.contains(.traitItalic)
	}
	
	func setBoldFnc() -> UIFont
	{
		if(isBold)
		{
			return self
		}
		else
		{
			var fontAtrAry = fontDescriptor.symbolicTraits
			fontAtrAry.insert([.traitBold])
			if let fontAtrDetails = fontDescriptor.withSymbolicTraits(fontAtrAry) {
				return UIFont(descriptor: fontAtrDetails, size: 0)
			} else {
				return self
			}
		}
	}
	
	func setItalicFnc()-> UIFont
	{
		if(isItalic)
		{
			return self
		}
		else
		{
			var fontAtrAry = fontDescriptor.symbolicTraits
			fontAtrAry.insert([.traitItalic])
			if let fontAtrDetails = fontDescriptor.withSymbolicTraits(fontAtrAry) {
				return UIFont(descriptor: fontAtrDetails, size: 0)
			} else {
				return self
			}
		}
	}
	
	func setBoldItalicFnc()-> UIFont
	{
		return setBoldFnc().setItalicFnc()
	}
	
	func detBoldFnc() -> UIFont
	{
		if(!isBold)
		{
			return self
		}
		else
		{
			var fontAtrAry = fontDescriptor.symbolicTraits
			fontAtrAry.remove([.traitBold])
			if let fontAtrDetails = fontDescriptor.withSymbolicTraits(fontAtrAry) {
				return UIFont(descriptor: fontAtrDetails, size: 0)
			} else {
				return self
			}
		}
	}
	
	func detItalicFnc()-> UIFont
	{
		if(!isItalic)
		{
			return self
		}
		else
		{
			var fontAtrAry = fontDescriptor.symbolicTraits
			fontAtrAry.remove([.traitItalic])
			if let fontAtrDetails = fontDescriptor.withSymbolicTraits(fontAtrAry) {
				return UIFont(descriptor: fontAtrDetails, size: 0)
			} else {
				return self
			}
		}
	}
	
	func SetNormalFnc()-> UIFont
	{
		return detBoldFnc().detItalicFnc()
	}
	
	func toggleBoldFnc()-> UIFont
	{
		if(isBold)
		{
			return detBoldFnc()
		}
		else
		{
			return setBoldFnc()
		}
	}
	
	func toggleItalicFnc()-> UIFont
	{
		if(isItalic)
		{
			return detItalicFnc()
		}
		else
		{
			return setItalicFnc()
		}
	}
	
	
	
}
