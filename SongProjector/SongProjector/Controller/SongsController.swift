//
//  SongsController.swift
//  SongViewer
//
//  Created by Leo van der Zee on 13-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit

protocol SongsControllerDelegate {
	func didSelectClusters(_ clusters: [Cluster])
}

class SongsController: ChurchBeamViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, CustomSheetsControllerDelegate {
	func didCloseCustomSheet() {
		presentedViewController?.dismiss(animated: true, completion: nil)
	}
	
	
	
	
	@IBOutlet var new: UIBarButtonItem!
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var emptyView: UIView!
	
	
	
	// MARK: - Private Properties
	
	private var tags: [Tag] = []
	private var selectedTags: [Tag] = []
	private var clusters: [Cluster] = []
	private var selectedCluster: Cluster?
	private var filteredClusters: [Cluster] = []
	
	
	
	// MARK: Properties

	var delegate: SongsControllerDelegate?
	var selectedClusters: [Cluster] = []
	override var requesterId: String {
		return "SongsController"
	}
	var selectedSongserviceClusters: [Cluster] = [] {
		didSet {
			delegate?.didSelectClusters(selectedSongserviceClusters)
		}
	}
	
	
	
	// MARK: - UIViewController Functions

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ClusterFetcher.addObserver(self)
		ClusterSubmitter.addObserver(self)
		ClusterFetcher.fetch(force: false)
		searchBarCancelButtonClicked(searchBar)
		selectedTags = []
		mocBackground.perform {
			moc.reset()
			mocBackground.reset()
		}
		update()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		ClusterFetcher.removeObserver(self)
		ClusterSubmitter.removeObserver(self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination.unwrap() as? CustomSheetsController {
			vc.delegate = self
		}
	}
	
	
	
	// MARK: UITableview Functions
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredClusters.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
		
		if let cell = cell as? BasicCell {
			cell.setup(title: filteredClusters[indexPath.row].title, icon: Cells.songIcon)
			cell.setup(title: filteredClusters[indexPath.row].title, icon: Cells.songIcon, iconSelected: Cells.sheetIcon)
			cell.selectedCell = selectedSongserviceClusters.contains(filteredClusters[indexPath.row])
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return UITableViewCellEditingStyle.delete
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			if let index = clusters.index(of: filteredClusters[indexPath.row]) {
				ClusterSubmitter.submit([clusters[index]], requestMethod: .delete)
			}
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedCluster = filteredClusters[indexPath.row]
		if delegate != nil {
			if selectedSongserviceClusters.contains(filteredClusters[indexPath.row]) {
				selectedSongserviceClusters.delete(entity: filteredClusters[indexPath.row])
			} else {
				selectedSongserviceClusters.append(filteredClusters[indexPath.row])
			}
			tableView.reloadRows(at: [indexPath], with: .automatic)
		} else {
			if let name = UserDefaults.standard.value(forKey: "device") as? String, name == "ipad" {
				
				let customController = storyboard?.instantiateViewController(withIdentifier: "CustomSheetsController") as! CustomSheetsController
				customController.cluster = selectedCluster
				customController.isNew = false
				let nav = UINavigationController(rootViewController: customController)
				DispatchQueue.main.async {
					self.present(nav, animated: true)
				}
				
			} else {
				let customController = storyboard?.instantiateViewController(withIdentifier: "CustomSheetsIphoneController") as! CustomSheetsController
				customController.cluster = selectedCluster!
				customController.sheets = selectedCluster!.hasSheetsArray
				customController.delegate = self
				customController.isNew = false
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
		let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.themeCellCollection, for: indexPath)
		
		if let collectionCell = collectionCell as? ThemeCellCollection {
			collectionCell.setup(themeName: tags[indexPath.row].title ?? "")
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
		let font = UIFont.systemFont(ofSize: 17)
		let width = (tags[indexPath.row].title ?? "").width(withConstrainedHeight: 22, font: font) + 50
		return CGSize(width: width, height: 50)
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
	
	override func handleRequestFinish(requesterId: String, result: AnyObject?) {
		if requesterId == ClusterSubmitter.requesterId, let deletedCluster = (result as? [Cluster])?.first, let index = clusters.index(where: { $0.id == deletedCluster.id }) {
			clusters.remove(at: index)
			filteredClusters = clusters
			self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
		} else {
			update()
		}
	}
	
	private func setup() {
		
		tableView.register(cell: Cells.basicCellid)
		collectionView.register(UINib(nibName: Cells.themeCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.themeCellCollection)
		
		hideKeyboardWhenTappedAround()
		view.backgroundColor = themeWhiteBlackBackground
		
		navigationController?.title = Text.Songs.title
		title = Text.Songs.title
		cancel.title = Text.Actions.done
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
		clusters.sort(by: { ($0.title ?? "") < ($1.title ?? "") })
		CoreTag.setSortDescriptor(attributeName: "position", ascending: true)
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
		clusters = clusters.filter({ cluster in
			if selectedTags.contains(where: { (tag) -> Bool in
				return cluster.tagIds.contains(where: { NSNumber(value: tag.id) == $0 })
			}) {
				return true
			}
			return false
		})
	}

	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
	
}
