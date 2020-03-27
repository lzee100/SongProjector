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

	private var songServiceObject: VSongServiceSettings? = nil {
		didSet { print(songServiceObject?.sections.count ?? 0) }
	}
	override var requesterId: String {
		return ""
	}
	override var requesters: [RequesterType] {
		return [SongServiceSettingsFetcher]
	}
	
	// MARK: - UIView Functions

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.register(cell: BasicCell.identifier)
		tableView.rowHeight = 68
		tableView.register(cell: TextCell.identifier)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		SongServiceSettingsFetcher.fetch()
		addOrEditButton.tintColor = .clear
		addOrEditButton.isEnabled = false
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination.unwrap() as? WizzardSectionsController {
			vc.songServiceObject = songServiceObject
		}
	}
	
	// MARK: - UITableView Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return songServiceObject?.sections.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (songServiceObject?.sections[section].hasTags.count ?? 0) + 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: TextCell.identifier) as! TextCell
			cell.setupWith(text: Text.SongServiceManagement.numberOfSongs + "\(songServiceObject?.sections[indexPath.section].numberOfSongs ?? 0)")
			return cell
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BasicCell.identifier) as! BasicCell
		cell.setup(title: songServiceObject?.sections[indexPath.section].hasTags[indexPath.row - 1].title, icon: Cells.bulletFilled, iconSelected: nil, textColor: themeWhiteBlackTextColor, hasPianoOnly: false)
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 0 {
			return UITableView.automaticDimension
		}
		return 68
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return songServiceObject?.sections[section].title ?? "No title"
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return HeaderView.basicSize.height
	}
	
	override func handleRequestFinish(requesterId: String, result: AnyObject?) {
		Queues.main.async {
			self.songServiceObject = VSongServiceSettings.list().last
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
