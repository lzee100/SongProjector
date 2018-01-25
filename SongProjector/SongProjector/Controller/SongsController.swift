//
//  SongsController.swift
//  SongViewer
//
//  Created by Leo van der Zee on 13-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit

protocol SongsControllerDelegate {
	func didSelectCluster(cluster: Cluster)
}

class SongsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating, UISearchBarDelegate, CustomSheetsControllerDelegate {
	
	@IBOutlet var new: UIBarButtonItem!
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var emptyView: UIView!
	
	var delegate: SongsControllerDelegate?
	
	
	private var tags: [Tag] = []
	private var selectedTags: [Tag] = []
	private var clusters: [Cluster] = []
	private var selectedCluster: Cluster?
	private var filteredClusters: [Cluster] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		update()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "NewSongIphoneSegue" {
			if let nav = segue.destination as? UINavigationController {
				let songController = nav.topViewController as! NewSongIphoneController
				songController.editExistingCluster = false
				selectedCluster = nil
			}
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredClusters.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
		
		if let cell = cell as? BasicCell {
			cell.setup(title: filteredClusters[indexPath.row].title, icon: Cells.songIcon)
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return UITableViewCellEditingStyle.delete
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			if let index = clusters.index(of: filteredClusters[indexPath.row]) {
				let _ = CoreCluster.delete(entity: filteredClusters[indexPath.row])
				clusters.remove(at: index)
				filteredClusters = clusters
				self.tableView.deleteRows(at: [indexPath], with: .automatic)
			}
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedCluster = filteredClusters[indexPath.row]
		if delegate != nil {
			delegate?.didSelectCluster(cluster: selectedCluster!)
			dismiss(animated: true)
		} else {
			if selectedCluster!.isTypeSong {
				let controller = storyboard?.instantiateViewController(withIdentifier: "NewSongIphoneController") as! NewSongIphoneController
				controller.cluster = selectedCluster!
				controller.sheets = selectedCluster!.hasSheetsArray as? [SheetTitleContentEntity] ?? []
				controller.editExistingCluster = true
				let nav = UINavigationController(rootViewController: controller)
				DispatchQueue.main.async {
					self.present(nav, animated: true)
				}
			} else {
				let customController = storyboard?.instantiateViewController(withIdentifier: "CustomSheetsIphoneController") as! CustomSheetsIphoneController
				customController.cluster = selectedCluster!
				customController.sheets = selectedCluster!.hasSheetsArray
				let nav = UINavigationController(rootViewController: customController)
				DispatchQueue.main.async {
					self.present(nav, animated: true)
				}
			}
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return tags.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.tagCellCollection, for: indexPath)
		
		if let collectionCell = collectionCell as? TagCellCollection {
			collectionCell.setup(tagName: tags[indexPath.row].title ?? "")
			collectionCell.isSelectedCell = selectedTags.contains(tags[indexPath.row])
		}
		return collectionCell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if selectedTags.contains(tags[indexPath.row]), let index = selectedTags.index(of: tags[indexPath.row]) {
			self.selectedTags.remove(at: index)
		} else {
			self.selectedTags.append(tags[indexPath.row])
		}
		update()
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 200, height: 50)
	}
	
	// MARK: - UISearchResultsUpdating Functions

	func updateSearchResults(for searchController: UISearchController) {
		if searchController.searchBar.text! == "" {
			filteredClusters = clusters
		} else {
			let searchString = searchController.searchBar.text!.lowercased()
			filteredClusters = clusters.filter {
				if let title = $0.title {
					return title.lowercased().contains(searchString)
				} else {
					return false
				}
			}
		}

		self.tableView.reloadData()
	}
	
	public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText == "" {
			filteredClusters = clusters
		} else {
			let searchString = searchText.lowercased()
			filteredClusters = clusters.filter {
				if let title = $0.title {
					return title.lowercased().contains(searchString)
				} else {
					return false
				}
			}
		}
		
		self.tableView.reloadData()
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		searchBar.text = ""
		filteredClusters = clusters
		self.tableView.reloadData()
	}
	
	// MARK: - Delegate functions
	
	func didSaveSheets(sheets: [Sheet]) {
		tableView.reloadData()
	}
	private func setup() {
		
		tableView.register(cell: Cells.basicCellid)
		collectionView.register(UINib(nibName: Cells.tagCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.tagCellCollection)
		
		NotificationCenter.default.addObserver(forName: NotificationNames.dataBaseDidChange, object: nil, queue: nil, using: dataBaseDidChange)

		hideKeyboardWhenTappedAround()
		
		navigationController?.title = Text.Songs.title
		title = Text.Songs.title
		cancel.title = Text.Actions.cancel
		cancel.tintColor = delegate == nil ? .clear : themeHighlighted
		emptyView.backgroundColor = themeWhiteBlackBackground

		if delegate == nil {
			self.navigationItem.leftBarButtonItem = nil
		}
		navigationController?.title = Text.Songs.title
		tableView.keyboardDismissMode = .interactive
		
		searchBar.showsCancelButton = true
		searchBar.placeholder = Text.Songs.SearchSongPlaceholder
		searchBar.tintColor = themeHighlighted

	}
	
	private func update() {
		clusters = CoreCluster.getEntities()
		CoreTag.predicates.append("isHidden", notEquals: true)
		tags = CoreTag.getEntities()
		filterOnTags()
		filteredClusters = clusters
		tableView.reloadData()
		collectionView.reloadData()
	}
	
	private func filterOnTags() {
		if selectedTags.count == 0 {
			return
		}
		clusters = clusters.filter { (cluster) -> Bool in
			if let tag = cluster.hasTag {
				return selectedTags.contains(tag)
			} else {return false}
		}
	}
	
	func dataBaseDidChange(notification: Notification) {
		update()
	}

	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
	
	@IBAction func new(_ sender: UIBarButtonItem) {
		SheetPickerMenu.showMenu(sender: self)
	}
}
