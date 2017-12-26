//
//  SongServiceIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit

class SongServiceIphoneController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

	@IBOutlet var clear: UIBarButtonItem!
	@IBOutlet var new: UIBarButtonItem!
	@IBOutlet var sheetDisplaySwipeView: UIView!

	@IBOutlet var sheetDisplayerPrevious: UIImageView!
	@IBOutlet var sheetDisplayer: UIImageView!
	@IBOutlet var sheetDisplayerNext: UIImageView!
	
	@IBOutlet var sheetDisplayerContainerHeight: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerPreviousHeight: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerNextHeight: NSLayoutConstraint!
	
	@IBOutlet var moveUpDownSection: UIView!
	@IBOutlet var tableView: UITableView!
	

	// MARK: - Private Properties
	
	private var hasTitle = true
	private var hasEmptySheet = false
	private var emptySheet = CoreSheet.createEntityNOTsave()
	private var externalScreen: UIScreen?
	private var externalScreenBounds = CGRect(x: 0, y: 0, width: 640, height: 480)
	private var clusters: [Cluster] = [] { didSet { update() } }
	private var selectedClusterRow = -1
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
			update()
			displaySheets()
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
	
//	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//		if let controller = segue.destination as? UINavigationController, let newSongServiceController = controller.viewControllers.first as? NewSongServiceController {
//			newSongServiceController.delegate = self
//			newSongServiceController.songs = clusters
//		}
//		if let controller = segue.destination as? UINavigationController, let songsController = controller.viewControllers.first as? SongsController {
//			songsController.delegate = self
//		}
//	}
	
	
	
	// MARK: UITableViewDelegate Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
			return clusters.count + (sheetsForSelectedCluster?.count ?? 0)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
			if let cell = cell as? BasicCell {
				print(indexPath.row)
				if sheetsForSelectedCluster != nil && indexPath.row > selectedClusterRow && indexPath.row <= (selectedClusterRow + (sheetsForSelectedCluster?.count ?? 0)){
					// sheets
					print("sheet \(indexPath.row)")
					let index = indexPath.row - (selectedClusterRow + 1)
					cell.setup(title: sheetsForSelectedCluster?[index].title, icon: Cells.songIcon)
					cell.selectedCell = selectedSheet?.id == sheetsForSelectedCluster?[index].id
					cell.isInnerCell = true
				} else {
					print("cluster \(indexPath.row)")
					let index = getIndexForCluster(indexPath)
					cell.setup(title: clusters[index].title, icon: Cells.songIcon)
					cell.isInnerCell = false
					cell.selectedCell = selectedCluster?.id == clusters[index].id
				}
			}
			return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// if sheets open
		if sheetsForSelectedCluster != nil {
			// if in sheet index
			if indexPath.row > selectedClusterRow && indexPath.row <= (selectedClusterRow + (sheetsForSelectedCluster?.count ?? 0)) {
				selectedSheet = sheetsForSelectedCluster?[indexPath.row - (selectedClusterRow + 1)]
			} else {
				 if selectedCluster?.id == clusters[getIndexForCluster(indexPath)].id {
					selectedCluster = nil
					selectedSheet = nil
				} else {
					if indexPath.row < selectedClusterRow {
						selectedClusterRow = indexPath.row
					} else {
						selectedClusterRow = indexPath.row - (sheetsForSelectedCluster?.count ?? 0)
					}
					selectedCluster = clusters[getIndexForCluster(indexPath)]
					selectedSheet = sheetsForSelectedCluster?.first
				}
			}
		} else {
			selectedCluster = clusters[indexPath.row]
			selectedSheet = sheetsForSelectedCluster?.first
			selectedClusterRow = indexPath.row
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
		
		sheetDisplayerPrevious.layer.transform = self.transformForFraction(fraction: 0.2)
		
		sheetDisplayerNext.layer.transform = self.transformForFraction(fraction: 1.8)
		
		CoreCluster.setSortDescriptor(attributeName: "position", ascending: true)
		clusters = CoreCluster.getEntities()
		
		navigationController?.title = Text.SongService.title
		
		clear.title = Text.Actions.new
		new.title = Text.Actions.add
		
		NotificationCenter.default.addObserver(forName: NotificationNames.externalScreen, object: nil, queue: nil, using: setExternalDisplay)
		
		let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		
		upSwipe.direction = .up
		downSwipe.direction = .down
		
		moveUpDownSection.addGestureRecognizer(upSwipe)
		moveUpDownSection.addGestureRecognizer(downSwipe)
		
		let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))

		leftSwipe.direction = .left
		rightSwipe.direction = .right
		
		sheetDisplaySwipeView.addGestureRecognizer(leftSwipe)
		sheetDisplaySwipeView.addGestureRecognizer(rightSwipe)
		

		
		tableView.register(cell: Cells.basicCellid)
		
		update()
		
	}
	
	private func update() {
		tableView.reloadData()
	}
	
	private func moveToFirstSheet() {
//		tableViewSheets.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
	}
	
	private func getIndexForCluster(_ indexPath: IndexPath) -> Int {
		if selectedCluster != nil {
			if indexPath.row <= selectedClusterRow {
				return indexPath.row
			} else {
				return indexPath.row - ((sheetsForSelectedCluster?.count ?? 0))
			}
		} else {
			return indexPath.row
		}
	}
	
	@objc private func respondToSwipeGesture(_ sender: UISwipeGestureRecognizer) {
		
		if sender.view == sheetDisplaySwipeView {
			switch sender.direction {
				
				
			case .left:
				print("left")
				if let sheetsForSelectedCluster = sheetsForSelectedCluster, let position = selectedSheet?.position {
					let nextPosition = Int(position) + 1
					if nextPosition < sheetsForSelectedCluster.count {
						// display next sheet
						selectedSheet = sheetsForSelectedCluster[nextPosition]
					} else {
						// display next song
						if let clusterPosition = selectedCluster?.position, Int(clusterPosition) + 1 <= clusters.count {
							selectedCluster = clusters[Int(clusterPosition)]
							selectedSheet = sheetsForSelectedCluster.first
						}
					}
				}
				
				
				
			case .right:
				print("right")
				
				if let sheetsForSelectedCluster = sheetsForSelectedCluster, let position = selectedCluster?.position {
					let previousPosition = Int(position) - 1
					if previousPosition > 0 {
						// display previous sheet
						selectedSheet = sheetsForSelectedCluster[previousPosition]
					} else {
						// display previous song
						if let clusterPosition = selectedCluster?.position, Int(clusterPosition) - 1 > 0 {
							selectedCluster = clusters[Int(clusterPosition) - 1]
						}
					}
				}
				
				
				
				
				
			default:
				break
			}
		} else if sender.view == moveUpDownSection {
			switch sender.direction {
			case .up:
				print("up")
				if sheetDisplayerContainerHeight.constant > 100 {
					self.sheetDisplayerContainerHeight.constant = 100
				} else {
					self.sheetDisplayerContainerHeight.constant = 0
				}
			case .down:
				print("down")
				if sheetDisplayerContainerHeight.constant < 100 {
					self.sheetDisplayerContainerHeight.constant = 100
				} else if sheetDisplayerContainerHeight.constant < 150 {
					self.sheetDisplayerContainerHeight.constant = 150
				}
			case .left:
				print("left")
			case .right:
				print("right")
			default:
				break
			}
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
		var sheets: [UIImage] = []
		if let sheetsForSelectedCluster = sheetsForSelectedCluster {
			
			if let sheetController = storyboard?.instantiateViewController(withIdentifier: "SheetController") as? SheetController {
				sheetController.setView(CGRect(x: 0, y: 0, width: externalScreenBounds.width, height: externalScreenBounds.height))
				for sheet in sheetsForSelectedCluster {
					sheetController.isEmptySheet = sheet.title == Text.Sheet.emptySheetTitle ? true : false
					sheetController.hasTitle = hasTitle
					sheetController.songTitle = selectedCluster?.title
					sheetController.lyrics = sheet.lyrics
					sheets.append(sheetController.asImage())
				}
			}
		}
		sheetsToDisplay = sheets
	}
	
	private func displaySheets() {
		if selectedSheet != nil {
			// display background
			sheetDisplayer.isHidden = false
			
			
			if let numberOfSheets = sheetsForSelectedCluster?.count, let position = selectedSheet?.position {
				
				sheetDisplayerNext.isHidden = position == numberOfSheets - 1 ? true : false
				sheetDisplayerPrevious.isHidden = position == 0 ? true : false
				
				let selectedSheetPosition = Int(position)
				
				if selectedSheetPosition < (numberOfSheets) {
					
					// current sheet
					var image = sheetsToDisplay[selectedSheetPosition].imageResize(sizeChange: sheetDisplayer.frame.size)
					sheetDisplayer.image = image
					if let bounds = externalScreen?.nativeBounds {
						let imageView = UIImageView(frame: bounds)
						imageView.image = image
					}
					
					// next sheet
					if selectedSheetPosition < (numberOfSheets - 1) {
						image = sheetsToDisplay[selectedSheetPosition + 1].imageResize(sizeChange: sheetDisplayerPrevious.frame.size)
						sheetDisplayerNext.image = image
					}
					
					// previous sheet
					if selectedSheetPosition > 0 {
						let image = sheetsToDisplay[selectedSheetPosition - 1].imageResize(sizeChange: sheetDisplayerPrevious.frame.size)
						sheetDisplayerPrevious.image = image
					}
					
				}
			}
			
		} else {
			sheetDisplayer.isHidden = true
			sheetDisplayerNext.isHidden = true
			sheetDisplayerPrevious.isHidden = true
		}
	}
	
	func transformForFraction(fraction:CGFloat) -> CATransform3D {
		var identity = CATransform3DIdentity
		identity.m34 = -1.0 / 1000.0
		let angle = Double(1.0 - fraction) * -Double.pi/2
		//		  let xOffset = self.view.bounds.width * 0.5
		let xOffset = CGFloat(view.frame.width*0.5)
		//		  let rotateTransform = CATransform3DRotate(identity, CGFloat(angle), 0.0, 1.0, 0.0)
		let rotateTransform = CATransform3DRotate(identity, CGFloat(angle), 0.0, 1.0, 0.0)
		let translateTransform = CATransform3DMakeTranslation(0.0, 0.0, xOffset)
		return CATransform3DConcat(rotateTransform, translateTransform)
	}
	
	private func animateSheetsWith(_ direction : AnimationDirection, completion: @escaping () -> Void) {
		switch direction {
		case .left:
			
			if let position = selectedSheet?.position {
				
				let selectedSheetPosition = Int(position)
				
				let navigationBarHeight = UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height
				
				// current sheet
				let imageCurrent = sheetsToDisplay[selectedSheetPosition].imageResize(sizeChange: sheetDisplayer.frame.size)
				let currentSheetView = UIImageView(frame: CGRect(x: sheetDisplayer.frame.minX, y: sheetDisplayer.frame.minY + navigationBarHeight, width: sheetDisplayer.frame.width, height: sheetDisplayer.frame.height))
				currentSheetView.image = imageCurrent
				
				
				let imageNext = sheetsToDisplay[selectedSheetPosition + 1].imageResize(sizeChange: sheetDisplayerNext.frame.size)
				let nextSheetView = UIImageView(frame: CGRect(x: sheetDisplayerNext.frame.minX, y: sheetDisplayerNext.frame.minY + navigationBarHeight, width: sheetDisplayerNext.frame.width, height: sheetDisplayerNext.frame.height))
				nextSheetView.image = imageNext
				
				view.addSubview(currentSheetView)
				view.addSubview(nextSheetView)
				sheetDisplayer.isHidden = true
				sheetDisplayerPrevious.isHidden = true
				sheetDisplayerNext.isHidden = true
				UIView.animate(withDuration: 0.3, animations: {
					currentSheetView.frame = CGRect(x: self.sheetDisplayerPrevious.frame.minX, y: self.sheetDisplayerPrevious.frame.minY + navigationBarHeight, width: self.sheetDisplayerPrevious.frame.width, height: self.sheetDisplayerPrevious.frame.height)
					nextSheetView.frame = CGRect(x: self.sheetDisplayer.frame.minX, y: navigationBarHeight, width: self.sheetDisplayer.frame.width, height: self.sheetDisplayer.frame.height)
				}, completion: { (bool) in
					self.sheetDisplayer.isHidden = false
					self.sheetDisplayerPrevious.isHidden = false
					nextSheetView.removeFromSuperview()
					currentSheetView.removeFromSuperview()
					completion()
				})
			}
			
			
		case .right:
			
			// show previous sheet
			if let numberOfSheets = sheetsForSelectedCluster?.count, let position = selectedSheet?.position {
				
				sheetDisplayerNext.isHidden = position == numberOfSheets ? true : false
				sheetDisplayerPrevious.isHidden = position == 0 ? true : false
				
				let selectedSheetPosition = Int(position)
				
				let navigationBarHeight = UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height
				
				// current sheet, move to right
				let imageCurrent = sheetsToDisplay[selectedSheetPosition].imageResize(sizeChange: sheetDisplayer.frame.size)
				let currentSheetView = UIImageView(frame: CGRect(x: sheetDisplayer.frame.minX, y: sheetDisplayer.frame.minY + navigationBarHeight, width: sheetDisplayer.frame.width, height: sheetDisplayer.frame.height))
				currentSheetView.image = imageCurrent
				
				// previous sheet, move to right
				let imagePrevious = sheetsToDisplay[selectedSheetPosition - 1].imageResize(sizeChange: sheetDisplayerPrevious.frame.size)
				let previousSheetView = UIImageView(frame: CGRect(x: sheetDisplayerPrevious.frame.minX, y: sheetDisplayerPrevious.frame.minY + navigationBarHeight, width: sheetDisplayerPrevious.frame.width, height: sheetDisplayerPrevious.frame.height))
				previousSheetView.image = imagePrevious
				
				view.addSubview(currentSheetView)
				view.addSubview(previousSheetView)
				sheetDisplayer.isHidden = true
				sheetDisplayerPrevious.isHidden = true
				sheetDisplayerNext.isHidden = true
				UIView.animate(withDuration: 0.3, animations: {
					currentSheetView.frame = CGRect(x: self.sheetDisplayerNext.frame.minX, y: self.sheetDisplayerNext.frame.minY + navigationBarHeight, width: self.sheetDisplayerNext.frame.width, height: self.sheetDisplayerNext.frame.height)
					previousSheetView.frame = CGRect(x: self.sheetDisplayer.frame.minX, y: navigationBarHeight, width: self.sheetDisplayer.frame.width, height: self.sheetDisplayer.frame.height)
				}, completion: { (bool) in
					self.sheetDisplayer.isHidden = false
					self.sheetDisplayerPrevious.isHidden = false
					previousSheetView.removeFromSuperview()
					currentSheetView.removeFromSuperview()
					completion()
				})
			}
		}
	}

}
