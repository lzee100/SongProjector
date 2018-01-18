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
	@IBOutlet var emptyViewTableView: UIView!
	
	@IBOutlet var swipeViewLine: UIView!
	
	@IBOutlet var sheetDisplayerNextLeftConstraint: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerPreviousRightConstraint: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerSwipeViewHeight: NSLayoutConstraint!
	
	@IBOutlet var sheetDisplayerRatioConstraint: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerPreviousRatioConstraint: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerNextRatioConstraint: NSLayoutConstraint!
	
	var customSheetDisplayerRatioConstraint: NSLayoutConstraint?
	var customSheetDisplayerPreviousRatioConstraint: NSLayoutConstraint?
	var customSheetDisplayerNextRatioConstraint: NSLayoutConstraint?
	var sheetDisplaySwipeViewCustomHeightConstraint: NSLayoutConstraint?
	var swipeAnimationIsActive = false
	
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
	
	private var viewToBeamer: SheetView?
	private var hasTitle = true
	private var emptySheet: Sheet?
	private var clusters: [Cluster] = [] { didSet { update() } }
	private var clustersOrdened: [Cluster] { get { return clusters.sorted{ $0.position < $1.position } } }
	private var selectedClusterRow = -1
	private var selectedCluster: Cluster? {
		willSet {
			if newValue == nil {
				if let hasEmptySheet = selectedCluster?.hasTag?.hasEmptySheet, hasEmptySheet {
					removeEmptySheet()
				}
			}
		}
		didSet {
			if let hasEmptySheet = selectedCluster?.hasTag?.hasEmptySheet, hasEmptySheet {
				addEmptySheet(selectedCluster, isEmptySheetFirst: selectedCluster?.hasTag?.isEmptySheetFirst)
			} else {
				selectedSheet = sheetsForSelectedCluster?.first
			}
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
					cell.isSelected = false
					return cell
				}
				if sheetsForSelectedCluster != nil && indexPath.row > selectedClusterRow && indexPath.row <= (selectedClusterRow + (sheetsForSelectedCluster?.count ?? 0)){
					// sheets
					let index = indexPath.row - (selectedClusterRow + 1)
					cell.setup(title: sheetsForSelectedCluster?[index].title, icon: Cells.sheetIcon)
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
				}
			}
		} else {
			if clustersOrdened.count > 0 {
				selectedCluster = clustersOrdened[indexPath.row]
				selectedClusterRow = indexPath.row
			}
		}
		update()
	}
	
	// MARK: NewSongServiceDelegate Functions
	
	func didFinishSongServiceSelection(clusters: [Cluster]) {
		selectedCluster = nil
		selectedSheet = nil
		self.clusters = clusters
	}
	
	
	
	// MARK: SongsControllerDelegate Functions
	
	func didSelectCluster(cluster: Cluster){
		self.clusters.append(cluster)
	}
	
	
	
	// MARK: - Private Functions
	
	private func setup() {
		
		navigationController?.title = Text.SongService.title
		title = Text.SongService.title
		
		clear.title = Text.Actions.new
		new.title = Text.Actions.add
		
		emptyViewTableView.backgroundColor = themeWhiteBlackBackground
		moveUpDownSection.backgroundColor = themeWhiteBlackBackground
		swipeViewLine.backgroundColor = themeHighlighted
		
		NotificationCenter.default.addObserver(forName: NotificationNames.externalDisplayDidChange, object: nil, queue: nil, using: externalDisplayDidChange)
		
		NotificationCenter.default.addObserver(
			forName: Notification.Name.UIScreenDidConnect,
			object: nil,
			queue: nil,
			using: databaseDidChange)

		
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
		
		sheetDisplayerNextLeftConstraint.constant = UIScreen.main.bounds.width
		sheetDisplayerPreviousRightConstraint.constant = -UIScreen.main.bounds.width
		
		sheetDisplaySwipeView.addGestureRecognizer(leftSwipe)
		sheetDisplaySwipeView.addGestureRecognizer(rightSwipe)
//		sheetDisplaySwipeView.isHidden = true
		
		tableView.register(cell: Cells.basicCellid)
		updateSheetDisplayersRatios()
		update()
		
	}
	
	private func update() {
		tableView.reloadData()
		
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
	
	private func getNextSheet() -> Sheet? {
		if let sheetsForSelectedCluster = sheetsForSelectedCluster, let position = selectedSheet?.position {
			let nextPosition = Int(position) + 1
			if nextPosition < sheetsForSelectedCluster.count {
				return sheetsForSelectedCluster[nextPosition]
			} else if let clusterPosition = selectedCluster?.position, Int(clusterPosition) + 1 < clusters.count {
					let selectedCluster = self.clustersOrdened[Int(clusterPosition) + 1]
					return selectedCluster.hasSheetsArray.first
			} else {
				return nil
			}
		} else {
			return nil
		}
	}
	
	private func getPreviousSheet() -> Sheet? {
		if let sheetsForSelectedCluster = sheetsForSelectedCluster, let position = selectedSheet?.position {
			let previousPosition = Int(position) - 1
			
			if previousPosition >= 0 {
				return sheetsForSelectedCluster[previousPosition]
			} else if let clusterPosition = selectedCluster?.position, Int(clusterPosition) - 1 >= 0 {
				let selectedCluster = clustersOrdened[Int(clusterPosition) - 1]
				return selectedCluster.hasSheetsArray.first
			} else {
				return nil
			}
		} else {
			return nil
		}
	}
	
	@objc private func respondToSwipeGesture(_ sender: UISwipeGestureRecognizer) {
		
		if sender.view == sheetDisplaySwipeView {
			switch sender.direction {
				
			case .left:
				print("left")
				if let clusterPosition = selectedCluster?.position, let sheetsForSelectedCluster = sheetsForSelectedCluster, let position = selectedSheet?.position {
					let nextPosition = Int(position) + 1
					if nextPosition < sheetsForSelectedCluster.count {
						// display next sheet
						swipeAnimationIsActive = true
						animateSheetsWith(.left, completion: {
							self.swipeAnimationIsActive = false
							self.selectedSheet = sheetsForSelectedCluster[nextPosition]
						})
						self.tableView.scrollToRow(at: IndexPath(row: Int(clusterPosition) + nextPosition, section: 0), at: .middle, animated: false)
					} else {
						// display next song
						if let clusterPosition = selectedCluster?.position, Int(clusterPosition) + 1 < clusters.count {
							swipeAnimationIsActive = true
							animateSheetsWith(.left, completion: {
								self.swipeAnimationIsActive = false
								self.selectedClusterRow += 1
								self.selectedCluster = self.clustersOrdened[Int(clusterPosition) + 1]
								self.selectedSheet = self.sheetsForSelectedCluster?.first
							})
							self.tableView.scrollToRow(at: IndexPath(row: Int(clusterPosition) + nextPosition, section: 0), at: .middle, animated: false)
						}
					}
				}
				
				
				
			case .right:
				print("right")
				
				if let clusterPosition = selectedCluster?.position, let sheetsForSelectedCluster = sheetsForSelectedCluster, let position = selectedSheet?.position {
					let previousPosition = Int(position) - 1
					if previousPosition >= 0 {
						// display previous sheet
						swipeAnimationIsActive = true
						animateSheetsWith(.right, completion: {
							self.swipeAnimationIsActive = false
							self.selectedSheet = sheetsForSelectedCluster[previousPosition]
						})
						self.tableView.scrollToRow(at: IndexPath(row: Int(clusterPosition) + previousPosition, section: 0), at: .middle, animated: false)

					} else {
						// display previous song
						if let clusterPosition = selectedCluster?.position, Int(clusterPosition) - 1 >= 0 {
							
							swipeAnimationIsActive = true
							animateSheetsWith(.right, completion: {
								self.swipeAnimationIsActive = false
								self.selectedClusterRow -= 1
								self.selectedCluster = self.clustersOrdened[Int(clusterPosition) - 1]
								self.selectedSheet = self.sheetsForSelectedCluster?.first
							})
							self.tableView.scrollToRow(at: IndexPath(row: Int(clusterPosition - 1), section: 0), at: .middle, animated: false)
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
		if let sheet = selectedCluster?.hasSheetsArray.first {
			emptySheet = sheet.emptySheet
			emptySheet?.title = Text.Sheet.emptySheetTitle
			if let isEmptySheetFirst = isEmptySheetFirst, isEmptySheetFirst {
				emptySheet?.position = 0
				if let sheets = selectedCluster?.hasSheets as? Set<Sheet> {
					let sheetsSorted = sheets.sorted{ $0.position < $1.position }
					for (index, sheet) in sheetsSorted.enumerated() {
						sheet.position = Int16(index + 1)
					}
				}
				selectedCluster?.addToHasSheets(emptySheet!)
			} else {
				if let sheets = selectedCluster?.hasSheets as? Set<Sheet> {
					let sheetsSorted = sheets.sorted{ $0.position < $1.position }
					emptySheet?.position = (sheetsSorted.last?.position ?? 0) + 1
					selectedCluster?.addToHasSheets(emptySheet!)
				}
			}
			sheetsForSelectedCluster?.forEach{ print(Int($0.position)) }
			sheetsForSelectedCluster?.forEach{ print($0.title ?? "") }
			selectedSheet = sheetsForSelectedCluster?.first
		}
	}
	
	private func removeEmptySheet() {
		if let emptySheet = emptySheet {
			selectedCluster?.removeFromHasSheets(emptySheet)
			if let isEmptySheetFirst = selectedCluster?.hasTag?.isEmptySheetFirst, isEmptySheetFirst {
				if let sheetsForSelectedCluster = sheetsForSelectedCluster {
					for (index, sheet) in sheetsForSelectedCluster.enumerated() {
						sheet.position = Int16(index - 1)
					}
				}
			}
		}
	}
	
	func externalDisplayDidChange(_ notification: Notification) {
		updateSheetDisplayersRatios()
		displaySheets()
	}
	
	func databaseDidChange( _ notification: Notification) {
		selectedCluster = nil
		selectedSheet = nil
		
		for cluster in clusters {
			CoreCluster.predicates.append("id", equals: cluster.id)
		}
		clusters = CoreCluster.getEntities()
	}
	
	func updateSheetDisplayersRatios() {
		sheetDisplayerRatioConstraint.isActive = false
		sheetDisplayerPreviousRatioConstraint.isActive = false
		sheetDisplayerNextRatioConstraint.isActive = false
		
		sheetDisplayerSwipeViewHeight.isActive = false
		
		if let sheetDisplaySwipeViewCustomHeightConstraint = sheetDisplaySwipeViewCustomHeightConstraint {
			sheetDisplaySwipeView.removeConstraint(sheetDisplaySwipeViewCustomHeightConstraint)
		}
		sheetDisplaySwipeViewCustomHeightConstraint = NSLayoutConstraint(item: sheetDisplaySwipeView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: (UIScreen.main.bounds.width - 20) * externalDisplayWindowRatio)
		sheetDisplaySwipeView.addConstraint(sheetDisplaySwipeViewCustomHeightConstraint!)
		
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
		
		view.layoutIfNeeded()
		view.layoutSubviews()
		
	}
	
	@IBAction func clearButtonPressed(_ sender: UIBarButtonItem) {

	}
	
	
	private func displaySheets() {
		if selectedSheet != nil {
			
			for subview in sheetDisplayer.subviews {
				subview.removeFromSuperview()
			}
			
			// display background
			sheetDisplaySwipeView.isHidden = false
			
			if let numberOfSheets = sheetsForSelectedCluster?.count, let position = selectedSheet?.position {
				
				sheetDisplayerPrevious.isHidden = true
				sheetDisplayerNext.isHidden = true
				
				let selectedSheetPosition = Int(position)
				
				if selectedSheetPosition < (numberOfSheets) {
					
					if let selectedSheet = selectedSheet {
												
						switch selectedSheet.type {
						case .SheetTitleContent:
							print("Title content")
							
							// current sheet
							if let tag = selectedCluster?.hasTag {
								let view = SheetTitleContent.createWith(frame: sheetDisplayer.bounds, title: selectedCluster?.title, sheet: selectedSheet as? SheetTitleContentEntity, tag: tag)
								sheetDisplayer.addSubview(view)
								
								if externalDisplayWindow != nil {
									_ = SheetTitleContent.createWith(frame: sheetDisplayer.bounds, title: selectedCluster?.title, sheet: selectedSheet as? SheetTitleContentEntity, tag: tag, scaleFactor: externalDisplayWindowWidth / sheetDisplayer.bounds.width).toExternalDisplay()
								}
							}
							
						case .SheetTitleImage:
							let view = SheetTitleImage.createWith(frame: sheetDisplayer.bounds, sheet: selectedSheet as! SheetTitleImageEntity, tag: selectedSheet.hasTag)
							sheetDisplayer.addSubview(view)
							
							if externalDisplayWindow != nil {
								_ = SheetTitleImage.createWith(frame: sheetDisplayer.bounds, sheet: selectedSheet as! SheetTitleImageEntity, tag: selectedSheet.hasTag, scaleFactor: externalDisplayWindowWidth / sheetDisplayer.bounds.width).toExternalDisplay()
							}
								
						case .SheetSplit:
							let view = SheetSplit.createWith(frame: sheetDisplayer.bounds, sheet: selectedSheet as! SheetSplitEntity, tag: selectedSheet.hasTag)
							sheetDisplayer.addSubview(view)
							
							if externalDisplayWindow != nil {
								_ = SheetSplit.createWith(frame: sheetDisplayer.bounds, sheet: selectedSheet as! SheetSplitEntity, tag: selectedSheet.hasTag, scaleFactor: externalDisplayWindowWidth / sheetDisplayer.bounds.width).toExternalDisplay()
							}
								
						case .SheetEmpty:
							let view = SheetEmpty.createWith(frame: sheetDisplayer.bounds, tag: selectedSheet.hasTag)
							sheetDisplayer.addSubview(view)
							if externalDisplayWindow != nil {
								_ = SheetEmpty.createWith(frame: sheetDisplayer.bounds, tag: selectedSheet.hasTag, scaleFactor: externalDisplayWindowWidth / sheetDisplayer.bounds.width)
							}
						}
						
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
	
	private func animateSheetsWith(_ direction : AnimationDirection, completion: @escaping () -> Void) {
		switch direction {
		case .left:
			
			print("left")
			
				// current sheet
				// current sheet, move to left
				let nextSheet = getNextSheet()
				var currentSheetView: SheetView?
				var nextSheetView: SheetView?

				
				if let selectedSheet = selectedSheet {
					switch selectedSheet.type {
					case .SheetTitleContent:
						currentSheetView = SheetTitleContent.createWith(frame: sheetDisplayer.bounds, title: selectedCluster?.title, sheet: selectedSheet as? SheetTitleContentEntity, tag: selectedCluster?.hasTag)
					case .SheetTitleImage:
						currentSheetView = SheetTitleImage.createWith(frame: sheetDisplayer.bounds, sheet: selectedSheet as! SheetTitleImageEntity, tag: selectedSheet.hasTag)
					case .SheetSplit:
						currentSheetView = SheetSplit.createWith(frame: sheetDisplayer.bounds, sheet: selectedSheet as! SheetSplitEntity, tag: selectedSheet.hasTag)
					case .SheetEmpty:
						currentSheetView = SheetEmpty.createWith(frame: sheetDisplayer.bounds, tag: selectedSheet.hasTag)
					}
					
					
					switch nextSheet?.type {
					case .none: break
					case .some(.SheetTitleContent):
						nextSheetView = SheetTitleContent.createWith(frame: sheetDisplayerNext.bounds, title: selectedCluster?.title, sheet: nextSheet as? SheetTitleContentEntity, tag: selectedCluster?.hasTag)
					case .some(.SheetTitleImage):
						nextSheetView = SheetTitleImage.createWith(frame: sheetDisplayer.bounds, sheet: nextSheet as! SheetTitleImageEntity, tag: nextSheet?.hasTag)
					case .some(.SheetSplit):
						nextSheetView = SheetSplit.createWith(frame: sheetDisplayer.bounds, sheet: nextSheet as! SheetSplitEntity, tag: nextSheet?.hasTag)
					case .some(.SheetEmpty):
						nextSheetView = SheetEmpty.createWith(frame: sheetDisplayer.bounds, tag: nextSheet?.hasTag)
					}

					currentSheetView?.frame = CGRect(
						x: sheetDisplayer.bounds.minX,
						y: sheetDisplayer.bounds.minY,
						width: sheetDisplayer.bounds.width,
						height: sheetDisplayer.bounds.height)
					
					nextSheetView?.frame = CGRect(
						x: UIScreen.main.bounds.width,
						y: sheetDisplayer.bounds.minY,
						width: sheetDisplayer.bounds.width,
						height: sheetDisplayer.bounds.height) // set the view
				}
				
				if let currentSheetView = currentSheetView, let nextSheetView = nextSheetView {
					view.addSubview(currentSheetView)
					view.addSubview(nextSheetView)
					sheetDisplayer.isHidden = true
					sheetDisplayerPrevious.isHidden = true
					sheetDisplayerNext.isHidden = true
					
					UIView.animate(withDuration: 0.3, animations: {
						currentSheetView.frame = CGRect(
							x: -UIScreen.main.bounds.width,
							y: self.sheetDisplayer.bounds.minY,
							width: self.sheetDisplayerPrevious.bounds.width,
							height: self.sheetDisplayerPrevious.bounds.height)

						nextSheetView.frame = CGRect(
							x: self.sheetDisplayer.frame.minX,
							y: self.sheetDisplayer.bounds.minY,
							width: self.sheetDisplayer.bounds.width,
							height: self.sheetDisplayer.bounds.height)
						
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
				
				let previousSheet = getPreviousSheet()

				// current sheet
				// current sheet, move to left
				var currentSheetView: SheetView?
				var previousSheetView: SheetView?
				
				if let selectedSheet = selectedSheet {
					switch selectedSheet.type {
					case .SheetTitleContent:
						
						currentSheetView = SheetTitleContent.createWith(frame: sheetDisplayer.bounds, title: selectedCluster?.title, sheet: selectedSheet as? SheetTitleContentEntity, tag: selectedCluster?.hasTag)
						
					case .SheetTitleImage:
						
						currentSheetView = SheetTitleImage.createWith(frame: sheetDisplayer.bounds, sheet: selectedSheet as! SheetTitleImageEntity, tag: selectedSheet.hasTag)
						
						
					case .SheetSplit:
						
						currentSheetView = SheetSplit.createWith(frame: sheetDisplayer.bounds, sheet: selectedSheet as! SheetSplitEntity, tag: selectedSheet.hasTag)
						
					case .SheetEmpty:
						
						currentSheetView = SheetEmpty.createWith(frame: sheetDisplayer.bounds, tag: selectedSheet.hasTag)
						
					}
					
					switch previousSheet?.type {
					case .none: break
					case .some(.SheetTitleContent):
						previousSheetView = SheetTitleContent.createWith(frame: sheetDisplayerPrevious.bounds, title: selectedCluster?.title, sheet: previousSheet as? SheetTitleContentEntity, tag: selectedCluster?.hasTag)
					case .some(.SheetTitleImage):
						previousSheetView = SheetTitleImage.createWith(frame: sheetDisplayer.bounds, sheet: previousSheet as! SheetTitleImageEntity, tag: previousSheet?.hasTag)
					case .some(.SheetSplit):
						previousSheetView = SheetSplit.createWith(frame: sheetDisplayer.bounds, sheet: previousSheet as! SheetSplitEntity, tag: previousSheet?.hasTag)
					case .some(.SheetEmpty):
						previousSheetView = SheetEmpty.createWith(frame: sheetDisplayer.bounds, tag: previousSheet?.hasTag)
					}
					
					currentSheetView?.frame = CGRect(
						x: sheetDisplayer.frame.minX,
						y: sheetDisplayer.bounds.minY,
						width: sheetDisplayer.bounds.width,
						height: sheetDisplayer.bounds.height)
					
					previousSheetView?.frame = CGRect(
						x: -UIScreen.main.bounds.width,
						y: self.sheetDisplayer.bounds.minY,
						width: sheetDisplayer.bounds.width,
						height: sheetDisplayerPrevious.bounds.height) // set the view
					
					
				}
				
				if let currentSheetView = currentSheetView, let previousSheetView = previousSheetView {
					view.addSubview(currentSheetView)
					view.addSubview(previousSheetView)
					sheetDisplayer.isHidden = true
					sheetDisplayerPrevious.isHidden = true
					sheetDisplayerNext.isHidden = true
					
					
					UIView.animate(withDuration: 0.3, animations: {
						previousSheetView.frame = CGRect(
							x: self.sheetDisplayer.frame.minX,
							y: self.sheetDisplayer.bounds.minY,
							width: self.sheetDisplayer.bounds.width,
							height: self.sheetDisplayer.bounds.height)
						
						currentSheetView.frame = CGRect(
							x: UIScreen.main.bounds.width,
							y: self.sheetDisplayer.frame.minY,
							width: self.sheetDisplayerNext.bounds.width,
							height: self.sheetDisplayerNext.bounds.height)


						
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

}
