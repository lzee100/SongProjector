//
//  NewSongServiceIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 26-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

class NewSongServiceIphoneController: ChurchBeamTableViewController, SongsControllerDelegate, UIGestureRecognizerDelegate {
	

	@IBOutlet var done: UIBarButtonItem!
	@IBOutlet var add: UIBarButtonItem!
	@IBOutlet var emptyView: UIView!
	
	
	
	// MARK: - Properties

	var selectedSongs: [Cluster] = []
	var delegate: NewSongServiceDelegate?
	var hasNoSongs = true
	
	
	
	// MARK: - Private Properties
	
	private var songServiceSettings: SongServiceSettings? = nil
	
	
	
	// MARK: - ViewController Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		songServiceSettings = CoreSongServiceSettings.getEntities().first
		SongServiceSettingsFetcher.addObserver(self)
		SongServiceSettingsFetcher.fetch(force: false)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		SongServiceSettingsFetcher.removeObserver(self)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let navigationController = segue.destination
		if let songsController = navigationController.childViewControllers.first as? SongsController {
			songsController.delegate = self
			songsController.selectedClusters = selectedSongs
			songsController.selectedSongserviceClusters = selectedSongs
		}
	}

	
	
	// MARK: - TableView Functions
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return songServiceSettings?.sections.count ?? 1
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

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
		let itemToMove = selectedSongs[fromIndexPath.row]
		selectedSongs.remove(at: fromIndexPath.row)
		selectedSongs.insert(itemToMove, at: to.row)
		updatePositions()
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if let settings = songServiceSettings {
			return settings.sections[section].title
		}
		return nil
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		if songServiceSettings == nil {
			return CGFloat.leastNonzeroMagnitude
		}
		return HeaderView.basicSize.height
	}
	
	
	
	// MARK: - Custom Functions

	func didSelectClusters(_ clusters: [Cluster]) {
		hasNoSongs = false
		selectedSongs = clusters
		updatePositions()
		update()
	}
	
	
	
	// MARK: - Requester Functions
	
	override func handleRequestFinish(requesterId: String, result: AnyObject?) {
		songServiceSettings = CoreSongServiceSettings.getEntities().first
		tableView.reloadData()
	}
	
	
	
	// MARK: - Private Functions

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
