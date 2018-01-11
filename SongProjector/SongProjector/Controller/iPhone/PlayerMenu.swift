////
////  PlayerMenu.swift
////  SongProjector
////
////  Created by Leo van der Zee on 07-01-18.
////  Copyright © 2018 iozee. All rights reserved.
////
//
//import UIKit
//
//class PlayerMenu: UITableViewController {
//
//	enum MenuItem: String {
//		case emptySheet
//		case textSheet
//		case imageSheet
//
//		static let all = [emptySheet, textSheet, imageSheet]
//
//		static func `for`(_ indexPath: IndexPath) -> MenuItem {
//			return all[indexPath.row]
//		}
//
//		static func nameFor(_ indexPath: IndexPath) -> String {
//			switch `for`(indexPath) {
//			case .emptySheet: return Text.Players.menuEmptySheet
//			case .textSheet: return Text.Players.menuTextSheet
//			case .imageSheet: return Text.Players.menuImageSheet
//			}
//		}
//
//		var image: UIImage {
//			switch self {
//			case .emptySheet:
//				return Cells.songIcon
//			case .textSheet:
//				return Cells.tagIcon
//			case .imageSheet:
//				return Cells.sheetIcon
//			}
//		}
//
//	}
//
//
//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//		setup()
//
//	}
//
//    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return MenuItem.all.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//		let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath) as! BasicCell
//		cell.setup(title: MenuItem.nameFor(indexPath), icon: MenuItem.for(indexPath).image)
//		cell.backgroundColor = UIColor(hex: "282828")
//		return cell
//    }
//
//	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//	}
//
//	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//		return 60
//	}
//
//	private func setup() {
//		tableView.register(cell: Cells.basicCellid)
//		tableView.backgroundColor = .gray
//		tableView.reloadData()
//	}
//
//}

