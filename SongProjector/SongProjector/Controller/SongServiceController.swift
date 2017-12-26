//
//  SongServiceController.swift
//  SongViewer
//
//  Created by Leo van der Zee on 05-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit
import CoreData

extension UIImage {
	
	func imageResize (sizeChange:CGSize)-> UIImage{
		
		let hasAlpha = true
		let scale: CGFloat = 0.0 // Use scale factor of main screen
		
		UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
		self.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
		
		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		return scaledImage!
	}
	
}

enum AnimationDirection {
	case left
	case right
}

struct Cells {
	static let songIcon = #imageLiteral(resourceName: "Song")
	static let sheetIcon = #imageLiteral(resourceName: "Sheet")
	static let tagIcon = #imageLiteral(resourceName: "BulletSelected")
	static let basicCellid = "BasicCell"
	static let addButtonCellid = "AddButtonCell"
	static let newSongSheetCellid = "NewSongSheetCell"
	static let tagCellCollection = "TagCellCollection"
	static let sheetCollectionCell = "SheetCollectionCell"
}

class SongServiceController: UIViewController, UITableViewDataSource, UITableViewDelegate, NewSongServiceDelegate, SongsControllerDelegate {
	
	
	// MARK: - Properties
	
	@IBOutlet var swipeRecognizerView: UIView!
	@IBOutlet var sheetDisplayPrevious: UIView!
	@IBOutlet var sheetDisplay: UIView!
	@IBOutlet var sheetDisplayNext: UIView!
	@IBOutlet var tableViewClusters: UITableView!
	@IBOutlet var tableViewSheets: UITableView!
	@IBOutlet var titleTableCluster: UILabel!
	@IBOutlet var titleTableSheet: UILabel!
	@IBOutlet var clear: UIBarButtonItem!
	@IBOutlet var toNewSongService: UIBarButtonItem!
	
	
	
	// MARK: - Private Properties
	
	private var hasTitle = true
	private var hasEmptySheet = false
	private var emptySheet = CoreSheet.createEntityNOTsave()
	private var externalScreen: UIScreen?
	private var externalScreenBounds = CGRect(x: 0, y: 0, width: 640, height: 480)
	private var clusters: [Cluster] = [] { didSet { update() } }
	private var selectedClusterRow = -1
	private var selectedSheetRow = -1
	private var selectedCluster: Cluster? {
		didSet {
			if hasEmptySheet {
				if selectedCluster == nil {
					removeEmptySheet()
				} else {
					addEmptySheet()
				}
			}
			createSheetListForDisplay()
			update()
			moveToFirstSheet()
		}
	}
	private var sheetsToDisplay: [UIImage] = []
	
	private var selectedSheet: Sheet? {
		didSet {
			displaySheet()
			update()
		}
	}
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
			return selectedCluster?.hasSheets?.count ?? 0
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
				if let sheet = sheetsForSelectedCluster?[indexPath.row] {
					cell.setup(title: sheet.title, icon: Cells.sheetIcon)
					cell.selectedCell = selectedSheet?.id == sheet.id
					cell.isLast = sheetsForSelectedCluster?.count == indexPath.row
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
		
		clusters = CoreCluster.getEntities()
		
		navigationController?.title = Text.SongService.title
		titleTableCluster.text = Text.SongService.titleTableClusters
		titleTableSheet.text = Text.SongService.titleTableSheets
		
		clear.title = Text.Actions.new
		toNewSongService.title = Text.Actions.add
		
		NotificationCenter.default.addObserver(forName: NotificationNames.externalScreen, object: nil, queue: nil, using: setExternalDisplay)
		
		let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		
		leftSwipe.direction = .left
		rightSwipe.direction = .right
		
		swipeRecognizerView.addGestureRecognizer(leftSwipe)
		swipeRecognizerView.addGestureRecognizer(rightSwipe)
		
		tableViewClusters.register(cell: Cells.basicCellid)
		tableViewSheets.register(cell: Cells.basicCellid)
		
		sheetDisplay.isHidden = true
		
		update()
		
	}
	
	private func update() {
		tableViewClusters.reloadData()
		tableViewSheets.reloadData()
	}
	
	private func moveToFirstSheet() {
		tableViewSheets.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
	}
	
	private func displaySheet() {
		if selectedSheet != nil {
			// display background
			sheetDisplay.isHidden = false
			
			
			if let numberOfSheets = sheetsForSelectedCluster?.count, let position = selectedSheet?.position {
				
				sheetDisplayNext.isHidden = position == numberOfSheets - 1 ? true : false
				sheetDisplayPrevious.isHidden = position == 0 ? true : false
				
				let selectedSheetPosition = Int(position)
				
				if selectedSheetPosition < (numberOfSheets) {
					
					// current sheet
					var image = sheetsToDisplay[selectedSheetPosition].imageResize(sizeChange: sheetDisplay.frame.size)
					sheetDisplay.backgroundColor = UIColor(patternImage: image)
					
					// next sheet
					if selectedSheetPosition < (numberOfSheets - 1) {
						image = sheetsToDisplay[selectedSheetPosition + 1].imageResize(sizeChange: sheetDisplayPrevious.frame.size)
						sheetDisplayNext.backgroundColor = UIColor(patternImage: image)
					}
					
					// previous sheet
					if selectedSheetPosition > 0 {
						let image = sheetsToDisplay[selectedSheetPosition - 1].imageResize(sizeChange: sheetDisplayPrevious.frame.size)
						sheetDisplayPrevious.backgroundColor = UIColor(patternImage: image)
					}
					
				}
			}
			
		} else {
			sheetDisplay.isHidden = true
			sheetDisplayNext.isHidden = true
			sheetDisplayPrevious.isHidden = true
		}
	}
	
	@objc private func respondToSwipeGesture(_ sender: UISwipeGestureRecognizer) {
		switch sender.direction {
		case .right:
			if var position = selectedSheet?.position {
				position -= 1
				if position >= 0 {
					animateSheetsWith(.right){
						self.selectedSheet = (self.selectedCluster?.hasSheets as! Set<Sheet>).first{ $0.position == position }
						if let position = self.selectedSheet?.position {
							self.tableViewSheets.scrollToRow(at: IndexPath(row: Int(position), section: 0), at: .middle, animated: true)
						}
					}
				} else {
					if let selectedCluster = selectedCluster, let index = clusters.index(of: selectedCluster) {
						if index - 1 >= 0 {
							self.selectedCluster = clusters[index - 1]
							self.selectedSheet = sheetsForSelectedCluster?[0]
							
							self.tableViewClusters.scrollToRow(at: IndexPath(row: index + 1, section: 0), at: .middle, animated: true)
						}
					}
				}
			}
		case .left:
			if let numberOfSheets = sheetsForSelectedCluster?.count, var position = selectedSheet?.position {
				position += 1
				if position < numberOfSheets {
					animateSheetsWith(.left){
						self.selectedSheet = (self.selectedCluster?.hasSheets as! Set<Sheet>).first{ $0.position == position }
						if let position = self.selectedSheet?.position {
							self.tableViewSheets.scrollToRow(at: IndexPath(row: Int(position), section: 0), at: .middle, animated: true)
						}
					}
				} else {
					if let selectedCluster = selectedCluster, let index = clusters.index(of: selectedCluster) {
						if index + 1 < clusters.count {
							self.selectedCluster = clusters[index + 1]
							self.selectedSheet = sheetsForSelectedCluster?[0]
							
							self.tableViewClusters.scrollToRow(at: IndexPath(row: index + 1, section: 0), at: .middle, animated: true)
						}
					}
				}
			}
		default:
			break
		}
	}
	
	private func addEmptySheet() {
		emptySheet.position = (sheetsForSelectedCluster?.last?.position ?? 0) + 1
		emptySheet.title = Text.Sheet.emptySheetTitle
		selectedCluster?.addToHasSheets(emptySheet)
	}
	
	private func removeEmptySheet() {
		selectedCluster?.removeFromHasSheets(emptySheet)
	}
	
	
	func setExternalDisplay(_ notification: Notification) {
		externalScreen = notification.userInfo?["screen"] as? UIScreen
	}
	
	@IBAction func clearButtonPressed(_ sender: UIBarButtonItem) {
		
	}
	
	private func createSheetListForDisplay() {
		sheetsToDisplay = []
		if let sheetsForSelectedCluster = sheetsForSelectedCluster {
			
			if let sheetController = storyboard?.instantiateViewController(withIdentifier: "SheetController") as? SheetController {
				sheetController.setView(CGRect(x: 0, y: 0, width: sheetDisplay.frame.width, height: sheetDisplay.frame.height))
				for sheet in sheetsForSelectedCluster {
					sheetController.isEmptySheet = sheet.title == Text.Sheet.emptySheetTitle ? true : false
					sheetController.hasTitle = hasTitle
					sheetController.songTitle = selectedCluster?.title
					sheetController.lyrics = sheet.lyrics
					sheetsToDisplay.append(sheetController.asImage())
				}
			}
		}
	}
	
	private func animateSheetsWith(_ direction : AnimationDirection, completion: @escaping () -> Void) {
		switch direction {
		case .left:
			
			if let numberOfSheets = sheetsForSelectedCluster?.count, let position = selectedSheet?.position {
				
				let selectedSheetPosition = Int(position)
				
				let navigationBarHeight = UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height
				
				// current sheet
				let imageCurrent = sheetsToDisplay[selectedSheetPosition].imageResize(sizeChange: sheetDisplay.frame.size)
				let currentSheetView = UIImageView(frame: CGRect(x: sheetDisplay.frame.minX, y: sheetDisplay.frame.minY + navigationBarHeight, width: sheetDisplay.frame.width, height: sheetDisplay.frame.height))
				currentSheetView.image = imageCurrent
				
				
				let imageNext = sheetsToDisplay[selectedSheetPosition + 1].imageResize(sizeChange: sheetDisplayNext.frame.size)
				let nextSheetView = UIImageView(frame: CGRect(x: sheetDisplayNext.frame.minX, y: sheetDisplayNext.frame.minY + navigationBarHeight, width: sheetDisplayNext.frame.width, height: sheetDisplayNext.frame.height))
				nextSheetView.image = imageNext
				
				view.addSubview(currentSheetView)
				view.addSubview(nextSheetView)
				sheetDisplay.isHidden = true
				sheetDisplayPrevious.isHidden = true
				sheetDisplayNext.isHidden = true
				UIView.animate(withDuration: 0.3, animations: {
					currentSheetView.frame = CGRect(x: self.sheetDisplayPrevious.frame.minX, y: self.sheetDisplayPrevious.frame.minY + navigationBarHeight, width: self.sheetDisplayPrevious.frame.width, height: self.sheetDisplayPrevious.frame.height)
					nextSheetView.frame = CGRect(x: self.sheetDisplay.frame.minX, y: navigationBarHeight, width: self.sheetDisplay.frame.width, height: self.sheetDisplay.frame.height)
				}, completion: { (bool) in
					self.sheetDisplay.isHidden = false
					self.sheetDisplayPrevious.isHidden = false
					nextSheetView.removeFromSuperview()
					currentSheetView.removeFromSuperview()
					completion()
				})
			}
			
			
		case .right:
			
			// show previous sheet
			if let numberOfSheets = sheetsForSelectedCluster?.count, let position = selectedSheet?.position {
				
				sheetDisplayNext.isHidden = position == numberOfSheets ? true : false
				sheetDisplayPrevious.isHidden = position == 0 ? true : false
				
				let selectedSheetPosition = Int(position)
				
				let navigationBarHeight = UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height
				
				// current sheet, move to right
				let imageCurrent = sheetsToDisplay[selectedSheetPosition].imageResize(sizeChange: sheetDisplay.frame.size)
				let currentSheetView = UIImageView(frame: CGRect(x: sheetDisplay.frame.minX, y: sheetDisplay.frame.minY + navigationBarHeight, width: sheetDisplay.frame.width, height: sheetDisplay.frame.height))
				currentSheetView.image = imageCurrent
				
				// previous sheet, move to right
				let imagePrevious = sheetsToDisplay[selectedSheetPosition - 1].imageResize(sizeChange: sheetDisplayPrevious.frame.size)
				let previousSheetView = UIImageView(frame: CGRect(x: sheetDisplayPrevious.frame.minX, y: sheetDisplayPrevious.frame.minY + navigationBarHeight, width: sheetDisplayPrevious.frame.width, height: sheetDisplayPrevious.frame.height))
				previousSheetView.image = imagePrevious
				
				view.addSubview(currentSheetView)
				view.addSubview(previousSheetView)
				sheetDisplay.isHidden = true
				sheetDisplayPrevious.isHidden = true
				sheetDisplayNext.isHidden = true
				UIView.animate(withDuration: 0.3, animations: {
					currentSheetView.frame = CGRect(x: self.sheetDisplayNext.frame.minX, y: self.sheetDisplayNext.frame.minY + navigationBarHeight, width: self.sheetDisplayNext.frame.width, height: self.sheetDisplayNext.frame.height)
					previousSheetView.frame = CGRect(x: self.sheetDisplay.frame.minX, y: navigationBarHeight, width: self.sheetDisplay.frame.width, height: self.sheetDisplay.frame.height)
				}, completion: { (bool) in
					self.sheetDisplay.isHidden = false
					self.sheetDisplayPrevious.isHidden = false
					previousSheetView.removeFromSuperview()
					currentSheetView.removeFromSuperview()
					completion()
				})
			}
		}
	}
	
}
