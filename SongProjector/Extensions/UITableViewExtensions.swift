//
//  UITableViewExtensions.swift
//  SongViewer
//
//  Created by Leo van der Zee on 04-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
	
	public func deleteRow(at indexPath: IndexPath, with animation: UITableView.RowAnimation) {
		
		deleteRows(at: [indexPath], with: animation)
		
	}
	
	public func updateHeights(animated: Bool = true, completion: (() -> Void)? = nil) {
		
		if animated {
			
			CATransaction.setCompletionBlock(completion)
			
			beginUpdates()
			endUpdates()
			
			CATransaction.commit()
			
		} else {
			
			UIView.performWithoutAnimation{ updateHeights() }
			
		}
		
	}
    
    public func register(header: String) {
        register(UINib(nibName: header, bundle: nil), forHeaderFooterViewReuseIdentifier: header)
    }
	
	public func register(cell: String) {
		register(nib: cell, identifier: cell)
	}
    
    public func registerBasicHeaderView() {
        register(header: BasicHeaderView.identifier)
    }
    public func registerTextFooterView() {
        register(TextFooterView.self, forHeaderFooterViewReuseIdentifier: TextFooterView.identifier)
    }
	
	public func register(cells: [String]) {
		
		cells.forEach({ register(nib: $0, identifier: $0) })
		
	}
	
	public func register(nib: String, identifier: String) {
		
		register(UINib(nibName: nib, bundle: nil), forCellReuseIdentifier: identifier)
		
	}
	
	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCell.EditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
	}
	
	func setBottomInset(to value: CGFloat) {
		let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: value, right: 0)
		
		self.contentInset = edgeInset
		self.scrollIndicatorInsets = edgeInset
	}
    
    var basicHeaderView: BasicHeaderView? {
        return dequeueReusableHeaderFooterView(withIdentifier: BasicHeaderView.identifier) as? BasicHeaderView
    }
    
    var basicFooterView: TextFooterView? {
        return dequeueReusableHeaderFooterView(withIdentifier: TextFooterView.identifier) as? TextFooterView
    }
    
    func style(_ cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == 0 && indexPath.row == numberOfRows(inSection: indexPath.section)-1) {
            cell.setCornerRadiusAsMask(corners: .all)
        } else if (indexPath.row == 0) {
            cell.setCornerRadiusAsMask(corners: .leftTopRightTop)
        } else if (indexPath.row == numberOfRows(inSection: indexPath.section)-1) {
            cell.setCornerRadiusAsMask(corners: .leftBottomRightBottom)
        } else {
            cell.setBorderMask()
        }
    }
    
    func styleHeaderView(view: UIView) {
        
        var current: UIView? = (view as? SongHeaderView)?.contentView
        repeat {
            if !(current is SongHeaderView) {
                current?.backgroundColor = .whiteColor
            }
            current = current?.superview
        } while current != nil
        
    }
	
}
