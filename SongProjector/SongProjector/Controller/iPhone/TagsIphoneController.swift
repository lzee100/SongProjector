//
//  TagsIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 27-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

class TagsIphoneController: ChurchBeamTableViewController, UISearchBarDelegate, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate, NewOrEditIphoneControllerDelegate {
	
	

	@IBOutlet var add: UIBarButtonItem!
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var emptyView: UIView!
	
	override var requesterId: String {
		return "TagsIphoneController"
	}
	
	private var tags: [Tag] = []
	private var filteredTags: [Tag] = []
	private var selectedTag: Tag?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		TagFetcher.addObserver(self)
		TagSubmitter.addObserver(self)
		TagFetcher.request(force: false)
		searchBar.text = nil
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		TagFetcher.removeObserver(self)
		TagSubmitter.removeObserver(self)
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredTags.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
		
		if let cell = cell as? BasicCell {
			cell.setup(title: filteredTags[indexPath.row].title, icon: Cells.bulletOpen, iconSelected: Cells.bulletFilled)
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		if let playerTitle = tags[indexPath.row].title, playerTitle == "Player" || playerTitle == "Songs"  {
			return UITableViewCellEditingStyle.none
		} else {
			return UITableViewCellEditingStyle.delete
		}
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			TagSubmitter.submit([tags[indexPath.row]], requestMethod: .delete)
		}
	}
	
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let itemToMove = filteredTags[sourceIndexPath.row]
		filteredTags.remove(at: sourceIndexPath.row)
		filteredTags.insert(itemToMove, at: destinationIndexPath.row)
		updatePostitions()
		print("filtered tags to post \(filteredTags.count)")
		TagSubmitter.submit(filteredTags, requestMethod: .put)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedTag = filteredTags[indexPath.row]
		let controller = storyboard?.instantiateViewController(withIdentifier: "NewOrEditIphoneController") as! NewOrEditIphoneController
		controller.tag = selectedTag
		controller.modificationMode = .editTag
		controller.delegate = self
		let nav = UINavigationController(rootViewController: controller)
		present(nav, animated: true)
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
	
	func didCreate(sheet: Sheet) {
	}
	
	func didCloseNewOrEditIphoneController() {
		presentedViewController?.dismiss(animated: true, completion: nil)
	}
	
	override func handleRequestFinish(result: AnyObject?) {
//		let submittedTag = (result as? [Tag])?.first
//		if let position = filteredTags.firstIndex(where: { $0.id == submittedTag?.id }) {
//			tags.remove(at: Int(position))
//			filteredTags.remove(at: Int(position))
//			tableView.deleteRow(at: IndexPath(row: Int(position), section: 0), with: .left)
//		} else {
			Queues.main.async {
				self.update()
			}
//		}
	}
	
	private func setup() {
		tableView.register(cell: Cells.basicCellid)
		tableView.keyboardDismissMode = .interactive
		navigationController?.title = Text.Songs.title
		title = Text.Tags.title
		
		TagSubmitter.requestMethod = .delete
		
		searchBar.showsCancelButton = true
		searchBar.placeholder = Text.Tags.searchBarPlaceholderText
		searchBar.tintColor = themeHighlighted
		searchBar.delegate = self
		add.title = Text.Actions.add
		
		emptyView.backgroundColor = themeWhiteBlackBackground
		
		let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		longPressGesture.minimumPressDuration = 0.7
		longPressGesture.delegate = self
		self.tableView.addGestureRecognizer(longPressGesture)
		
		let doubleTab = UITapGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		doubleTab.numberOfTapsRequired = 2
		view.addGestureRecognizer(doubleTab)
	}
	
	private func update() {
		CoreTag.predicates.append("isHidden", notEquals: true)
		CoreTag.setSortDescriptor(attributeName: "position", ascending: true)
		tags = CoreTag.getEntities()
		print("tags get: \(tags.count)")
		filteredTags = tags
		tableView.reloadData()
	}
	
	private func updatePostitions() {
		for (index, tag) in filteredTags.enumerated() {
			tag.position = Int16(index)
		}
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
		let controller = storyboard?.instantiateViewController(withIdentifier: "NewOrEditIphoneController") as! NewOrEditIphoneController
		controller.modificationMode = .newTag
		controller.delegate = self
		let nav = UINavigationController(rootViewController: controller)
		present(nav, animated: true)
	}
}
