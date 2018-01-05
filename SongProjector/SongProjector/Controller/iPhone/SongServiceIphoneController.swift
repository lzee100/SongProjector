//
//  SongServiceIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit
import QuartzCore

extension NSLayoutConstraint {
	func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
		return NSLayoutConstraint(item: self.firstItem, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
	}
}

class SongServiceIphoneController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, NewSongServiceDelegate {

	@IBOutlet var clear: UIBarButtonItem!
	@IBOutlet var new: UIBarButtonItem!
	@IBOutlet var sheetDisplaySwipeView: UIView!

	@IBOutlet var sheetDisplayerPrevious: UIView!
	@IBOutlet var sheetDisplayer: UIView!
	@IBOutlet var sheetDisplayerNext: UIView!
	

	@IBOutlet var sheetDisplayerSwipeViewHeight: NSLayoutConstraint!
	
	@IBOutlet var sheetDisplayerRatioConstraint: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerPreviousRatioConstraint: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerNextRatioConstraint: NSLayoutConstraint!
	
	var customSheetDisplayerRatioConstraint: NSLayoutConstraint?
	var customSheetDisplayerPreviousRatioConstraint: NSLayoutConstraint?
	var customSheetDisplayerNextRatioConstraint: NSLayoutConstraint?
	
	@IBOutlet var moveUpDownSection: UIView!
	@IBOutlet var tableView: UITableView!
	

	// MARK: - Private Properties
	
	enum SheetType {
		case current
		case previous
		case next
	}
	
	struct Constants {
		static let previousSheetFraction: CGFloat = 0.2
		static let nextSheetFraction: CGFloat = 1.8
	}
	
	private var viewToBeamer: UIView?
	private var hasTitle = true
	private var emptySheet = CoreSheet.createEntityNOTsave()
	private var clusters: [Cluster] = [] { didSet { update() } }
	private var clustersOrdened: [Cluster] { get { return clusters.sorted{ $0.position < $1.position } } }
	private var selectedClusterRow = -1
	private var selectedCluster: Cluster? {
		willSet {
			if let hasEmptySheet = newValue?.hasTag?.hasEmptySheet, hasEmptySheet {
				if newValue == nil {
					removeEmptySheet()
				} else {
					addEmptySheet(newValue, isEmptySheetFirst: newValue?.hasTag?.isEmptySheetFirst)
				}
			}
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
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let controller = segue.destination as? UINavigationController, let newSongServiceIphoneController = controller.viewControllers.first as? NewSongServiceIphoneController {
			newSongServiceIphoneController.delegate = self
			newSongServiceIphoneController.selectedSongs = clusters
		}
//		if let controller = segue.destination as? UINavigationController, let songsController = controller.viewControllers.first as? SongsController {
//			songsController.delegate = self
//		}
	}
	
	
	
	// MARK: UITableViewDelegate Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return (clusters.count + (sheetsForSelectedCluster?.count ?? 0)) == 0 ? 1 : clusters.count + (sheetsForSelectedCluster?.count ?? 0)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
			let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
			if let cell = cell as? BasicCell {
				if clusters.count < 1 {
					cell.setup(title: Text.NewSongService.noSelectedSongs)
					return cell
				}
				if sheetsForSelectedCluster != nil && indexPath.row > selectedClusterRow && indexPath.row <= (selectedClusterRow + (sheetsForSelectedCluster?.count ?? 0)){
					// sheets
					let index = indexPath.row - (selectedClusterRow + 1)
					cell.setup(title: sheetsForSelectedCluster?[index].title, icon: Cells.songIcon)
					cell.selectedCell = selectedSheet?.id == sheetsForSelectedCluster?[index].id
					cell.isInnerCell = true
				} else {
					let index = getIndexForCluster(indexPath)
					cell.setup(title: clustersOrdened[index].title, icon: Cells.songIcon)
					cell.isInnerCell = false
					cell.selectedCell = selectedCluster?.id == clustersOrdened[index].id
				}
			}
			return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// if sheets open
		if sheetsForSelectedCluster != nil, let selectedClusterIndex = selectedCluster?.position {
			// if in sheet index
			if indexPath.row > selectedClusterRow && indexPath.row <= (selectedClusterRow + (sheetsForSelectedCluster?.count ?? 0)) {
				selectedSheet = sheetsForSelectedCluster?[indexPath.row - (selectedClusterRow + 1)]
			} else {
				 if selectedCluster?.id == clusters[getIndexForCluster(indexPath)].id {
					selectedCluster = nil
					selectedSheet = nil
				} else {
					if indexPath.row < selectedClusterIndex {
						selectedClusterRow = indexPath.row
					} else {
						selectedClusterRow = indexPath.row - (sheetsForSelectedCluster?.count ?? 0)
					}
					selectedCluster = clustersOrdened[getIndexForCluster(indexPath)]
					selectedSheet = sheetsForSelectedCluster?.first
				}
			}
		} else {
			if clustersOrdened.count > 0 {
				selectedCluster = clustersOrdened[indexPath.row]
				selectedSheet = sheetsForSelectedCluster?.first
				selectedClusterRow = indexPath.row
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

//		sheetDisplaySwipeView.isHidden = true

		sheetDisplayerPrevious.layer.transform = self.transformForFraction(fraction: Constants.previousSheetFraction)
		sheetDisplayerNext.layer.transform = self.transformForFraction(fraction: Constants.nextSheetFraction)
		
		navigationController?.title = Text.SongService.title
		title = Text.SongService.title
		
		clear.title = Text.Actions.new
		new.title = Text.Actions.add
		
		NotificationCenter.default.addObserver(forName: NotificationNames.externalDisplayDidChange, object: nil, queue: nil, using: externalDisplayDidChange)
		
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
						animateSheetsWith(.left, completion: {
							self.selectedSheet = sheetsForSelectedCluster[nextPosition]
						})
					} else {
						// display next song
						if let clusterPosition = selectedCluster?.position, Int(clusterPosition) + 1 < clusters.count {
							selectedClusterRow += 1
							selectedCluster = clustersOrdened[Int(clusterPosition) + 1]
							selectedSheet = self.sheetsForSelectedCluster?.first
						}
					}
				}
				
				
				
			case .right:
				print("right")
				
				if let sheetsForSelectedCluster = sheetsForSelectedCluster, let position = selectedSheet?.position {
					let previousPosition = Int(position) - 1
					if previousPosition >= 0 {
						// display previous sheet
						animateSheetsWith(.right, completion: {
							self.selectedSheet = sheetsForSelectedCluster[previousPosition]
						})
					} else {
						// display previous song
						if let clusterPosition = selectedCluster?.position, Int(clusterPosition) - 1 >= 0 {
							selectedClusterRow -= 1
							selectedCluster = clustersOrdened[Int(clusterPosition) - 1]
							selectedSheet = self.sheetsForSelectedCluster?.first
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
				if sheetDisplayerSwipeViewHeight.constant > 100 {
					sheetDisplayerSwipeViewHeight.constant = 100

					UIView.animate(withDuration: 0.3) {
						self.view.layoutIfNeeded()
						self.sheetDisplayer.layoutIfNeeded()
						self.sheetDisplayerPrevious.layoutIfNeeded()
						self.sheetDisplayerNext.layoutIfNeeded()
					}
				} else {
					self.sheetDisplayerSwipeViewHeight.constant = 0
					UIView.animate(withDuration: 0.3) {
						self.view.layoutIfNeeded()
						self.sheetDisplayer.layoutIfNeeded()
						self.sheetDisplayerPrevious.layoutIfNeeded()
						self.sheetDisplayerNext.layoutIfNeeded()
					}
				}
			case .down:
				print("down")
				if sheetDisplayerSwipeViewHeight.constant < 150 {
					self.sheetDisplayerSwipeViewHeight.constant = 150
//					sheetDisplayerPreviousYCenterConstraint.constant = -170
//					sheetDisplayerNextYCenterConstraint.constant = 170
					UIView.animate(withDuration: 0.3) {
						self.view.layoutIfNeeded()
						self.sheetDisplayer.layoutIfNeeded()
						self.sheetDisplayerPrevious.layoutIfNeeded()
						self.sheetDisplayerNext.layoutIfNeeded()
					}
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
	
	private func addEmptySheet(_ selectedCluster: Cluster?, isEmptySheetFirst: Bool?) {
		emptySheet.title = Text.Sheet.emptySheetTitle
		if let isEmptySheetFirst = isEmptySheetFirst, isEmptySheetFirst {
			emptySheet.position = 0
			if let sheets = selectedCluster?.hasSheets as? Set<Sheet> {
				let sheetsSorted = sheets.sorted{ $0.position < $1.position }
				for (index, sheet) in sheetsSorted.enumerated() {
					sheet.position = Int16(index + 1)
				}
			}
			selectedCluster?.addToHasSheets(emptySheet)
		} else {
			if let sheets = selectedCluster?.hasSheets as? Set<Sheet> {
				let sheetsSorted = sheets.sorted{ $0.position < $1.position }
				emptySheet.position = (sheetsSorted.last?.position ?? 0) + 1
				selectedCluster?.addToHasSheets(emptySheet)
			}

		}
	}
	
	private func removeEmptySheet() {
		selectedCluster?.removeFromHasSheets(emptySheet)
		if let isEmptySheetFirst = selectedCluster?.hasTag?.isEmptySheetFirst, isEmptySheetFirst {
			if let sheetsForSelectedCluster = sheetsForSelectedCluster {
				for (index, sheet) in sheetsForSelectedCluster.enumerated() {
					sheet.position = Int16(index - 1)
				}
			}
		}
	}
	
	func externalDisplayDidChange(_ notification: Notification) {
		updateSheetDisplayersRatios()
		displaySheets()
	}
	
	func updateSheetDisplayersRatios() {
			sheetDisplayerRatioConstraint.isActive = false
			sheetDisplayerPreviousRatioConstraint.isActive = false
			sheetDisplayerNextRatioConstraint.isActive = false
			
			if let customSheetDisplayerRatioConstraint = customSheetDisplayerRatioConstraint {
				sheetDisplayer.removeConstraint(customSheetDisplayerRatioConstraint)
			}
			customSheetDisplayerRatioConstraint = NSLayoutConstraint(item: sheetDisplayer, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: sheetDisplayer, attribute: NSLayoutAttribute.width, multiplier: externalDisplayWindowRatio, constant: 0)
			sheetDisplayer.addConstraint(customSheetDisplayerRatioConstraint!)
			sheetDisplayer.layoutIfNeeded()
			sheetDisplayer.layoutSubviews()
			
			if let customSheetDisplayerPreviousRatioConstraint = customSheetDisplayerPreviousRatioConstraint {
				sheetDisplayer.removeConstraint(customSheetDisplayerPreviousRatioConstraint)
			}
			customSheetDisplayerPreviousRatioConstraint = NSLayoutConstraint(item: sheetDisplayerPrevious, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: sheetDisplayerPrevious, attribute: NSLayoutAttribute.width, multiplier: externalDisplayWindowRatio, constant: 0)
			sheetDisplayerPrevious.addConstraint(customSheetDisplayerPreviousRatioConstraint!)
			
			if let customSheetDisplayerNextRatioConstraint = customSheetDisplayerNextRatioConstraint {
				sheetDisplayer.removeConstraint(customSheetDisplayerNextRatioConstraint)
			}
			customSheetDisplayerNextRatioConstraint = NSLayoutConstraint(item: sheetDisplayerNext, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: sheetDisplayerNext, attribute: NSLayoutAttribute.width, multiplier: externalDisplayWindowRatio, constant: 0)
			sheetDisplayerNext.addConstraint(customSheetDisplayerNextRatioConstraint!)
			
//		} else {
//			sheetDisplayerRatioConstraint.isActive = true
//			sheetDisplayerPreviousRatioConstraint.isActive = true
//			sheetDisplayerNextRatioConstraint.isActive = true
//		}
		
		view.layoutIfNeeded()
		view.layoutSubviews()

	}
	
	@IBAction func clearButtonPressed(_ sender: UIBarButtonItem) {

	}
	
	
	private func displaySheets() {
		if selectedSheet != nil {
			// display background
			sheetDisplaySwipeView.isHidden = false
			
			if let numberOfSheets = sheetsForSelectedCluster?.count, let position = selectedSheet?.position {
				
				sheetDisplayerNext.isHidden = position == numberOfSheets - 1 ? true : false
				sheetDisplayerPrevious.isHidden = position == 0 ? true : false
				
				let selectedSheetPosition = Int(position)
				
				if selectedSheetPosition < (numberOfSheets) {
					
					// current sheet
					if let tag = selectedCluster?.hasTag {
						viewToBeamer?.removeFromSuperview()
						viewToBeamer = buildSheetViewFor(type: .current, title: selectedCluster?.title, sheet: selectedSheet, tag: tag, displayToBeamer: true)
						sheetDisplayer.addSubview(viewToBeamer!)
					}

					// next sheet
					if selectedSheetPosition < (numberOfSheets - 1), let tag = selectedCluster?.hasTag {
						sheetDisplayerNext.layer.transform = transformForFraction(fraction: 1.0)
						let nextSheet = sheetsForSelectedCluster?[selectedSheetPosition + 1]
						sheetDisplayerNext.addSubview(buildSheetViewFor(type: .next, title: selectedCluster?.title, sheet: nextSheet, tag: tag))
						sheetDisplayerNext.layer.transform = transformForFraction(fraction: Constants.nextSheetFraction)

					}

					// previous sheet
					if selectedSheetPosition > 0, let tag = selectedCluster?.hasTag {
						let nextSheet = sheetsForSelectedCluster?[selectedSheetPosition - 1]
						sheetDisplayerPrevious.layer.transform = transformForFraction(fraction: 1.0)
						sheetDisplayerPrevious.addSubview(buildSheetViewFor(type: .previous, title: selectedCluster?.title, sheet: nextSheet, tag: tag))
						sheetDisplayerPrevious.layer.transform = transformForFraction(fraction: Constants.previousSheetFraction)
					}
					
				}
			}
			
		} else {
			sheetDisplaySwipeView.isHidden = true
			if let externalDisplayWindow = externalDisplayWindow {
				let view = UIView(frame: externalDisplayWindow.frame)
				view.backgroundColor = .black
				externalDisplayWindow.addSubview(view)
				viewToBeamer?.removeFromSuperview()
			}
		}
	}
	
	private func buildSheetViewFor(type: SheetType, title: String?, sheet: Sheet?, tag: Tag?, displayToBeamer: Bool = false) -> UIView {
		var heightView: CGFloat = 0.0
		var displayerFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
		switch type {
		case .previous:
			heightView = sheetDisplayerPrevious.frame.size.height
			displayerFrame = sheetDisplayerPrevious.frame
		case .current:
			heightView = sheetDisplayer.frame.size.height
			displayerFrame = sheetDisplayer.frame
		case .next:
			heightView = sheetDisplayerNext.frame.size.height
			displayerFrame = sheetDisplayerNext.frame
		}
		if let externalDisplayWindow = externalDisplayWindow, displayToBeamer {
			let view = SheetView(frame: externalDisplayWindow.frame)
			view.isEmptySheet = sheet?.title == Text.Sheet.emptySheetTitle
			view.selectedTag = tag
			view.songTitle = title
			view.lyrics = sheet?.lyrics
			view.scaleFactor = externalDisplayWindow.bounds.size.height / heightView
			view.update()
			externalDisplayWindow.addSubview(view)
		}
		let frame = CGRect(x: 0, y: 0, width: displayerFrame.width, height: displayerFrame.height)
		let view = SheetView(frame: frame)
		view.isEmptySheet = sheet?.title == Text.Sheet.emptySheetTitle
		view.selectedTag = tag
		view.songTitle = title
		view.lyrics = sheet?.lyrics
		view.update()
		return view
		
	}
	
	private func transformForFraction(fraction:CGFloat) -> CATransform3D {
		var identity = CATransform3DIdentity
		identity.m34 = -1.0 / 2000
		let angle = Double(1.0 - fraction) * -Double.pi/2
		//		  let xOffset = self.view.bounds.width * 0.5
		let xOffset = CGFloat(view.frame.width*0.5)
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
				sheetDisplayerPrevious.layer.transform = transformForFraction(fraction: 1.0)
				sheetDisplayerNext.layer.transform = transformForFraction(fraction: 1.0)


				// current sheet
				// current sheet, move to left
				let currentSheetView = buildSheetViewFor(type: .current, title: selectedCluster?.title, sheet: selectedSheet, tag: selectedCluster?.hasTag)
				currentSheetView.frame = CGRect(x: sheetDisplayer.frame.minX, y: sheetDisplayer.frame.minY + navigationBarHeight, width: sheetDisplayer.frame.width, height: sheetDisplayer.frame.height)
				
				
				// next sheet, move to left
				let nextSheet = sheetsForSelectedCluster?[selectedSheetPosition + 1]
				let nextSheetView = buildSheetViewFor(type: .next, title: selectedCluster?.title, sheet: nextSheet, tag: selectedCluster?.hasTag)
				
				nextSheetView.frame = CGRect(
					x: sheetDisplayerNext.frame.minX,
					y: sheetDisplayerNext.frame.minY + navigationBarHeight,
					width: sheetDisplayerNext.frame.width,
					height: sheetDisplayerNext.frame.height) // set the view
				nextSheetView.layer.transform = transformForFraction(fraction: Constants.nextSheetFraction)
				
				
				view.addSubview(currentSheetView)
				view.addSubview(nextSheetView)
				sheetDisplayer.isHidden = true
				sheetDisplayerPrevious.isHidden = true
				sheetDisplayerNext.isHidden = true
				
				UIView.animate(withDuration: 0.3, animations: {
					currentSheetView.frame = CGRect(
						x: self.sheetDisplayerPrevious.frame.minX,
						y: self.sheetDisplayerPrevious.frame.minY + navigationBarHeight,
						width: self.sheetDisplayerPrevious.frame.width,
						height: self.sheetDisplayerPrevious.frame.height)
					currentSheetView.layer.transform = self.transformForFraction(fraction: Constants.previousSheetFraction)

					nextSheetView.frame = CGRect(
						x: self.sheetDisplayer.frame.minX,
						y: self.sheetDisplayer.frame.minY + navigationBarHeight,
						width: self.sheetDisplayer.frame.width,
						height: self.sheetDisplayer.frame.height)
					nextSheetView.layer.transform = self.transformForFraction(fraction: 1.0)
					
				}, completion: { (bool) in
					self.sheetDisplayer.isHidden = false
					self.sheetDisplayerPrevious.isHidden = false
					self.sheetDisplayerPrevious.layer.transform = self.transformForFraction(fraction: Constants.previousSheetFraction)
					self.sheetDisplayerNext.layer.transform = self.transformForFraction(fraction: Constants.nextSheetFraction)

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
				sheetDisplayerNext.layer.transform = self.transformForFraction(fraction: 1.0)

				let selectedSheetPosition = Int(position)
				
				let navigationBarHeight = UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height
				
				// current sheet, move to right
				let currentSheetView = buildSheetViewFor(type: .current, title: selectedCluster?.title, sheet: selectedSheet, tag: selectedCluster?.hasTag)
				currentSheetView.frame = CGRect(x: sheetDisplayer.frame.minX, y: sheetDisplayer.frame.minY + navigationBarHeight, width: sheetDisplayer.frame.width, height: sheetDisplayer.frame.height)
				
				sheetDisplayerPrevious.layer.transform = self.transformForFraction(fraction: 1.0)

				
				// previous sheet, move to right
				let previousSheet = sheetsForSelectedCluster?[selectedSheetPosition - 1]
				let previousSheetView = buildSheetViewFor(type: .previous, title: selectedCluster?.title, sheet: previousSheet, tag: selectedCluster?.hasTag) // generates uiview with dimensions of sheetDisplayerPrevious which is set in storyboard
				previousSheetView.frame = CGRect(
					x: sheetDisplayerPrevious.frame.minX,
					y: sheetDisplayerPrevious.frame.minY + navigationBarHeight,
					width: sheetDisplayerPrevious.frame.width,
					height: sheetDisplayerPrevious.frame.height) // set the view
				
				sheetDisplayerPrevious.layer.transform = self.transformForFraction(fraction: Constants.previousSheetFraction)

				previousSheetView.layer.transform = self.transformForFraction(fraction: Constants.previousSheetFraction)
				
				view.addSubview(currentSheetView)
				view.addSubview(previousSheetView)
				sheetDisplayer.isHidden = true
				sheetDisplayerPrevious.isHidden = true
				sheetDisplayerNext.isHidden = true
				
				
				UIView.animate(withDuration: 0.3, animations: {
					previousSheetView.layer.transform = self.transformForFraction(fraction: 1.0)
					previousSheetView.frame = CGRect(
						x: self.sheetDisplayer.frame.minX,
						y: self.sheetDisplayer.frame.minY + navigationBarHeight,
						width: self.sheetDisplayer.frame.width,
						height: self.sheetDisplayer.frame.height)
					
					currentSheetView.frame = CGRect(
						x: self.sheetDisplayerNext.frame.minX,
						y: self.sheetDisplayerNext.frame.minY + navigationBarHeight,
						width: self.sheetDisplayerNext.frame.width,
						height: self.sheetDisplayerNext.frame.height)
					currentSheetView.layer.transform = self.transformForFraction(fraction: Constants.nextSheetFraction)


					
				}, completion: { (bool) in
					self.sheetDisplayerNext.layer.transform = self.transformForFraction(fraction: Constants.nextSheetFraction)
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
