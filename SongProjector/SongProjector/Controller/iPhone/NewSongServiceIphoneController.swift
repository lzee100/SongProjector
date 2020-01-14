//
//  NewSongServiceIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 26-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit
import MessageUI

class ClusterOrComment {
	let id: Int64?
	var cluster: VCluster?
	var isSelected = false
	
	init(cluster: VCluster?) {
		self.id = cluster?.id
		self.cluster = cluster
	}
	
	func refresh() {
		if let id = id, let cluster = VCluster.single(with: id) {
			self.cluster = cluster
		}
	}
}

class TempClustersModel {
	var clusters: [ClusterOrComment] = []
	var songServiceSettings: VSongServiceSettings?
	var sectionedClusterOrComment: [[ClusterOrComment]]
	var clusterToChange: ClusterOrComment?
	var hasNoSongs: Bool {
		return songServiceSettings != nil && sectionedClusterOrComment.count == 0 || clusters.count == 0 && songServiceSettings == nil
	}
	var errorIndexPath: IndexPath?
	
	
	init(clusters: [ClusterOrComment] = [], songServiceSettings: VSongServiceSettings? = nil, sectionedClusterIdsWithComments: [[ClusterOrComment]] = []) {
		self.clusters = clusters
		self.songServiceSettings = songServiceSettings
		self.sectionedClusterOrComment = sectionedClusterIdsWithComments
	}
	
	func refresh() {
		sectionedClusterOrComment.flatMap({ $0 }).forEach({ $0.refresh() })
	}
	
	func contains(_ cOrC: ClusterOrComment) -> Bool {
		if songServiceSettings != nil {
			if let sectionIndex = self.sectionedClusterOrComment.firstIndex(where: { (array) -> Bool in
				return array.contains(where: { $0.id == cOrC.id })
			}) {
				return self.sectionedClusterOrComment[sectionIndex].contains(where: { $0.id == cOrC.id })
			} else {
				return false
			}
		} else {
			return clusters.contains(where: { $0.id == cOrC.id })
		}
	}
	
	func delete(_ cOrC: ClusterOrComment) {
		if songServiceSettings == nil, let index = clusters.firstIndex(where: { $0.id == cOrC.id }) {
			clusters.remove(at: index)
		}
	}
	
	func append(_ cOrC: ClusterOrComment) {
		if songServiceSettings == nil {
			clusters.append(cOrC)
		}
	}
	
	func changePosition(_ cOrC: ClusterOrComment, to indexPath: IndexPath) {
		if songServiceSettings != nil {
			if let sectionIndex = self.sectionedClusterOrComment.firstIndex(where: { (array) -> Bool in
				return array.contains(where: { $0.id == cOrC.cluster?.id })
			}) {
				if let rowIndex = self.sectionedClusterOrComment[sectionIndex].firstIndex(where: { $0.id == cOrC.id }) {
					self.sectionedClusterOrComment[sectionIndex].remove(at: rowIndex)
					self.sectionedClusterOrComment[indexPath.section].insert(cOrC, at: indexPath.row)
				}
			}
		} else {
			if let index = clusters.firstIndex(where: { $0.id == cOrC.id }) {
				clusters.remove(at: index)
			}
		}
	}
	
	@discardableResult
	func change(old: ClusterOrComment, for new: ClusterOrComment) -> Bool {
		var updated = false
		if songServiceSettings != nil {
			if let sectionIndex = self.sectionedClusterOrComment.firstIndex(where: { (array) -> Bool in
				return array.contains(where: { $0.id == old.id })
			}) {
				if let rowIndex = self.sectionedClusterOrComment[sectionIndex].firstIndex(where: { $0.id == old.id }) {
					self.sectionedClusterOrComment[sectionIndex].remove(at: rowIndex)
					self.sectionedClusterOrComment[sectionIndex].insert(new, at: rowIndex)
					updated = true
				}
				updated = false
			}
			updated = false
		} else {
			if let index = clusters.firstIndex(where: { $0.id == old.id }) {
				clusters.remove(at: index)
				clusters.insert(new, at: index)
				updated = true
			}
			updated = false
		}
		updatePositions()
		return updated
	}
	
	func getManditoryTagsIds() -> [Int64] {
		if let songServiceSettings = songServiceSettings, let clusterToChange = clusterToChange {
			if let index = sectionedClusterOrComment.firstIndex(where: { (array) -> Bool in
				return array.contains(where: { $0.id == clusterToChange.id })
			}) {
				return songServiceSettings.sections[index].tagIds.compactMap({ Int64(exactly: $0) })
			}
		}
		return []
	}
	
	private func updatePositions() {
		for (index, cluster) in clusters.enumerated() {
			cluster.cluster?.position = Int16(exactly: index) ?? 0
		}
		sectionedClusterOrComment.forEach { (clusterOrComments) in
			for (index, clusterOrComment) in clusterOrComments.enumerated() {
				clusterOrComment.cluster?.position = Int16(exactly: index) ?? 0
			}
		}
	}
}

class NewSongServiceIphoneController: ChurchBeamTableViewController, UIGestureRecognizerDelegate, SongsControllerDelegate {
	

	@IBOutlet var done: UIBarButtonItem!
	@IBOutlet var add: UIBarButtonItem!
	@IBOutlet var share: UIBarButtonItem!
	@IBOutlet var emptyView: UIView!

	
	
	// MARK: - Properties

	var delegate: SongsControllerDelegate?
	var clusterModel: TempClustersModel!
	override var canBecomeFirstResponder: Bool {
		return true
	}
	
	
	
	// MARK: - ViewController Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		SongServiceSettingsFetcher.addObserver(self) 
		SongServiceSettingsFetcher.fetch()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		SongServiceSettingsFetcher.removeObserver(self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		if let songsController = segue.destination.unwrap() as? SongsController {
			songsController.delegate = self
			songsController.tempClusterModel = clusterModel
		}
	}

	
	
	// MARK: - TableView Functions
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return clusterModel.songServiceSettings?.sections.count ?? 1
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if clusterModel.songServiceSettings != nil {
			return clusterModel.sectionedClusterOrComment[section].count
		}
        let noSelection = clusterModel.hasNoSongs ? 1 : 0
		return clusterModel.clusters.count + noSelection
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if clusterModel.songServiceSettings != nil {
			if clusterModel.sectionedClusterOrComment.count == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: TextCell.identifier) as! TextCell
				cell.setupWith(text: Text.NewSongService.noSelectedSongs)
				return cell
			}
			if let cluster = clusterModel.sectionedClusterOrComment[indexPath.section][indexPath.row].cluster {
				let cell = tableView.dequeueReusableCell(withIdentifier: BasicCell.identifier) as! BasicCell
				cell.setup(title: cluster.title, icon: Cells.songIcon)
				return cell
			} else {
				let cell = tableView.dequeueReusableCell(withIdentifier: TextCell.identifier) as! TextCell
				cell.setupWith(text: Text.NewSongService.notEnoughSongsForTagSection)
				return cell
			}
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: BasicCell.identifier) as! BasicCell
		if clusterModel.clusters.count == 0 {
			cell.setup(title: Text.NewSongService.noSelectedSongs)
		} else {
			cell.setup(title: clusterModel.clusters[indexPath.row].cluster?.title ?? "", icon: Cells.songIcon)
		}

        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView.cellForRow(at: indexPath) is BasicCell {
			if clusterModel.songServiceSettings != nil {
				clusterModel.clusterToChange = clusterModel.sectionedClusterOrComment[indexPath.section][indexPath.row]
			} else {
				clusterModel.clusterToChange = clusterModel.clusters[indexPath.row]
			}
			UIApplication.shared.sendAction(add.action!, to: add.target, from: self, for: nil)
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if tableView.cellForRow(at: indexPath) is TextCell {
			return UITableViewAutomaticDimension
		}
		return 60
	}
	
	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return clusterModel.songServiceSettings == nil ? .delete : .none
	}
	
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
			clusterModel.clusters.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
			tableView.setNeedsDisplay()
			if tableView.numberOfRows(inSection: 0) == 0 {
				tableView.reloadData()
			}
        }
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
		if canMoveRow(from: fromIndexPath, to: to) {
			let itemToMode = clusterModel.sectionedClusterOrComment[fromIndexPath.section][fromIndexPath.row]
			clusterModel.changePosition(itemToMode, to: to)
		} else {
			
			tableView.reloadData()
			
		}
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return (tableView.cellForRow(at: indexPath) is TextCell) ? false : true
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if let settings = clusterModel.songServiceSettings {
			return settings.sections[section].title
		}
		return nil
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if clusterModel.songServiceSettings == nil {
			return CGFloat.leastNonzeroMagnitude
		}
		return HeaderView.basicSize.height
	}
	
	override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
		if(event?.subtype == UIEventSubtype.motionShake), let settings = VSongServiceSettings.list().last {
			clusterModel.songServiceSettings = settings
			clusterModel.clusters = []
			createRandomSongService()
			tableView.reloadData()
			add.title = Text.Actions.cancel
		}
	}
	
	
	
	// MARK: - Custom Functions

	func finishedSelection(_ model: TempClustersModel) {
		update()
	}
	
	
	
	// MARK: - Requester Functions
	
	override func handleRequestFinish(requesterId: String, result: AnyObject?) {
		DispatchQueue.main.async {
			self.update()
		}
	}
	
	
	
	// MARK: - Private Functions

	private func setup() {
		becomeFirstResponder()
		tableView.register(cell: Cells.basicCellid)
		tableView.register(cell: TextCell.identifier)
		done.title = Text.Actions.done
		add.title = Text.Actions.add
		
		emptyView.backgroundColor = themeWhiteBlackBackground
		
		let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		longPressGesture.minimumPressDuration = 0.7
		longPressGesture.delegate = self
		self.tableView.addGestureRecognizer(longPressGesture)
		
		let doubleTab = UITapGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		doubleTab.numberOfTapsRequired = 2
		view.addGestureRecognizer(doubleTab)
		
		update()
	}
	
	private func update() {
		let hasContent = clusterModel.songServiceSettings?.sections.count ?? 0 > 0
		share.isEnabled = hasContent
		share.tintColor = hasContent ? themeHighlighted : .clear
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
	
	private func createRandomSongService() {
		if let settings = VSongServiceSettings.list().last {
			clusterModel.songServiceSettings = settings
		}
		var sectionedClusterOrComments: [[ClusterOrComment]] = []
		let allClusters = VCluster.list()
		for (position, section) in (clusterModel.songServiceSettings?.sections ?? []).enumerated() {
			sectionedClusterOrComments.append([])
			for _ in 1...section.numberOfSongs {
				let allSelectedClusters = sectionedClusterOrComments.flatMap({ $0 }).compactMap({ $0.cluster })
				let candidateSongs = allClusters.filter({ !allSelectedClusters.contains(entity: $0) }).filter({ cluster in
					var contains = false
					for tag in cluster.hasTags {
						if section.hasTags.contains(entity: tag) {
							contains = true
							break
						}
					}
					return contains
				})
				if candidateSongs.count > 0 {
					let random = Int.random(in: 0...max(candidateSongs.count - 1, 0))
					sectionedClusterOrComments[position].append(ClusterOrComment(cluster: candidateSongs[random]))
				} else if sectionedClusterOrComments[position].filter({ $0.cluster == nil }).count == 0 {
					sectionedClusterOrComments[position].append(ClusterOrComment(cluster: nil))
				}
			}
		}
		clusterModel.sectionedClusterOrComment = sectionedClusterOrComments
	}
	
	private func canMoveRow(from: IndexPath, to: IndexPath) -> Bool {
		if clusterModel.songServiceSettings == nil {
			return true
		}
		let toRow = min(clusterModel.sectionedClusterOrComment[to.section].count - 1, to.row)
		if clusterModel.sectionedClusterOrComment[to.section][toRow].cluster == nil {
			return false
		}
		
		let clusterToMoveTagIds = clusterModel.sectionedClusterOrComment[from.section][from.row].cluster?.tagIds
		let sectionTo = clusterModel.songServiceSettings!.sections[to.section]
		if sectionTo.hasTags.contains(where: { (tag) -> Bool in
			clusterToMoveTagIds?.contains(where: { $0 == NSNumber(value: tag.id) }) ?? false
		}) {
			return true
		}
		return false
	}
	
	@IBAction func addPressed(_ sender: UIBarButtonItem) {
		if add.title == Text.Actions.add || clusterModel.clusterToChange != nil {
			let nav = Storyboard.MainStoryboard.instantiateViewController(withIdentifier: "SongsControllerNav")
			let vc = (nav.unwrap() as? SongsController)
			vc?.delegate = self
			vc?.tempClusterModel = clusterModel
			show(nav, sender: self)
		} else {
			add.title = Text.Actions.add
			clusterModel.songServiceSettings = nil
			clusterModel.sectionedClusterOrComment = []
			tableView.reloadData()
		}
		
		
	}
	
	
	@IBAction func shareSongServicePressed(_ sender: UIBarButtonItem) {
			if MFMailComposeViewController.canSendMail() {
				
				let message:String  = "dit zijn de liedjes voor \(Date())"
				
				let composePicker = MFMailComposeViewController()
				
				composePicker.mailComposeDelegate = self
				
				composePicker.delegate = self
				
				composePicker.setToRecipients([])
				
				composePicker.setSubject(Text.Users.inviteEmailSubject)
				
				composePicker.setMessageBody(message, isHTML: false)
				
				self.present(composePicker, animated: true, completion: nil)
				
			} else {
//				showAlertWith(title: nil, message: Text.Users.noEmail, actions: [UIAlertAction(title: Text.Actions.ok, style: .default, handler: nil)])
			}
		}
	
	@IBAction func donePressed(_ sender: UIBarButtonItem) {
		delegate?.finishedSelection(clusterModel)
		self.dismiss(animated: true)
	}
}




extension NewSongServiceIphoneController: UINavigationControllerDelegate {
	
}

extension NewSongServiceIphoneController: MFMailComposeViewControllerDelegate {
	
	func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith didFinishWithResult:MFMailComposeResult, error:Error?) {
		presentedViewController?.dismiss(animated: true)
	}

}
