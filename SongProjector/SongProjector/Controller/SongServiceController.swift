//
//  SongServiceController.swift
//  SongViewer
//
//  Created by Leo van der Zee on 05-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit
import CoreData

struct Cells {
	static let songIcon = #imageLiteral(resourceName: "Song")
	static let sheetIcon = #imageLiteral(resourceName: "Sheet")
	static let tagIcon = #imageLiteral(resourceName: "BulletSelected")
	static let basicCellid = "BasicCell"
	static let addButtonCellid = "AddButtonCell"
	static let newSongSheetCellid = "NewSongSheetCell"
	static let tagCellCollection = "TagCellCollection"
}

class SongServiceController: UIViewController, UITableViewDataSource, UITableViewDelegate, NewSongServiceDelegate, SongsControllerDelegate {

	
	// MARK: - Properties
	
	@IBOutlet var sheetDisplayTitle: UILabel!
	@IBOutlet var sheetDisplayTitleHeightConstraint: NSLayoutConstraint!
	@IBOutlet var sheetDisplayLyrics: UITextView!
	@IBOutlet var sheetDisplay: UIView!
	@IBOutlet var tableViewClusters: UITableView!
	@IBOutlet var tableViewSheets: UITableView!
	@IBOutlet var titleTableCluster: UILabel!
	@IBOutlet var titleTableSheet: UILabel!
	@IBOutlet var clear: UIBarButtonItem!
	@IBOutlet var toNewSongService: UIBarButtonItem!
	
	
	
	// MARK: - Private Properties
	
	private var hasEmptySheet = true
	private var emptySheet = CoreSheet.createEntityNOTsave()
	private var externalScreen: UIScreen?
	private var clusters: [Cluster] = [] { didSet { update() } }
	private var selectedClusterRow = -1
	private var selectedSheetRow = -1
	private var selectedCluster: Cluster? { didSet { update() } }
	private var selectedSheet: Sheet? { didSet { displaySheet() } }
	private var sheetsForSelectedCluster: [Sheet]? {
		get {
			if let sheets = selectedCluster?.hasSheets as? Set<Sheet> {
				return sheets.sorted{ $0.position < $1.position }
			} else {
				return nil
			}
		}
	}
	
	
	
	// MARK: - Functions
	
	// MARK: UIViewController Functions

	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		update()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let controller = segue.destination as? UINavigationController, let newSongServiceController = controller.viewControllers.first as? NewSongServiceController {
			newSongServiceController.delegate = self
			newSongServiceController.songs = clusters
		}
		if let controller = segue.destination as? UINavigationController, let songsController = controller.viewControllers.first as? SongsController {
			songsController.delegate = self
		}
	}
	
	
	
	// MARK: UITableViewDelegate Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView == tableViewClusters {
			return clusters.count
		} else {
			var numberOfSheets = selectedCluster?.hasSheets?.count ?? 0
			numberOfSheets += (hasEmptySheet && selectedSheet != nil ? 1 : 0)
			return numberOfSheets
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if tableView == tableViewClusters {
			let cell = tableViewClusters.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
			if let cell = cell as? BasicCell {
				cell.setup(title: clusters[indexPath.row].title, icon: Cells.songIcon)
					cell.selectedCell = selectedCluster?.id == clusters[indexPath.row].id
			}
			return cell
		} else {
			let cell = tableViewSheets.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
			if let cell = cell as? BasicCell {
				if hasEmptySheet && indexPath.row == sheetsForSelectedCluster?.count {
					emptySheet.id = (sheetsForSelectedCluster?[indexPath.row - 1].id ?? 0) + 1
					cell.setup(title: emptySheet.title, icon: Cells.sheetIcon)
					cell.selectedCell = emptySheet.id == selectedSheet?.id
					cell.isLast = true
				} else {
					if let sheet = sheetsForSelectedCluster?[indexPath.row] {
						cell.setup(title: sheet.title, icon: Cells.sheetIcon)
						cell.selectedCell = selectedSheet?.id == sheet.id
						cell.isLast = sheetsForSelectedCluster?.count == indexPath.row
					}
				}
			}
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView == tableViewClusters {
			// selected a selected row, deselect the row
			if let selectedCluster = selectedCluster, selectedCluster.id == clusters[indexPath.row].id {
				self.selectedCluster = nil
				selectedSheet = nil
			} else {
				selectedCluster = clusters[indexPath.row]
				selectedSheet = sheetsForSelectedCluster?[0]
			}
		} else {
			if hasEmptySheet && (indexPath.row == sheetsForSelectedCluster?.count) {
				selectedSheet = selectedSheet?.id == emptySheet.id ? nil : emptySheet
			} else {
				if let selectedSheet = selectedSheet, selectedSheet.id == sheetsForSelectedCluster?[indexPath.row].id {
					self.selectedSheet = nil
				} else {
					selectedSheet = sheetsForSelectedCluster?[indexPath.row]
				}
			}
		}
		update()
	}
	
	
	
	// MARK: NewSongServiceDelegate Functions

	func didFinishSongServiceSelection(clusters: [Cluster]) {
		self.clusters = clusters
	}
	
	
	
	// MARK: SongsControllerDelegate Functions
	
	func didSelectCluster(cluster: Cluster){
		self.clusters.append(cluster)
	}

	
	
	// MARK: - Private Functions
	
	private func setup() {
		
		navigationController?.title = Text.SongService.title
		titleTableCluster.text = Text.SongService.titleTableClusters
		titleTableSheet.text = Text.SongService.titleTableSheets
		
		clear.title = Text.Actions.new
		toNewSongService.title = Text.Actions.add
		
		NotificationCenter.default.addObserver(forName: NotificationNames.externalScreen, object: nil, queue: nil, using: setExternalDisplay)
		
		tableViewClusters.register(cell: Cells.basicCellid)

		sheetDisplay.isHidden = true

		update()

	}
	
	private func update() {
		tableViewClusters.reloadData()
		tableViewSheets.reloadData()
	}
	
	private func displaySheet() {
		if selectedSheet != nil {
			// display background
			sheetDisplay.isHidden = false
			sheetDisplay.backgroundColor = .white
			
			if let title = selectedCluster?.title, let _ = selectedSheet?.title {
				sheetDisplayTitleHeightConstraint.constant = 50
				sheetDisplayTitle.text = title
			} else {
				sheetDisplayTitleHeightConstraint.constant = 0
			}
			if let selectedSheetLyrics = selectedSheet?.lyrics {
				sheetDisplayLyrics.text = selectedSheetLyrics
			} else {
				sheetDisplayLyrics.text = ""
			}

		} else {
			sheetDisplay.isHidden = true
			sheetDisplay.backgroundColor = .clear
		}
	}
	
	func setExternalDisplay(_ notification: Notification) {
		externalScreen = notification.userInfo?["screen"] as? UIScreen
	}
	
	@IBAction func clearButtonPressed(_ sender: UIBarButtonItem) {
		
	}
	
	
}
