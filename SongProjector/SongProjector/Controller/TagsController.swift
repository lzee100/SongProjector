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
	
	override var requesterId: String {
		return "TagsController"
	}
	override var requesters: [RequesterType] {
		return [TagFetcher, TagSubmitter]
	}
	
	// MARK: - Private  Properties

	private var tags: [VTag] = []
	private var editingInfo: (RequestMethod, IndexPath?)?

	
	
	// MARK: - UIView Functions

	override func viewDidLoad() {
        super.viewDidLoad()
		self.title = Text.Tags.title
		tableView.register(cell: BasicCell.identifier)
		tableView.rowHeight = 60

		let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		longPressGesture.minimumPressDuration = 0.7
		self.tableView.addGestureRecognizer(longPressGesture)

		let doubleTab = UITapGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		doubleTab.numberOfTapsRequired = 2
		view.addGestureRecognizer(doubleTab)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		moc.reset()
		mocBackground.reset()
		tableView.setEditing(false, animated: false)
		TagFetcher.fetch()
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
	
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let itemToMove = tags[sourceIndexPath.row]
		tags.remove(at: sourceIndexPath.row)
		tags.insert(itemToMove, at: destinationIndexPath.row)
		updatePostitions()
		editingInfo = (.put, nil)
		TagSubmitter.submit(tags, requestMethod: .put)
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		return .delete
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
					if editingInfo.0 == .delete, let indexPath = editingInfo.1 {
						self.tags.remove(at: indexPath.row)
						self.tableView.deleteRows(at: [indexPath], with: .left)
					} else if editingInfo.0 == .put, let indexPath = editingInfo.1 {
						self.tags = VTag.list(sortOn: "position", ascending: true)
						self.tableView.reloadRows(at: [indexPath], with: .fade)
					} else {
						self.tags = VTag.list(sortOn: "position", ascending: true)
						self.tableView.reloadData()
					}
				} else {
					self.tags = VTag.list(sortOn: "position", ascending: true)
					self.tableView.reloadData()
				}
			}
			self.editingInfo = nil
		}
	}
	
	
	// MARK: - Private functions
	
	
	private func showEditTag(tag: VTag, indexPath: IndexPath) {
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
	
	private func updatePostitions() {
		for (index, tag) in tags.enumerated() {
			tag.position = Int16(index)
		}
	}
	
	@objc private func editTableView(_ gestureRecognizer: UIGestureRecognizer) {
		if let gestureRecognizer = gestureRecognizer as? UILongPressGestureRecognizer {
			if gestureRecognizer.state == UIGestureRecognizer.State.began {
				changeEditingState()
			}
		} // for double tab
		else if let _ = gestureRecognizer as? UITapGestureRecognizer, tableView.isEditing {
			changeEditingState()
		}
	}
	
	private func changeEditingState(_ onlyIfEditing: Bool? = nil) {
		if let _ = onlyIfEditing {
			if tableView.isEditing {
				tableView.setEditing(false, animated: false)
			}
		} else {
			tableView.setEditing(tableView.isEditing ? false : true, animated: false)
		}
	}
	
	
	
	// MARK: - IBAction functions
	
	@IBAction func didPressAddTag(_ sender: UIBarButtonItem) {
		let controller = UIAlertController(title: "Nieuwe tag", message: nil, preferredStyle: .alert)
		controller.addTextField { (textField) in
			textField.placeholder = "Naam"
		}
		controller.addAction(UIAlertAction(title: Text.Actions.save, style: .default, handler: { (_) in
			if let name = controller.textFields?.first?.text {
				let tag = VTag()
				tag.title = name
				TagSubmitter.submit([tag], requestMethod: .post)
			}
		}))
		controller.addAction(UIAlertAction(title: Text.Actions.cancel, style: .cancel, handler: { (_) in
			
		}))
		self.present(controller, animated: true)
	}

}
