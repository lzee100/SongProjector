//
//  NewSongServiceIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 26-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

class NewSongServiceIphoneController: UITableViewController, SongsControllerDelegate, UIGestureRecognizerDelegate {

	@IBOutlet var done: UIBarButtonItem!
	@IBOutlet var add: UIBarButtonItem!
	@IBOutlet var emptyView: UIView!
	
	var selectedSongs: [Cluster] = []
	var delegate: NewSongServiceDelegate?
	var hasNoSongs = true
	
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let navigationController = segue.destination
		if let songsController = navigationController.childViewControllers.first as? SongsController {
			songsController.delegate = self
			songsController.selectedClusters = selectedSongs
		}
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let noSelection = hasNoSongs ? 1 : 0
		return selectedSongs.count + noSelection
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
		
		if selectedSongs.count < 1, let cell = cell as? BasicCell {
			cell.setup(title: Text.NewSongService.noSelectedSongs)
		} else if let cell = cell as? BasicCell {
			cell.setup(title: selectedSongs[indexPath.row].title, icon: Cells.songIcon)
		}

        return cell
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
			selectedSongs.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
		tableView.setNeedsDisplay()
		if tableView.numberOfRows(inSection: 0) == 0 {
			hasNoSongs = true
			tableView.reloadData()
		}
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
		let itemToMove = selectedSongs[fromIndexPath.row]
		selectedSongs.remove(at: fromIndexPath.row)
		selectedSongs.insert(itemToMove, at: to.row)
		updatePositions()
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
	
	func didSelectCluster(cluster: Cluster) {
		hasNoSongs = false
		selectedSongs.append(cluster)
		updatePositions()
		update()
	}
	
	private func setup() {
		tableView.register(cell: Cells.basicCellid)
		
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
		
		if selectedSongs.count == 0 {
			performSegue(withIdentifier: "SongsSegue", sender: self)
		}
		hasNoSongs = selectedSongs.count == 0
		
		update()
	}
	
	private func update() {
		tableView.reloadData()
	}
	
	private func updatePositions() {
		for (index, song) in selectedSongs.enumerated() {
			song.position = Int16(index)
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
	
	
	
	
	@IBAction func donePressed(_ sender: UIBarButtonItem) {
		delegate?.didFinishSongServiceSelection(clusters: selectedSongs, completion: {
			self.dismiss(animated: true)
		})
	}
}
