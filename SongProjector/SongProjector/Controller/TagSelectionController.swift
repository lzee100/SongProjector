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
	override var requesters: [RequesterBase] {
		return [TagFetcher]
	}
	
	
	// MARK: - UIView Functions
	
	override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(header: BasicHeaderView.identifier)
		cancelButton.title = AppText.Actions.cancel
		doneButton.title = AppText.Actions.done
        cancelButton.tintColor = themeHighlighted
        doneButton.tintColor = themeHighlighted
		tableView.rowHeight = 60
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        update()
		tableView.register(cell: BasicCell.identifier)
		TagFetcher.fetch()
	}
	
	
	
	// MARK: - UITableView Functions
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tags.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: BasicCell.identifier) as! BasicCell
		cell.setup(title: tags[indexPath.row].title, textColor: .blackColor)
        cell.selectedCell = selectedTags.contains(where: { $0.id == tags[indexPath.row].id })
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = selectedTags.firstIndex(where: { $0.id == tags[indexPath.row].id }) {
			selectedTags.remove(at: index)
		} else {
			selectedTags.append(tags[indexPath.row])
		}
		tableView.reloadRows(at: [indexPath], with: .fade)
	}
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.style(cell, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.basicHeaderView
        view?.descriptionLabel.text = nil
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
	
    override func update() {
        let tags: [Tag] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted], sort: NSSortDescriptor(key: "position", ascending: true))
        self.tags = tags.map({ VTag(tag: $0, context: moc) })
        self.tableView.reloadData()
    }
	
	// MARK: - Requester Functions

	override func handleRequestFinish(requesterId: String, result: Any?) {
        update()
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
