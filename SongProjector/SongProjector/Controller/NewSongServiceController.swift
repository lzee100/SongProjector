//
//  NewSongServiceController.swift
//  SongViewer
//
//  Created by Leo van der Zee on 08-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit

protocol NewSongServiceDelegate {
	func didFinishSongServiceSelection(clusters: [Cluster], completion: () -> Void)
}

class NewSongServiceController: ChurchBeamViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, SongsControllerDelegate {
	
	
	@IBOutlet var addButton: UIBarButtonItem!
	@IBOutlet var donelButton: UIBarButtonItem!
	@IBOutlet var tableView: UITableView!
	
	
	
	// MARK: - Types
	
	struct Constants {
		static let songsControllerid = "SongsController"
	}
	
	
	
	// MARK: - Properties
	
	var delegate: NewSongServiceDelegate?
	var selectedClusters: [Cluster] = []
	
	
	
	// MARK: - Private Properties
	
	private var songServiceSettings: SongServiceSettings? = nil
	
	
	
	// MARK: - ViewController Functions
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setup()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		SongServiceSettingsFetcher.addObserver(self)
		SongServiceSettingsFetcher.fetch(force: false)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		SongServiceSettingsFetcher.removeObserver(self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination.unwrap() as? SongsController {
			vc.selectedSongserviceClusters = selectedClusters
			vc.delegate = self
		}
	}
	
	
	
	// MARK: - UITableview Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return songServiceSettings?.sections.count ?? 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if selectedClusters.count == 0 {
			return 1
		}
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
		if let cell = cell as? BasicCell {
			if selectedClusters.count == 0 {
				cell.setup(title: Text.NewSongService.noSelectedSongs)
				return cell
			}
			cell.setup(title: selectedClusters[indexPath.row].title, icon: Cells.songIcon)
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return .delete
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			selectedClusters.remove(at: indexPath.row)
			update()
		}
	}
	
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let itemToMove = selectedClusters[sourceIndexPath.row]
		selectedClusters.remove(at: sourceIndexPath.row)
		selectedClusters.insert(itemToMove, at: destinationIndexPath.row)
		for (index, song) in selectedClusters.enumerated() {
			song.position = Int16(index)
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if let settings = songServiceSettings {
			return settings.sections[section].title
		}
		return nil
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if songServiceSettings == nil {
			return CGFloat.leastNonzeroMagnitude
		}
		return HeaderView.basicSize.height
	}
	
	
	func didSelectClusters(_ clusters: [Cluster]) {
		selectedClusters = clusters
		update()
	}
	
	
	
	// MARK: - Requester Functions
	
	override func handleRequestFinish(requesterId: String, result: AnyObject?) {
		Queues.main.async {
			self.tableView.reloadData()
		}
	}
	
	
	
	// MARK: - Private Functions
	
	private func setup() {
		tableView.register(cell: Cells.basicCellid)
		navigationController?.title = Text.NewSongService.title
		
		let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		longPressGesture.minimumPressDuration = 0.7
		longPressGesture.delegate = self
		tableView.addGestureRecognizer(longPressGesture)
		
		let doubleTab = UITapGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		doubleTab.numberOfTapsRequired = 2
		view.addGestureRecognizer(doubleTab)
		
		donelButton.title = Text.Actions.done
		update()
	}
	
	private func update() {
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
	
	private func changeEditingState() {
		tableView.setEditing(tableView.isEditing ? false : true, animated: false)
	}
	
	
	
	// MARK: - IBAction Functions
	
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		for (index, cluster) in selectedClusters.enumerated() {
			cluster.position = Int16(index)
		}
		delegate?.didFinishSongServiceSelection(clusters: selectedClusters, completion: {
			dismiss(animated: true)
		})
	}
	
	
}
