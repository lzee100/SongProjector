//
//  TagsController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 25/03/2019.
//  Copyright © 2019 iozee. All rights reserved.
//

import UIKit

class TagsController: ChurchBeamViewController, UITableViewDataSource, UITableViewDelegate {
	
	// MARK: - Properties

	@IBOutlet var tableView: UITableView!
	
	
	
	// MARK: - Private  Properties

	private var tags: [Tag] = []
	private var editingInfo: (RequestMethod, IndexPath)?

	
	
	// MARK: - UIView Functions

	override func viewDidLoad() {
        super.viewDidLoad()
		TagFetcher.addObserver(self)
		TagSubmitter.addObserver(self)
		self.title = Text.Tags.title
		tableView.register(cell: BasicCell.identifier)
		tableView.rowHeight = 60
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		TagFetcher.fetch(force: false)
	}
	
	
	
	// MARK: - UITableView Functions
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tags.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: BasicCell.identifier) as! BasicCell
		
		cell.setup(title: tags[indexPath.row].title ?? "No name")
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return .delete
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		editingInfo = (.delete, indexPath)
		
		TagSubmitter.submit([tags[indexPath.row]], requestMethod: .delete)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		showEditTag(tag: tags[indexPath.row], indexPath: indexPath)
	}
	
	
	override func requestDidFinish(requesterID: String, response: ResponseType, result: AnyObject?) {
		Queues.main.async {
			self.hideLoader()
			switch response {
			case .error(_, _): super.show(error: response)
			case .OK(_):
				if requesterID == TagSubmitter.requesterId, let editingInfo = self.editingInfo {
					if editingInfo.0 == .delete {
						self.tags.remove(at: editingInfo.1.row)
						self.tableView.deleteRow(at: editingInfo.1, with: UITableViewRowAnimation.left)
					} else {
						self.tags = CoreTag.getEntities()
						self.tableView.reloadRows(at: [editingInfo.1], with: .fade)
					}
				} else {
					self.tags = CoreTag.getEntities()
					CoreUser.setSortDescriptor(attributeName: "title", ascending: true)
					self.tableView.reloadData()
				}
			}
			self.editingInfo = nil
		}
	}
	
	
	// MARK: - Private functions
	
	
	private func showEditTag(tag: Tag, indexPath: IndexPath) {
		let name = tag.title
		let controller = UIAlertController(title: "Nieuwe tag", message: nil, preferredStyle: .alert)
		controller.addTextField { (textField) in
			textField.placeholder = "Naam"
			textField.text = name
		}
		controller.addAction(UIAlertAction(title: Text.Actions.save, style: .default, handler: { (_) in
			if let newName = controller.textFields?.first?.text, name != newName, !newName.isBlanc {
				tag.title = newName
				self.editingInfo = (.put, indexPath)
				TagSubmitter.submit([tag], requestMethod: .put)
			}
		}))
		controller.addAction(UIAlertAction(title: Text.Actions.cancel, style: .cancel, handler: { (_) in
			
		}))
		self.present(controller, animated: true)
	}
	
	
	// MARK: - IBAction functions
	
	@IBAction func didPressAddTag(_ sender: UIBarButtonItem) {
		let controller = UIAlertController(title: "Nieuwe tag", message: nil, preferredStyle: .alert)
		controller.addTextField { (textField) in
			textField.placeholder = "Naam"
		}
		controller.addAction(UIAlertAction(title: Text.Actions.save, style: .default, handler: { (_) in
			if let name = controller.textFields?.first?.text {
				let tag = CoreTag.createEntityNOTsave()
				tag.title = name
				TagSubmitter.submit([tag], requestMethod: .post)
			}
		}))
		controller.addAction(UIAlertAction(title: Text.Actions.cancel, style: .cancel, handler: { (_) in
			
		}))
		self.present(controller, animated: true)
	}

}
