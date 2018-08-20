//
//  ChurchBeamCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 04-06-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import UIKit

protocol DynamicHeightCell {
	var isActive: Bool { get set }
	var preferredHeight: CGFloat { get }
}

protocol TagImplementation {
	
	var sheetTag: Tag? { get set }
	var tagAttribute: TagAttribute? { get set }
	var valueDidChange: ((ChurchBeamCell) -> Void)? { get set }
	
	func set(value: Any?)
	func apply(tag: Tag, tagAttribute: TagAttribute)
	func applyValueToCell()
	func applyCellValueToTag()
	
}

protocol SheetImplementation {
	var sheet: Sheet? { get set }
	var sheetAttribute: SheetAttribute? { get set }
	var valueDidChange: ((ChurchBeamCell) -> Void)? { get set }
	
	func apply(sheet: Sheet, sheetAttribute: SheetAttribute)
}

class ChurchBeamCell: UITableViewCell {

	
	override func setSelected(_ selected: Bool, animated: Bool) {
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
	}
}
