//
//  ManageSongServiceController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 30/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

class ManageSongServiceController: ChurchBeamViewController, UITableViewDataSource, UITableViewDelegate {
	
	
	
	@IBOutlet var addOrEditButton: UIBarButtonItem!
	
	@IBOutlet var tableView: UITableView!

	private var songServiceObject: SongServiceSettings? = nil
	
	// MARK: - UIView Functions

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.register(cell: BasicCell.identifier)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		SongServiceSettingsFetcher.addObserver(self)
		SongServiceSettingsFetcher.fetch(force: false)
		addOrEditButton.tintColor = .clear
		addOrEditButton.isEnabled = false
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		SongServiceSettingsFetcher.removeObserver(self)
	}
	
	
	
	// MARK: - UITableView Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return songServiceObject?.sections.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return songServiceObject?.sections[section].tags.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BasicCell.identifier) as! BasicCell
		cell.setup(title: songServiceObject?.sections[indexPath.section].tags[indexPath.row].title, icon: Cells.bulletFilled, iconSelected: nil, textColor: themeWhiteBlackTextColor, hasPianoOnly: false)
		return cell
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return songServiceObject?.sections[section].title ?? "No title"
	}
	
	override func handleRequestFinish(requesterId: String, result: AnyObject?) {
		Queues.main.async {
			self.songServiceObject = CoreSongServiceSettings.getEntities().first
			self.tableView.reloadData()
		}
	}
	
	override func requestDidFinish(requesterID: String, response: ResponseType, result: AnyObject?) {
		Queues.main.async {
			self.hideLoader()
			switch response {
			case .error(_, _): self.show(error: response)
			case .OK(_): self.handleRequestFinish(requesterId: requesterID, result: result)
			}
			self.addOrEditButton.title = self.songServiceObject == nil ? Text.Actions.new : Text.Actions.edit
			self.addOrEditButton.tintColor = themeHighlighted
			self.addOrEditButton.isEnabled = true
		}
	}

}
