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
	var sectionedClusters = [[Any]]()
	
	override var canBecomeFirstResponder: Bool {
		return true
	}
	
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
		if songServiceSettings != nil {
			return sectionedClusters[section].count
		}
        let noSelection = hasNoSongs ? 1 : 0
		return selectedSongs.count + noSelection
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if songServiceSettings != nil {
			if (songServiceSettings == nil && selectedSongs.count == 0) || songServiceSettings != nil && sectionedClusters[indexPath.section].count == 0 {
				let cell = tableView.dequeueReusableCell(withIdentifier: TextCell.identifier) as! TextCell
				cell.setupWith(text: Text.NewSongService.noSelectedSongs)
				return cell
			}
			if let cluster = sectionedClusters[indexPath.section][indexPath.row] as? Cluster {
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
		if selectedSongs.count == 0 {
			cell.setup(title: Text.NewSongService.noSelectedSongs)
		} else {
			cell.setup(title: selectedSongs[indexPath.row].title, icon: Cells.songIcon)
		}

        return cell
    }
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if (songServiceSettings == nil && selectedSongs.count == 0) || songServiceSettings != nil && sectionedClusters[indexPath.section].count == 0 {
			return UITableViewAutomaticDimension
		}
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
	
	override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
		if(event?.subtype == UIEventSubtype.motionShake) {
			songServiceSettings = CoreSongServiceSettings.getEntities().first
			updateSectionsWithClusers()
			tableView.reloadData()
		}
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
		
		if selectedSongs.count == 0 {
			performSegue(withIdentifier: "SongsSegue", sender: self)
		}
		hasNoSongs = selectedSongs.count == 0
		
		update()
	}
	
	private func update() {
		if songServiceSettings != nil {
			songServiceSettings = CoreSongServiceSettings.getEntities().first
			updateSectionsWithClusers()
		}
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
	
	private func updateSectionsWithClusers() {
		sectionedClusters = []
		let allClusters = CoreCluster.getEntities()
		for (position, section) in (songServiceSettings?.sections ?? []).enumerated() {
			sectionedClusters.append([])
			for _ in 1...section.numberOfSongs {
				let allSelectedClusters = sectionedClusters.flatMap({ $0 }).compactMap({ $0 as? Cluster })
				let candidateSongs = allClusters.filter({ !allSelectedClusters.contains(entity: $0) }).filter({ cluster in
					var contains = false
					for tag in cluster.tags {
						if section.hasTags.contains(entity: tag) {
							contains = true
							break
						}
					}
					return contains
				})
				if candidateSongs.count > 0 {
					let random = Int.random(in: 0...max(candidateSongs.count - 1, 0))
					sectionedClusters[position].append(candidateSongs[random])
				} else if sectionedClusters[position].compactMap({ $0 as? Bool }).count == 0 {
					sectionedClusters[position].append(false)
				}
			}
		}
	}
	
	
	
	
	@IBAction func donePressed(_ sender: UIBarButtonItem) {
		delegate?.didFinishSongServiceSelection(clusters: selectedSongs, completion: {
			self.dismiss(animated: true)
		})
	}
}
