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
	
	public func deleteRow(at indexPath: IndexPath, with animation: UITableViewRowAnimation) {
		
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
	
	public func register(cell: String) {
		
		register(nib: cell, identifier: cell)
		
	}
	
	public func register(nib: String, identifier: String) {
		
		register(UINib(nibName: nib, bundle: nil), forCellReuseIdentifier: identifier)
		
	}
	
}
