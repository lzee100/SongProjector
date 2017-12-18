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

class NewSongServiceController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, SongsControllerDelegate {

	struct Constants {
		static let songsControllerid = "SongsController"
	}
	
	@IBOutlet var doneButton: UIBarButtonItem!
	@IBOutlet var cancelButton: UIBarButtonItem!
	
	@IBOutlet var descriptionViewController: UILabel!
	@IBOutlet var tableView: UITableView!
	
	var delegate: NewSongServiceDelegate?
	var clusters: [Cluster] = []
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setup()
    }
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return clusters.count + 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if indexPath.row == clusters.count {
			let cell = tableView.dequeueReusableCell(withIdentifier: Cells.addButtonCellid, for: indexPath)
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
			
			if let cell = cell as? BasicCell {
				cell.setup(title: clusters[indexPath.row].title, icon: Cells.songIcon)
				cell.isLast = clusters.count == indexPath.row
			}
			return cell
		}
		
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return clusters.count == indexPath.row ? 200 : 60
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if clusters.count == indexPath.row {
			if let controller = storyboard?.instantiateViewController(withIdentifier: Constants.songsControllerid), let songsController = controller as? SongsController {
				songsController.delegate = self
				let navigationControllerSongs = UINavigationController(rootViewController: songsController)
				navigationController?.show(navigationControllerSongs, sender: self)
			}
		}
	}
	
	func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return indexPath.row == clusters.count ? .none : UITableViewCellEditingStyle.delete
	}
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			clusters.remove(at: indexPath.row)
			update()
		}
	}
	
	func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
		return indexPath.row == clusters.count ? false : true
	}
	
	func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let itemToMove = clusters[sourceIndexPath.row]
		clusters.remove(at: sourceIndexPath.row)
		clusters.insert(itemToMove, at: destinationIndexPath.row)
	}
	
	
	func didSelectCluster(cluster: Cluster) {
		clusters.append(cluster)
		update()
	}


	
	private func setup() {
		tableView.register(cell: Cells.basicCellid)
		tableView.register(cell: Cells.addButtonCellid)
		
		let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		longPressGesture.minimumPressDuration = 0.7
		longPressGesture.delegate = self
		self.tableView.addGestureRecognizer(longPressGesture)
		
		let doubleTab = UITapGestureRecognizer(target: self, action: #selector(self.editTableView(_:)))
		doubleTab.numberOfTapsRequired = 2
		view.addGestureRecognizer(doubleTab)
		
		self.tableView.tableFooterView = UIView()

		cancelButton.title = Text.NewSongViewController.CancelButonText
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
	
	private func changeEditingState(_ onlyIfEditing: Bool? = nil) {
		if let _ = onlyIfEditing {
			if tableView.isEditing {
				tableView.setEditing(false, animated: false)
			}
		} else {
			tableView.setEditing(tableView.isEditing ? false : true, animated: false)
		}
	}
	
	@IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
		dismiss(animated: true)
	}
	
	@IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
		delegate?.didFinishSongServiceSelection(clusters: clusters)
		dismiss(animated: true)
	}
	
	
}
