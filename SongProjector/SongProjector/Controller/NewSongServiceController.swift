//
//  NewSongServiceController.swift
//  SongViewer
//
//  Created by Leo van der Zee on 08-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit

protocol NewSongServiceDelegate {
	func didFinishSongServiceSelection(clusters: [Cluster])
}

class NewSongServiceController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UISearchBarDelegate {

	struct Constants {
		static let songsControllerid = "SongsController"
	}
	
	@IBOutlet var doneButton: UIBarButtonItem!
	@IBOutlet var cancelButton: UIBarButtonItem!
	
	@IBOutlet var descriptionSelectedSongs: UILabel!
	@IBOutlet var descriptionSongs: UILabel!
	
	@IBOutlet var tableViewSelectedSongs: UITableView!
	@IBOutlet var tableViewSongs: UITableView!
	@IBOutlet var searchBar: UISearchBar!
	
	@IBOutlet var collectionView: UICollectionView!
	
	var delegate: NewSongServiceDelegate?
	var filteredSongs: [Cluster] = []
	var songs: [Cluster] = []
	var selectedSongs: [Cluster] = []
	var tags: [Tag] = []
	var selectedTags: [Tag] = []

	
	override func viewDidLoad() {
        super.viewDidLoad()
		setup()
    }
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableView == tableViewSelectedSongs ? selectedSongs.count == 0 ? 1 : selectedSongs.count : songs.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if tableView == tableViewSelectedSongs {
			let cell = tableViewSelectedSongs.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
			if let cell = cell as? BasicCell {
				if selectedSongs.count == 0 {
					cell.setup(title: Text.NewSongService.noSelectedSongs)
					cell.isLast = true
					return cell
				}
				cell.setup(title: selectedSongs[indexPath.row].title, icon: Cells.songIcon)
				cell.isLast = selectedSongs.count == indexPath.row
			}
			return cell
		} else {
			let cell = tableViewSongs.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
			if let cell = cell as? BasicCell {
				cell.setup(title: filteredSongs[indexPath.row].title, icon: Cells.songIcon)
				cell.isLast = filteredSongs.count == indexPath.row
			}
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView == tableViewSongs, selectedSongs.contains(filteredSongs[indexPath.row]) {
			if let index = selectedSongs.index(of: filteredSongs[indexPath.row]) {
				selectedSongs.remove(at: index)
			}
		} else {
			selectedSongs.append(filteredSongs[indexPath.row])
		}
		tableViewSelectedSongs.reloadData()
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return tableView == tableViewSelectedSongs ? UITableViewCellEditingStyle.delete : UITableViewCellEditingStyle.none
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if tableView == tableViewSelectedSongs, editingStyle == .delete {
			selectedSongs.remove(at: indexPath.row)
			update()
		}
	}
	
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return tableView == tableViewSelectedSongs ? true : false
	}
	
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let itemToMove = selectedSongs[sourceIndexPath.row]
		selectedSongs.remove(at: sourceIndexPath.row)
		selectedSongs.insert(itemToMove, at: destinationIndexPath.row)
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
	
//	// MARK: - UISearchResultsUpdating Functions
//
//	func updateSearchResults(for searchController: UISearchController) {
//		if searchController.searchBar.text! == "" {
//			filteredClusters = clusters
//		} else {
//			let searchString = searchController.searchBar.text!.lowercased()
//			filteredClusters = clusters.filter {
//				if let title = $0.title {
//					return title.lowercased().contains(searchString)
//				} else {
//					return false
//				}
//			}
//		}
//
//		self.tableView.reloadData()
//	}
	
	public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		if searchText == "" {
			filteredSongs = songs
		} else {
			let searchString = searchText.lowercased()
			filteredSongs = songs.filter {
				if let title = $0.title {
					return title.lowercased().contains(searchString)
				} else {
					return false
				}
			}
		}
		self.tableViewSongs.reloadData()
	}
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		searchBar.resignFirstResponder()
		filteredSongs = songs
		tableViewSongs.reloadData()
	}

	
	private func setup() {
		tableViewSongs.register(cell: Cells.basicCellid)
		tableViewSelectedSongs.register(cell: Cells.basicCellid)
		collectionView.register(UINib(nibName: Cells.tagCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.tagCellCollection)
		
		navigationController?.title = Text.NewSongService.title
		descriptionSelectedSongs.text = Text.NewSongService.selectedSongsDescription
		descriptionSongs.text = Text.NewSongService.songsDescription
		
		searchBar.showsCancelButton = true
		searchBar.placeholder = Text.Songs.SearchSongPlaceholder

		let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		longPressGesture.minimumPressDuration = 0.7
		longPressGesture.delegate = self
		self.tableViewSelectedSongs.addGestureRecognizer(longPressGesture)
		
		let doubleTab = UITapGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		doubleTab.numberOfTapsRequired = 2
		view.addGestureRecognizer(doubleTab)
		
		cancelButton.title = Text.Actions.cancel
		doneButton.title = Text.Actions.done
		update()
	}
	
	private func update() {
		songs = CoreCluster.getEntities()
		tags = CoreTag.getEntities()
		filterOnTags()
		filteredSongs = songs
		
		tableViewSelectedSongs.reloadData()
		tableViewSongs.reloadData()
	}
	
	@objc private func editTableView(_ gestureRecognizer: UIGestureRecognizer) {
		if let gestureRecognizer = gestureRecognizer as? UILongPressGestureRecognizer {
			if gestureRecognizer.state == UIGestureRecognizerState.began {
				changeEditingState()
			}
		} // for double tab
		else if let _ = gestureRecognizer as? UITapGestureRecognizer, tableViewSelectedSongs.isEditing {
			changeEditingState()
		}
	}
	
	private func changeEditingState(_ onlyIfEditing: Bool? = nil) {
		if let _ = onlyIfEditing {
			if tableViewSelectedSongs.isEditing {
				tableViewSelectedSongs.setEditing(false, animated: false)
			}
		} else {
			tableViewSelectedSongs.setEditing(tableViewSelectedSongs.isEditing ? false : true, animated: false)
		}
	}
	
	private func filterOnTags() {
		if selectedTags.count != 0 {
			songs = songs.filter { (song) -> Bool in
				var hasTag = false
				for selectedTag in selectedTags {
					if let contains = song.hasTags?.contains(selectedTag) {
						if contains {
							hasTag = true
							break
						}
					}
				}
				return hasTag
			}
		}
	}
	
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
	
	@IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
		delegate?.didFinishSongServiceSelection(clusters: selectedSongs)
		dismiss(animated: true)
	}
	
	
}
