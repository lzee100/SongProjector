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

class SongsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
	
	@IBOutlet var new: UIBarButtonItem!
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var emptyView: UIView!
	
	// MARK: - Private Properties
	
	private var isDeleting = false
	private var themes: [VTheme] = []
	private var selectedThemes: [VTheme] = []
	private var clusters: [Cluster] = []
	private var selectedCluster: Cluster?
	private var filteredClusters: [Cluster] = []
	
	
	// MARK: Properties

	var delegate: SongsControllerDelegate?
	var selectedClusters: [Cluster] = []
	
	
	// MARK: - UIViewController Functions

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		update()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
	}
	
	
	// MARK: UITableview Functions
	
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
				isDeleting = !isDeleting
				clusters.remove(at: index)
				let _ = CoreCluster.delete(entity: filteredClusters[index])
				filteredClusters = clusters
				self.tableView.deleteRows(at: [indexPath], with: .automatic)
				isDeleting = !isDeleting
			}
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectedCluster = filteredClusters[indexPath.row]
		if delegate != nil {
			DispatchQueue.main.async {
				self.delegate?.didSelectCluster(cluster: self.selectedCluster!)
			}
			dismiss(animated: true)
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
		return themes.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.tagCellCollection, for: indexPath)
		
		if let collectionCell = collectionCell as? TagCellCollection {
			collectionCell.setup(tagName: themes[indexPath.row].title ?? "")
			collectionCell.isSelectedCell = themes.contains(themes[indexPath.row])
		}
		return collectionCell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if themes.contains(themes[indexPath.row]), let index = themes.index(of: themes[indexPath.row]) {
			self.themes.remove(at: index)
		} else {
			self.themes.append(themes[indexPath.row])
		}
		update()
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 200, height: 50)
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
		
		NotificationCenter.default.addObserver(forName: NotificationNames.dataBaseDidChange, object: nil, queue: nil, using: dataBaseDidChange)

		hideKeyboardWhenTappedAround()
		view.backgroundColor = themeWhiteBlackBackground
		
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
		let newClusters = Array(Set(CoreCluster.getEntities()).subtracting(selectedClusters))
		clusters = newClusters
		CoreTheme.predicates.append("isHidden", equals: 0)
		CoreTheme.setSortDescriptor(attributeName: "position", ascending: false)
		themes = VTheme.getEntities()
		filterOnTags()
		filteredClusters = clusters
		tableView.reloadData()
		collectionView.reloadData()
	}
	
	private func filterOnTags() {
		if themes.count == 0 {
			return
		}
		clusters = clusters.filter { (cluster) -> Bool in
			if let theme = cluster.hasTheme {
				return themes.contains(theme)
			} else {return false}
		}
	}
	
	func dataBaseDidChange(notification: Notification) {
		if !isDeleting {
			update()
		}
	}

	@IBAction func cancelPressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
	
}
