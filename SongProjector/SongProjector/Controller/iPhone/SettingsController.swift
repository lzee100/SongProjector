//
//  SettingsController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 27-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController, GoogleCellDelegate {
	
	let googleCell = GoogleCell.create(id: "GoogleCell", description: Text.Settings.descriptionGoogle)
	
	enum Section: String {
		case songService
		case googleAgenda
		
		static let all = [songService, googleAgenda]
		
		static func `for`(_ section: Int) -> Section {
			return all[section]
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		setup()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return Section.all.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		switch Section.for(indexPath.row) {
		case .songService:
			
		case .googleAgenda:
			return googleCell
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		switch Section.for(indexPath.section) {
		case .googleAgenda:
			return googleCell.preferredHeight
		}
	}
	
	
	// MARK: - Delegate Functions
	
	func showInstructions(cell: GoogleCell) {
		print("show instructions")
	}

	private func setup() {
		tableView.register(cell: Cells.GoogleCell)
		googleCell.delegate = self
		googleCell.sender = self
	}
}
