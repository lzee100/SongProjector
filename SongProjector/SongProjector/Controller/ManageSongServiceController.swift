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
    
	private var songServiceObject: VSongServiceSettings? = nil
	override var requesters: [RequesterBase] {
		return [SongServiceSettingsFetcher, SongServiceSettingsSubmitter]
	}
	
	// MARK: - UIView Functions

    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.register(cell: BasicCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
		tableView.register(cell: TextCell.identifier)
        tableView.register(header: BasicHeaderView.identifier)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        update()
		SongServiceSettingsFetcher.fetch()
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
        let numberOfSongsCell = 1
        let numberOfTags = (songServiceObject?.sections[section].hasTags(moc: moc).count ?? 0)
        let tagsHeader = numberOfTags > 0 ? 1 : 0
		return numberOfSongsCell + tagsHeader + numberOfTags
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.row == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: TextCell.identifier) as! TextCell
			cell.setupWith(text: AppText.SongServiceManagement.numberOfSongs + "\(songServiceObject?.sections[indexPath.section].numberOfSongs ?? 0)")
			return cell
		}
        
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TextCell.identifier) as! TextCell
            cell.setupWith(text: AppText.Tags.title + ":")
            cell.asSmallHeader()
            return cell
        }

		let cell = tableView.dequeueReusableCell(withIdentifier: BasicCell.identifier) as! BasicCell
		cell.setup(title: songServiceObject?.sections[indexPath.section].hasTags(moc: moc)[indexPath.row - 2].title, textColor: .blackColor)
        cell.titleLeftConstraint.constant = 30
		return cell
	}
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.style(cell, forRowAt: indexPath)
    }
        
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.basicHeaderView
        view?.descriptionLabel.text = songServiceObject?.sections[section].title ?? "No title"
        return view
    }
    	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return HeaderView.height
	}
    
    override func update() {
        let settings: [SongServiceSettings] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "updatedAt", ascending: false))
        self.songServiceObject = [settings.first].compactMap({ $0 }).map({ VSongServiceSettings(songserviceSettings: $0, context: moc) }).first
        self.addOrEditButton.title = self.songServiceObject == nil ? AppText.Actions.new : AppText.Actions.edit
        self.tableView.reloadData()
    }
	
	override func handleRequestFinish(requesterId: String, result: Any?) {
        update()
	}
    
}
