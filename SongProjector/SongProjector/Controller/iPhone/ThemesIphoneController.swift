//
//  ThemesIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 27-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

class ThemesIphoneController: ChurchBeamTableViewController, UISearchBarDelegate, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate, NewOrEditIphoneControllerDelegate {
	
	

	@IBOutlet var add: UIBarButtonItem!
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var emptyView: UIView!
	
	override var requesterId: String {
		return "ThemesIphoneController"
	}
	
	private var themes: [VTheme] = []
	private var filteredThemes: [VTheme] = []
	private var selectedTheme: VTheme?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ThemeFetcher.addObserver(self)
		ThemeSubmitter.addObserver(self)
		ThemeFetcher.fetch()
		searchBar.text = nil
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		ThemeFetcher.removeObserver(self)
		ThemeSubmitter.removeObserver(self)
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredThemes.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
		
		if let cell = cell as? BasicCell {
			cell.setup(title: filteredThemes[indexPath.row].title, icon: Cells.bulletOpen, iconSelected: Cells.bulletFilled)
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		if let playerTitle = themes[indexPath.row].title, playerTitle == "Player" || playerTitle == "Songs"  {
			return UITableViewCellEditingStyle.none
		} else {
			return UITableViewCellEditingStyle.delete
		}
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			ThemeSubmitter.submit([themes[indexPath.row]], requestMethod: .delete)
		}
	}
	
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let itemToMove = filteredThemes[sourceIndexPath.row]
		filteredThemes.remove(at: sourceIndexPath.row)
		filteredThemes.insert(itemToMove, at: destinationIndexPath.row)
		updatePostitions()
		print("filtered themes to post \(filteredThemes.count)")
		ThemeSubmitter.submit(filteredThemes.compactMap({ $0 }), requestMethod: .put)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedTheme = filteredThemes[indexPath.row]
		let controller = storyboard?.instantiateViewController(withIdentifier: "NewOrEditIphoneController") as! NewOrEditIphoneController
		controller.theme = selectedTheme
		controller.modificationMode = .editTheme
		controller.delegate = self
		let nav = UINavigationController(rootViewController: controller)
		present(nav, animated: true)
	}
	
	
	
	public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText == "" {
			filteredThemes = themes
		} else {
			let searchString = searchText.lowercased()
			filteredThemes = themes.filter {
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
		filteredThemes = themes
		tableView.reloadData()
	}
	
	func hasNewTheme() {
		update()
	}
	
	func didCreate(sheet: VSheet) {
	}
	
	func didCloseNewOrEditIphoneController() {
		presentedViewController?.dismiss(animated: true, completion: nil)
	}
	
	override func handleRequestFinish(requesterId: String, result: AnyObject?) {
		Queues.main.async {
			self.update()
		}
	}
	
	private func setup() {
		tableView.register(cell: Cells.basicCellid)
		tableView.keyboardDismissMode = .interactive
		navigationController?.title = Text.Songs.title
		title = Text.Themes.title
		
		ThemeSubmitter.requestMethod = .delete
		
		searchBar.showsCancelButton = true
		searchBar.placeholder = Text.Themes.searchBarPlaceholderText
		searchBar.tintColor = themeHighlighted
		searchBar.delegate = self
		add.title = Text.Actions.add
		
		emptyView.backgroundColor = themeWhiteBlackBackground
		
		let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		longPressGesture.minimumPressDuration = 0.7
		self.tableView.addGestureRecognizer(longPressGesture)
		
		let doubleTab = UITapGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		doubleTab.numberOfTapsRequired = 2
		view.addGestureRecognizer(doubleTab)
	}
	
	private func update() {
		CoreTheme.predicates.append("isHidden", notEquals: true)
		themes = VTheme.list(sortOn: "position", ascending: true)
		print("themes get: \(themes.count)")
		filteredThemes = themes
		tableView.reloadData()
	}
	
	private func updatePostitions() {
		for (index, theme) in filteredThemes.enumerated() {
			theme.position = Int16(index)
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
	
	@IBAction func addThemePressed(_ sender: UIBarButtonItem) {
		let controller = storyboard?.instantiateViewController(withIdentifier: "NewOrEditIphoneController") as! NewOrEditIphoneController
		controller.modificationMode = .newTheme
		controller.delegate = self
		let nav = UINavigationController(rootViewController: controller)
		present(nav, animated: true)
	}
}
