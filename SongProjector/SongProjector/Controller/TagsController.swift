//
//  TagsController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 21-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

class TagsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIGestureRecognizerDelegate, NewTagControllerDelegate {
	
	
	@IBOutlet var add: UIBarButtonItem!
	@IBOutlet var pageDescription: UILabel!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var searchBar: UISearchBar!
	
	
	private var tags: [Tag] = []
	private var filteredTags: [Tag] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()

		if let splitViewController = splitViewController {
			collapseSecondaryViewController(self, for: splitViewController)
		}
		setup()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		update()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let newTagController = segue.destination as? NewTagController {
			newTagController.delegate = self
		}
	}
	
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredTags.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
		
		if let cell = cell as? BasicCell {
			cell.setup(title: filteredTags[indexPath.row].title, icon: Cells.tagIcon)
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		if let playerTitle = tags[indexPath.row].title, playerTitle == "Player" || playerTitle == "Songs"  {
			return UITableViewCellEditingStyle.none
		} else {
			return UITableViewCellEditingStyle.delete
		}
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let _ = CoreTag.delete(entity: tags[indexPath.row])
			tags.remove(at: indexPath.row)
			update()
		}
	}
	
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let itemToMove = filteredTags[sourceIndexPath.row]
		filteredTags.remove(at: sourceIndexPath.row)
		filteredTags.insert(itemToMove, at: destinationIndexPath.row)
	}
	
	
	
	public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText == "" {
			filteredTags = tags
		} else {
			let searchString = searchText.lowercased()
			filteredTags = tags.filter {
				if let title = $0.title {
					return title.lowercased().contains(searchString)
				} else {
					return false
				}
			}
		}
		tableView.reloadData()
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		searchBar.text = ""
		filteredTags = tags
		tableView.reloadData()
	}
	
	func hasNewTag() {
		update()
	}
	
	
	
	private func setup() {
		
		tableView.register(cell: Cells.basicCellid)
		
		navigationController?.title = Text.Songs.title
		
		searchBar.showsCancelButton = true
		searchBar.placeholder = Text.Songs.SearchSongPlaceholder
		add.title = Text.Actions.add
		
		let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		longPressGesture.minimumPressDuration = 0.7
		longPressGesture.delegate = self
		self.tableView.addGestureRecognizer(longPressGesture)
		
		let doubleTab = UITapGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		doubleTab.numberOfTapsRequired = 2
		view.addGestureRecognizer(doubleTab)
		
	}
	
	private func update() {
		tags = CoreTag.getEntities()
		filteredTags = tags
		tableView.reloadData()
	}
	
	@objc private func editTableView(_ gestureRecognizer: UIGestureRecognizer) {
		if let gestureRecognizer = gestureRecognizer as? UILongPressGestureRecognizer {
			if gestureRecognizer.state == UIGestureRecognizerState.began {
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
	
	@IBAction func addTagPressed(_ sender: UIBarButtonItem) {
		
	}
	
	
}
