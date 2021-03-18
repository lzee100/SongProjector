//
//  NewSongMenuController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10-02-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class NewSongMenuController: UITableViewController {
	
	private enum Menu: String {
		case newSongController
		case customSheetController
		
		static let all = [newSongController, customSheetController]
		
		static func `for`(_ indexPath: IndexPath) -> Menu {
			return all[indexPath.row]
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Menu.all.count
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath) as! BasicCell
		
		switch Menu.for(indexPath) {
		case .newSongController:
			cell.setup(title: AppText.NewSong.title)
		case .customSheetController:
			cell.setup(title: AppText.CustomSheets.title)
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch Menu.for(indexPath) {
		case .newSongController:
			let controller = storyboard?.instantiateViewController(withIdentifier: "CustomSheetsController") as! CustomSheetsController
			let nav = UINavigationController(rootViewController: controller)
			DispatchQueue.main.async {
				self.present(nav, animated: true, completion: {
					self.navigationController?.popViewController(animated: false)
				})
			}
		case .customSheetController:
			let controller = storyboard?.instantiateViewController(withIdentifier: "CustomSheetsController") as! CustomSheetsController
			let nav = UINavigationController(rootViewController: controller)
			DispatchQueue.main.async {
				self.present(nav, animated: true, completion: {
					self.navigationController?.popViewController(animated: false)
				})
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	private func setup() {
		tableView.register(cell: Cells.basicCellid)
		title = AppText.Songs.menuTitle
		tableView.isScrollEnabled = false
	}
	
	
}
