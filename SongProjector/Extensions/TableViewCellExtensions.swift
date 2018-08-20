//
//  TableViewCellExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17-08-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
	var tableView: UITableView? {
		var view = self.superview
		while (view != nil && view!.isKind(of: UITableView.self) == false) {
			view = view!.superview
		}
		return view as? UITableView
	}
}
