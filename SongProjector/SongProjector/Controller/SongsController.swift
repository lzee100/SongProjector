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

class SongsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating, UISearchBarDelegate {
	
	
	@IBOutlet var new: UIBarButtonItem!
	@IBOutlet var desciptionSongs: UILabel!
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var searchBar: UISearchBar!
	
	var delegate: SongsControllerDelegate?
	
	
	private var tags: [Tag] = []
	private var selectedTags: [Tag] = []
	private var clusters: [Cluster] = []
	private var filteredClusters: [Cluster] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		update()
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
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if delegate != nil {
			delegate?.didSelectCluster(cluster: clusters[indexPath.row])
			dismiss(animated: true)
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
			collectionCell.isSelectedCell = selectedTags.contains{ $0.id == tags[indexPath.row].id }
		}
		return collectionCell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if selectedTags.contains(tags[indexPath.row]) {
			if let index = selectedTags.index(where: { $0.id == tags[indexPath.row].id }) {
				selectedTags.remove(at: index)
			}
		} else {
			selectedTags.append(tags[indexPath.row])
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
	

	
	private func setup() {
		
		tableView.register(cell: Cells.basicCellid)
		collectionView.register(UINib(nibName: Cells.tagCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.tagCellCollection)
		
		if desciptionSongs != nil {
			desciptionSongs.text = Text.Songs.description
		}
		
		navigationController?.title = Text.Songs.title
		
		searchBar.showsCancelButton = true
		searchBar.placeholder = Text.Songs.SearchSongPlaceholder
		new.title = Text.Actions.add
		

	}
	
	private func update() {
		clusters = CoreCluster.getEntities()
		tags = CoreTag.getEntities()
		filterOnTags()
		filteredClusters = clusters
		tableView.reloadData()
		collectionView.reloadData()
	}
	
	private func filterOnTags() {
		if selectedTags.count != 0 {
			clusters = clusters.filter { (cluster) -> Bool in
				for selectedTag in selectedTags {
					if let contains = cluster.hasTags?.contains(selectedTag) {
						if contains {
							return true
						}
					}
				}
				return false
			}
		}
	}


}
