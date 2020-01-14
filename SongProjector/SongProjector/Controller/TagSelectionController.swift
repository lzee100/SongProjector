//
//  TagSelectionController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 29/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

protocol TagSelectionControllerDelegate {
	func didSelectTagsFor(section: Int, tags: [VTag])
}

class TagSelectionController: ChurchBeamViewController, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var cancelButton: UIBarButtonItem!
	@IBOutlet weak var doneButton: UIBarButtonItem!

	
	
	// MARK: - Private Properties

	private var tags: [VTag] = []
	
	
	
	// MARK: - Properties
	
	var section: Int = 0
	var selectedTags: [VTag] = []
	var delegate: TagSelectionControllerDelegate?
	override var requesterId: String {
		return "TagSelectionController"
	}
	override var requesters: [RequesterType] {
		return [TagFetcher]
	}
	
	
	// MARK: - UIView Functions
	
	override func viewDidLoad() {
        super.viewDidLoad()
		cancelButton.title = Text.Actions.cancel
		doneButton.title = Text.Actions.done
		tableView.rowHeight = 60
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.register(cell: BasicCell.identifier)
		TagFetcher.fetch()
	}
	
	
	
	// MARK: - UITableView Functions
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tags.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: BasicCell.identifier) as! BasicCell
		cell.setup(title: tags[indexPath.row].title, icon: Cells.bulletOpen, iconSelected: Cells.bulletFilled, textColor: themeWhiteBlackTextColor, hasPianoOnly: false)
		cell.selectedCell = selectedTags.contains(tags[indexPath.row])
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let index = selectedTags.firstIndex(of: tags[indexPath.row]) {
			selectedTags.remove(at: index)
		} else {
			selectedTags.append(tags[indexPath.row])
		}
		tableView.reloadRows(at: [indexPath], with: .fade)
	}
	
	
	
	// MARK: - Requester Functions

	override func handleRequestFinish(requesterId: String, result: AnyObject?) {
		Queues.main.async {
			self.tags = VTag.list(sortOn: "position", ascending: true)
			self.tableView.reloadData()
		}
	}
	
	
    
	// MARK: - IBAction Functions

	@IBAction func didPressCancel(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true)
	}
	
	@IBAction func didPressDone(_ sender: UIBarButtonItem) {
		delegate?.didSelectTagsFor(section: section, tags: selectedTags)
		self.dismiss(animated: true)
	}
}
