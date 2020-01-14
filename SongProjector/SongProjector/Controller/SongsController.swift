//
//  SongsController.swift
//  SongViewer
//
//  Created by Leo van der Zee on 13-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit

protocol SongsControllerDelegate {
	func finishedSelection(_ model: TempClustersModel)
}

class SongsController: ChurchBeamViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, CustomSheetsControllerDelegate {
	func didCloseCustomSheet() {
		presentedViewController?.dismiss(animated: true, completion: nil)
	}
	
	
	
	
	@IBOutlet var new: UIBarButtonItem!
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var tableView: TransParentTableView!
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var cancel: UIBarButtonItem!
	
	
	// MARK: - Private Properties
	
	private var tags: [VTag] = []
	private var selectedTags: [VTag] = []
	private var clusters: [VCluster] = []
	private var selectedCluster: VCluster?
	private var filteredClusters: [VCluster] = []
	
	
	
	// MARK: Properties

	var delegate: SongsControllerDelegate?
	var tempClusterModel: TempClustersModel?
	
	override var requesterId: String {
		return "SongsController"
	}
	override var requesters: [RequesterType] {
		return [ClusterFetcher, ClusterSubmitter]
	}
	var manditoryTagIds: [Int64]?
	
	// MARK: - UIViewController Functions

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ClusterFetcher.fetch()
		searchBarCancelButtonClicked(searchBar)
		selectedTags = []
		manditoryTagIds = tempClusterModel?.songServiceSettings == nil ? nil : tempClusterModel?.getManditoryTagsIds()
		update()
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
			cell.setup(title: filteredClusters[indexPath.row].title, icon: Cells.songIcon, iconSelected: Cells.sheetIcon)
			let hasUnsectionedClusters = tempClusterModel?.clusters.count ?? 0 != 0
			let clusters = hasUnsectionedClusters ? tempClusterModel?.clusters : tempClusterModel?.sectionedClusterOrComment.flatMap({ $0 })
			cell.selectedCell = clusters?.contains(where: { filteredClusters[indexPath.row].id == $0.id }) ?? false
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
		if let delegate = delegate {
			let currentCorC = ClusterOrComment(cluster: filteredClusters[indexPath.row])
			if let model = tempClusterModel, let clusterToChange = model.clusterToChange {
				if !model.sectionedClusterOrComment.flatMap({ $0 }).contains(where: { $0.id == currentCorC.id }) {
					model.change(old: clusterToChange, for: currentCorC)
					delegate.finishedSelection(model)
					self.dismiss(animated: true)
				}
			}
			else if tempClusterModel?.songServiceSettings == nil {
				if tempClusterModel?.contains(currentCorC) ?? false {
					tempClusterModel?.delete(currentCorC)
				} else {
					tempClusterModel?.append(currentCorC)
				}
			}
			// if not able to delete, then append
			else if tempClusterModel?.contains(ClusterOrComment(cluster: filteredClusters[indexPath.row])) ?? false {
				tempClusterModel?.delete(ClusterOrComment(cluster: filteredClusters[indexPath.row]))
			} else {
				tempClusterModel?.append(ClusterOrComment(cluster: filteredClusters[indexPath.row]))
			}
			tableView.reloadRows(at: [indexPath], with: .automatic)
		} else {
			if let name = UserDefaults.standard.value(forKey: "device") as? String, name == "ipad" {
				
				let customController = Storyboard.Ipad.instantiateViewController(withIdentifier: "CustomSheetsController") as! CustomSheetsController
				customController.cluster = selectedCluster
				customController.isNew = false
				let nav = UINavigationController(rootViewController: customController)
				DispatchQueue.main.async {
					self.present(nav, animated: true)
				}
				
			} else {
				let customController = storyboard?.instantiateViewController(withIdentifier: "CustomSheetsIphoneController") as! CustomSheetsController
				customController.cluster = selectedCluster!
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
	
	
	
	// MARK: - CollectionView Functions
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return tags.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.themeCellCollection, for: indexPath)
		
		if let collectionCell = collectionCell as? ThemeCellCollection {
			collectionCell.setup(themeName: tags[indexPath.row].title ?? "")
			if let manditoryTagIds = manditoryTagIds {
				let manditoryTags = VTag.list().filter({ manditoryTagIds.contains($0.id) })
				collectionCell.isSelectedCell = manditoryTags.contains(entity: tags[indexPath.row])
			} else {
				collectionCell.isSelectedCell = selectedTags.contains(entity: tags[indexPath.row])
			}
		}
		return collectionCell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if manditoryTagIds != nil {
			return
		}
		if let index = selectedTags.firstIndex(entity: tags[indexPath.row]) {
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
			tempClusterModel?.delete(ClusterOrComment(cluster: clusters[index]))
			clusters.remove(at: index)
			filteredClusters = clusters
			self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
		} else {
			tempClusterModel?.refresh()
			update()
		}
	}
	
	private func setup() {
		
		tableView.register(cell: Cells.basicCellid)
		collectionView.register(UINib(nibName: Cells.themeCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.themeCellCollection)
		
		hideKeyboardWhenTappedAround()
		
		navigationController?.title = Text.Songs.title
		title = Text.Songs.title
		cancel.title = Text.Actions.done
		cancel.tintColor = delegate == nil ? .clear : themeHighlighted
		
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
		clusters = VCluster.list(sortOn: "title", ascending: true)
		tags = VTag.list(sortOn: "position", ascending: true)
		filterOnTags()
		if let manditoryTagIds = manditoryTagIds?.compactMap({ NSNumber(value: $0) }) {
			filteredClusters = clusters.filter({ cluster in
				manditoryTagIds.contains(where: { (manditoryTagId) -> Bool in
					cluster.tagIds.contains(manditoryTagId)
				})
			})
		} else {
			filteredClusters = clusters
		}
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
		if let model = tempClusterModel {
			delegate?.finishedSelection(model)
		}
		dismiss(animated: true)
	}
	
}

class TransParentTableView: UITableView {
	
	override func awakeFromNib() {
		super.awakeFromNib()
		backgroundColor = .clear
		let blurEffect = UIBlurEffect(style: .extraLight)
		let blurEffectView = UIVisualEffectView(effect: blurEffect)
		blurEffectView.frame = frame
		backgroundView = blurEffectView
		separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
		let bottomView = UIView()
		bottomView.backgroundColor = .clear
		tableFooterView = bottomView
	}
}

class BlurredViewDark: UIView {
	
	override func awakeFromNib() {
		super.awakeFromNib()
		backgroundColor = .clear
		let blurEffect = UIBlurEffect(style: .prominent)
		let blurEffectView = UIVisualEffectView(effect: blurEffect)
		blurEffectView.frame = bounds
		addSubview(blurEffectView)
		sendSubview(toBack: blurEffectView)
		blurEffectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
		blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
		blurEffectView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
		blurEffectView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
	}
}
