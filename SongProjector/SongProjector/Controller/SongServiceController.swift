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



class SongServiceController: UIViewController, UITableViewDataSource, UITableViewDelegate, NewSongServiceDelegate, SongsControllerDelegate {
	
	
	// MARK: - Properties
	
	@IBOutlet var sheetDisplaySwipeView: UIView!
	@IBOutlet var sheetDisplayerPrevious: UIView!
	@IBOutlet var sheetDisplayer: UIView!
	@IBOutlet var sheetDisplayerNext: UIView!
	@IBOutlet var swipeUpDownImageView: UIImageView!
	@IBOutlet var tableViewClusters: UITableView!
	@IBOutlet var tableViewSheets: UITableView!
	@IBOutlet var titleTableCluster: UILabel!
	@IBOutlet var titleTableSheet: UILabel!
	@IBOutlet var clear: UIBarButtonItem!
	@IBOutlet var add: UIBarButtonItem!
	@IBOutlet var mixerHTopConstraint: NSLayoutConstraint!
	@IBOutlet var mixerContainerView: UIView!
	@IBOutlet var moveUpDownSection: UIView!
	
	@IBOutlet var sheetDisplayerSwipeViewHeight: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerRatioConstraint: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerPreviousRatioConstraint: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerNextRatioConstraint: NSLayoutConstraint!
	
	var customSheetDisplayerRatioConstraint: NSLayoutConstraint?
	var customSheetDisplayerPreviousRatioConstraint: NSLayoutConstraint?
	var customSheetDisplayerNextRatioConstraint: NSLayoutConstraint?
	var sheetDisplaySwipeViewCustomHeightConstraint: NSLayoutConstraint?
	var swipeAnimationIsActive = false

	
	// MARK: - Types
	
	private enum displayModeTypes {
		case small
		case normal
		case mixer
	}
	
	// MARK: - Private Properties
	
	private var newSheetDisplayerSwipeViewTopConstraint: NSLayoutConstraint?
	
	private var isAnimatingUpDown = false
	private var displayMode: displayModeTypes = .normal
	private var scaleFactor: CGFloat = 1
	private var sheetDisplayerInitialFrame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
	private var sheetDisplayerSwipeViewInitialHeight: CGFloat = 0
	private var isPlaying = false
	private var leftSwipe = UISwipeGestureRecognizer()
	private var viewToBeamer: SheetView?
	private var emptySheet: Sheet?
	
	private var hasEmptySheet = false
	private var externalScreen: UIScreen?
	private var externalScreenBounds = CGRect(x: 0, y: 0, width: 640, height: 480)
	private var clusters: [Cluster] = [] { didSet { update() } }
	private var clustersOrdened: [Cluster] { get { return clusters.sorted{ $0.position < $1.position } } }
	private var selectedClusterRow = -1
	private var selectedSheetRow = -1
	private var selectedCluster: Cluster? {
		willSet {
			if newValue == nil {
				if let hasEmptySheet = selectedCluster?.hasTag?.hasEmptySheet, hasEmptySheet {
					removeEmptySheet()
				}
			}
			stopPlay()
		}
		didSet {
			if let hasEmptySheet = selectedCluster?.hasTag?.hasEmptySheet, hasEmptySheet {
				addEmptySheet(selectedCluster, isEmptySheetFirst: selectedCluster?.hasTag?.isEmptySheetFirst)
			} else {
				selectedSheet = sheetsForSelectedCluster?.first
			}
			
		}
	}
	
	private var nextCluster: Cluster? {
		willSet {
			if newValue == nil {
				if let hasEmptySheet = nextCluster?.hasTag?.hasEmptySheet, hasEmptySheet {
					removeEmptySheet()
				}
			}
			stopPlay()
		}
		didSet {
			if let hasEmptySheet = nextCluster?.hasTag?.hasEmptySheet, hasEmptySheet {
				addEmptySheet(nextCluster, isEmptySheetFirst: nextCluster?.hasTag?.isEmptySheetFirst)
			}
		}
	}
	
	private var previousCluster: Cluster? {
		willSet {
			if newValue == nil {
				if let hasEmptySheet = previousCluster?.hasTag?.hasEmptySheet, hasEmptySheet {
					removeEmptySheet()
				}
			}
			stopPlay()
		}
		didSet {
			if let hasEmptySheet = previousCluster?.hasTag?.hasEmptySheet, hasEmptySheet {
				addEmptySheet(previousCluster, isEmptySheetFirst: previousCluster?.hasTag?.isEmptySheetFirst)
			}
		}
	}

	
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
				selectedSheet = selectedSheet?.id == emptySheet?.id ? nil : emptySheet
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
	
	func didFinishSongServiceSelection(clusters: [Cluster], completion: () -> Void) {
		self.clusters = clusters
		completion()
	}

	
	
	// MARK: SongsControllerDelegate Functions
	
	func didSelectCluster(cluster: Cluster){
		self.clusters.append(cluster)
	}
	
	
	
	// MARK: - Private Functions
	
	private func setup() {
		
		view.backgroundColor = themeWhiteBlackBackground
		clusters = CoreCluster.getEntities()
		
		navigationController?.title = Text.SongService.title
		titleTableCluster.text = Text.SongService.titleTableClusters
		titleTableSheet.text = Text.SongService.titleTableSheets
		
		clear.title = Text.Actions.new
		add.title = Text.Actions.add
		title = Text.SongService.title
				
		titleTableCluster.textColor = themeWhiteBlackTextColor
		titleTableCluster.backgroundColor = themeWhiteBlackBackground
		titleTableSheet.textColor = themeWhiteBlackTextColor
		titleTableSheet.backgroundColor = themeWhiteBlackBackground
		
		NotificationCenter.default.addObserver(forName: NotificationNames.externalDisplayDidChange, object: nil, queue: nil, using: externalDisplayDidChange)
		
		let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		
		leftSwipe.direction = .left
		rightSwipe.direction = .right
		
		sheetDisplaySwipeView.addGestureRecognizer(leftSwipe)
		sheetDisplaySwipeView.addGestureRecognizer(rightSwipe)
		
		tableViewClusters.register(cell: Cells.basicCellid)
		tableViewSheets.register(cell: Cells.basicCellid)
		
		update()
		
	}
	
	private func update() {
		tableViewClusters.reloadData()
		tableViewSheets.reloadData()
	}
	
	private func moveToFirstSheet() {
		tableViewSheets.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
	}
	
	private func displaySheets() {
		if selectedSheet != nil {
			
			for subview in sheetDisplayer.subviews {
				subview.removeFromSuperview()
			}
			
			// display background
			sheetDisplayer.isHidden = false
			
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
							if let tag = selectedSheet.hasTag ?? selectedCluster?.hasTag {
								let view = SheetTitleContent.createWith(frame: sheetDisplayer.bounds, title: selectedCluster?.title, sheet: selectedSheet as? SheetTitleContentEntity, tag: tag, scaleFactor: scaleFactor)
								sheetDisplayer.addSubview(view)
								
								if let externalDisplayWindow = externalDisplayWindow {
									_ = SheetTitleContent.createWith(frame: externalDisplayWindow.bounds, title: selectedCluster?.title, sheet: selectedSheet as? SheetTitleContentEntity, tag: tag, scaleFactor: (externalDisplayWindowWidth / sheetDisplayer.bounds.width) * scaleFactor).toExternalDisplay()
								}
							}
							
						case .SheetTitleImage:
							let view = SheetTitleImage.createWith(frame: sheetDisplayer.bounds, sheet: selectedSheet as! SheetTitleImageEntity, tag: selectedSheet.hasTag, scaleFactor: scaleFactor)
							sheetDisplayer.addSubview(view)
							
							if let externalDisplayWindow = externalDisplayWindow {
								_ = SheetTitleImage.createWith(frame: externalDisplayWindow.bounds, sheet: selectedSheet as! SheetTitleImageEntity, tag: selectedSheet.hasTag, scaleFactor: (externalDisplayWindowWidth / sheetDisplayer.bounds.width) * scaleFactor).toExternalDisplay()
							}
							
						case .SheetSplit:
							let view = SheetSplit.createWith(frame: sheetDisplayer.bounds, sheet: selectedSheet as! SheetSplitEntity, tag: selectedSheet.hasTag, scaleFactor: scaleFactor)
							sheetDisplayer.addSubview(view)
							
							if let externalDisplayWindow = externalDisplayWindow {
								_ = SheetSplit.createWith(frame: externalDisplayWindow.bounds, sheet: selectedSheet as! SheetSplitEntity, tag: selectedSheet.hasTag, scaleFactor: (externalDisplayWindowWidth / sheetDisplayer.bounds.width) * scaleFactor).toExternalDisplay()
							}
							
						case .SheetEmpty:
							let view = SheetEmpty.createWith(frame: sheetDisplayer.bounds, tag: selectedSheet.hasTag, scaleFactor: scaleFactor)
							sheetDisplayer.addSubview(view)
							if let externalDisplayWindow = externalDisplayWindow {
								_ = SheetEmpty.createWith(frame: externalDisplayWindow.bounds, tag: selectedSheet.hasTag, scaleFactor: (externalDisplayWindowWidth / sheetDisplayer.bounds.width) * scaleFactor).toExternalDisplay()
							}
							
						case .SheetActivities:
							let view = SheetActivitiesView.createWith(frame: sheetDisplayer.bounds, sheet: selectedSheet as? SheetActivities, tag: selectedSheet.hasTag, scaleFactor: scaleFactor)
							sheetDisplayer.addSubview(view)
							if let externalDisplayWindow = externalDisplayWindow {
								_ = SheetActivitiesView.createWith(frame: externalDisplayWindow.bounds, sheet: selectedSheet as? SheetActivities, tag: selectedSheet.hasTag, scaleFactor: (externalDisplayWindowWidth / sheetDisplayer.bounds.width) * scaleFactor).toExternalDisplay()
							}
						}
					
						if let previousSheet = getPreviousSheet() {
							sheetDisplayerPrevious.isHidden = false
							let previousScaleFactor: CGFloat = sheetDisplayerPrevious.bounds.height / sheetDisplayer.bounds.height
							
							switch previousSheet.type {
							case .SheetTitleContent:
								// current sheet
								if let tag = previousSheet.hasTag ?? getTagForPreviousSheet(sheet: previousSheet) {
									let view = SheetTitleContent.createWith(frame: sheetDisplayerPrevious.bounds, title: previousCluster?.title ?? selectedCluster?.title, sheet: previousSheet as? SheetTitleContentEntity, tag: tag, scaleFactor: previousScaleFactor)
									sheetDisplayerPrevious.addSubview(view)
									
									if let externalDisplayWindow = externalDisplayWindow {
										_ = SheetTitleContent.createWith(frame: externalDisplayWindow.bounds, title: previousCluster?.title ?? selectedCluster?.title, sheet: previousSheet as? SheetTitleContentEntity, tag: tag, scaleFactor: (externalDisplayWindowWidth / sheetDisplayerPrevious.bounds.width) * previousScaleFactor).toExternalDisplay()
									}
								}
								
							case .SheetTitleImage:
								let view = SheetTitleImage.createWith(frame: sheetDisplayerPrevious.bounds, sheet: previousSheet as! SheetTitleImageEntity, tag: previousSheet.hasTag, scaleFactor: previousScaleFactor)
								sheetDisplayerPrevious.addSubview(view)
								
								if let externalDisplayWindow = externalDisplayWindow {
									_ = SheetTitleImage.createWith(frame: externalDisplayWindow.bounds, sheet: previousSheet as! SheetTitleImageEntity, tag: previousSheet.hasTag, scaleFactor: (externalDisplayWindowWidth / sheetDisplayerPrevious.bounds.width) * previousScaleFactor).toExternalDisplay()
								}
								
							case .SheetSplit:
								let view = SheetSplit.createWith(frame: sheetDisplayerPrevious.bounds, sheet: previousSheet as! SheetSplitEntity, tag: previousSheet.hasTag, scaleFactor: previousScaleFactor)
								sheetDisplayerPrevious.addSubview(view)
								
								if let externalDisplayWindow = externalDisplayWindow {
									_ = SheetSplit.createWith(frame: externalDisplayWindow.bounds, sheet: previousSheet as! SheetSplitEntity, tag: previousSheet.hasTag, scaleFactor: (externalDisplayWindowWidth / sheetDisplayerPrevious.bounds.width) * previousScaleFactor).toExternalDisplay()
								}
								
							case .SheetEmpty:
								let view = SheetEmpty.createWith(frame: sheetDisplayerPrevious.bounds, tag: previousSheet.hasTag, scaleFactor: previousScaleFactor)
								sheetDisplayerPrevious.addSubview(view)
								if let externalDisplayWindow = externalDisplayWindow {
									_ = SheetEmpty.createWith(frame: externalDisplayWindow.bounds, tag: previousSheet.hasTag, scaleFactor: (externalDisplayWindowWidth / sheetDisplayerPrevious.bounds.width) * previousScaleFactor).toExternalDisplay()
								}
								
							case .SheetActivities:
								let view = SheetActivitiesView.createWith(frame: sheetDisplayerPrevious.bounds, sheet: previousSheet as? SheetActivities, tag: previousSheet.hasTag, scaleFactor: previousScaleFactor)
								sheetDisplayerPrevious.addSubview(view)
								if let externalDisplayWindow = externalDisplayWindow {
									_ = SheetActivitiesView.createWith(frame: externalDisplayWindow.bounds, sheet: previousSheet as? SheetActivities, tag: previousSheet.hasTag, scaleFactor: (externalDisplayWindowWidth / sheetDisplayerPrevious.bounds.width) * previousScaleFactor).toExternalDisplay()
								}
							}
							previousCluster = nil
							
						}
						else {
							sheetDisplayerPrevious.isHidden = true
						}
						
						if let nextSheet = getNextSheet() {
							sheetDisplayerNext.isHidden = false
							let nextScaleFactor: CGFloat = sheetDisplayerNext.bounds.height / sheetDisplayer.bounds.height
							
							switch nextSheet.type {
							case .SheetTitleContent:
								// current sheet
								if let tag = nextSheet.hasTag ?? getTagForNextSheet(sheet: nextSheet) {
									let view = SheetTitleContent.createWith(frame: sheetDisplayerNext.bounds, title: nextCluster?.title ?? selectedCluster?.title, sheet: nextSheet as? SheetTitleContentEntity, tag: tag, scaleFactor: nextScaleFactor)
									sheetDisplayerNext.addSubview(view)
									
									if let externalDisplayWindow = externalDisplayWindow {
										_ = SheetTitleContent.createWith(frame: externalDisplayWindow.bounds, title: nextCluster?.title ?? selectedCluster?.title, sheet: nextSheet as? SheetTitleContentEntity, tag: tag, scaleFactor: (externalDisplayWindowWidth / sheetDisplayerNext.bounds.width) * nextScaleFactor).toExternalDisplay()
									}
								}
								
							case .SheetTitleImage:
								let view = SheetTitleImage.createWith(frame: sheetDisplayerNext.bounds, sheet: nextSheet as! SheetTitleImageEntity, tag: nextSheet.hasTag, scaleFactor: nextScaleFactor)
								sheetDisplayerNext.addSubview(view)
								
								if let externalDisplayWindow = externalDisplayWindow {
									_ = SheetTitleImage.createWith(frame: externalDisplayWindow.bounds, sheet: nextSheet as! SheetTitleImageEntity, tag: nextSheet.hasTag, scaleFactor: (externalDisplayWindowWidth / sheetDisplayerNext.bounds.width) * nextScaleFactor).toExternalDisplay()
								}
								
							case .SheetSplit:
								let view = SheetSplit.createWith(frame: sheetDisplayerNext.bounds, sheet: nextSheet as! SheetSplitEntity, tag: nextSheet.hasTag, scaleFactor: nextScaleFactor)
								sheetDisplayerNext.addSubview(view)
								
								if let externalDisplayWindow = externalDisplayWindow {
									_ = SheetSplit.createWith(frame: externalDisplayWindow.bounds, sheet: nextSheet as! SheetSplitEntity, tag: nextSheet.hasTag, scaleFactor: (externalDisplayWindowWidth / sheetDisplayerNext.bounds.width) * nextScaleFactor).toExternalDisplay()
								}
								
							case .SheetEmpty:
								let view = SheetEmpty.createWith(frame: sheetDisplayerNext.bounds, tag: nextSheet.hasTag, scaleFactor: nextScaleFactor)
								sheetDisplayerNext.addSubview(view)
								if let externalDisplayWindow = externalDisplayWindow {
									_ = SheetEmpty.createWith(frame: externalDisplayWindow.bounds, tag: nextSheet.hasTag, scaleFactor: (externalDisplayWindowWidth / sheetDisplayerNext.bounds.width) * nextScaleFactor).toExternalDisplay()
								}
								
							case .SheetActivities:
								let view = SheetActivitiesView.createWith(frame: sheetDisplayerNext.bounds, sheet: nextSheet as? SheetActivities, tag: nextSheet.hasTag, scaleFactor: nextScaleFactor)
								sheetDisplayerNext.addSubview(view)
								if let externalDisplayWindow = externalDisplayWindow {
									_ = SheetActivitiesView.createWith(frame: externalDisplayWindow.bounds, sheet: nextSheet as? SheetActivities, tag: nextSheet.hasTag, scaleFactor: (externalDisplayWindowWidth / sheetDisplayerNext.bounds.width) * nextScaleFactor).toExternalDisplay()
								}
							}
							nextCluster = nil
						}
						else {
							sheetDisplayerNext.isHidden = true
						}
						
					}
				}
			}
			
			if !isPlaying {
				// check if needs to play
				if let duration = selectedCluster?.duration, duration > 0 {
					startPlay()
				} else if let sheetTime = selectedSheet?.time, sheetTime > 0 {
					startPlay()
				}
			}
			
		} else {
			stopPlay()
			shutDownDisplayer()
		}
	}
	
	private func shutDownDisplayer() {
		for subView in sheetDisplayer.subviews {
			subView.removeFromSuperview()
		}
		if clusters.count > 0 {
			sheetDisplayer.isHidden = true
			sheetDisplayerPrevious.isHidden = true
			sheetDisplayerNext.isHidden = true
		}
		if let externalDisplayWindow = externalDisplayWindow {
			let view = UIView(frame: externalDisplayWindow.frame)
			view.backgroundColor = .black
			externalDisplayWindow.addSubview(view)
			viewToBeamer?.removeFromSuperview()
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
							animateSheetsWith(.right, isNextOrPreviousCluster: true, completion: {
								self.selectedCluster = self.clusters[index - 1]
								self.selectedSheet = self.sheetsForSelectedCluster?[0]
								
								self.tableViewClusters.scrollToRow(at: IndexPath(row: index - 1, section: 0), at: .middle, animated: true)
							})
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
							animateSheetsWith(.left, isNextOrPreviousCluster: true, completion: {
								self.selectedCluster = self.clusters[index + 1]
								self.selectedSheet = self.sheetsForSelectedCluster?[0]
								self.tableViewClusters.scrollToRow(at: IndexPath(row: index + 1, section: 0), at: .middle, animated: true)
							})
						}
					}
				}
			}
		default:
			break
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
	
	@IBAction func clearButtonPressed(_ sender: UIBarButtonItem) {
		
	}
	
	private func animateSheetsWith(_ direction : AnimationDirection, isNextOrPreviousCluster: Bool = false, completion: @escaping () -> Void) {
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
					currentSheetView = SheetTitleContent.createWith(frame: sheetDisplayer.bounds, title: selectedCluster?.title, sheet: selectedSheet as? SheetTitleContentEntity, tag: selectedSheet.hasTag ?? selectedCluster?.hasTag, scaleFactor: scaleFactor)
				case .SheetTitleImage:
					currentSheetView = SheetTitleImage.createWith(frame: sheetDisplayer.bounds, sheet: selectedSheet as! SheetTitleImageEntity, tag: selectedSheet.hasTag, scaleFactor: scaleFactor)
				case .SheetSplit:
					currentSheetView = SheetSplit.createWith(frame: sheetDisplayer.bounds, sheet: selectedSheet as! SheetSplitEntity, tag: selectedSheet.hasTag, scaleFactor: scaleFactor)
				case .SheetEmpty:
					currentSheetView = SheetEmpty.createWith(frame: sheetDisplayer.bounds, tag: selectedSheet.hasTag, scaleFactor: scaleFactor)
				case .SheetActivities:
					currentSheetView = SheetActivitiesView.createWith(frame: sheetDisplayer.bounds, sheet: selectedSheet as? SheetActivities, tag: selectedSheet.hasTag, scaleFactor: scaleFactor)
				}
				
				switch nextSheet?.type {
				case .none: break
				case .some(.SheetTitleContent):
					nextSheetView = SheetTitleContent.createWith(frame: sheetDisplayer.bounds, title: isNextOrPreviousCluster ? nextCluster?.title : selectedCluster?.title, sheet: nextSheet as? SheetTitleContentEntity, tag: isNextOrPreviousCluster ? getTagForNextSheet(sheet: nextSheet) : nextSheet?.hasTag ?? selectedCluster?.hasTag, scaleFactor: scaleFactor)
				case .some(.SheetTitleImage):
					nextSheetView = SheetTitleImage.createWith(frame: sheetDisplayer.bounds, sheet: nextSheet as! SheetTitleImageEntity, tag: nextSheet?.hasTag, scaleFactor: scaleFactor)
				case .some(.SheetSplit):
					nextSheetView = SheetSplit.createWith(frame: sheetDisplayer.bounds, sheet: nextSheet as! SheetSplitEntity, tag: nextSheet?.hasTag, scaleFactor: scaleFactor)
				case .some(.SheetEmpty):
					nextSheetView = SheetEmpty.createWith(frame: sheetDisplayer.bounds, tag: nextSheet?.hasTag, scaleFactor: scaleFactor)
				case .some(.SheetActivities):
					nextSheetView = SheetActivitiesView.createWith(frame: sheetDisplayer.bounds, sheet: nextSheet as? SheetActivities, tag: nextSheet?.hasTag, scaleFactor: scaleFactor)
				}
				
			}
			
			if let currentSheetView = currentSheetView, let nextSheetView = nextSheetView {
				
				let imageCurrentSheet = currentSheetView.asImage()
				let currentImageView = UIImageView(frame: sheetDisplayer.frame)
				currentImageView.image = imageCurrentSheet
				
				let imageNext = nextSheetView.asImage()
				let nextImageView = UIImageView(frame: sheetDisplayerNext.frame)
				nextImageView.image = imageNext
				
				
				
				view.addSubview(currentImageView)
				view.addSubview(nextImageView)
				
				sheetDisplayer.isHidden = true
				sheetDisplayerNext.isHidden = true
				
				UIView.animate(withDuration: 0.3, animations: {
					currentImageView.frame = self.sheetDisplayerPrevious.frame
					
					nextImageView.frame = self.sheetDisplayer.frame
					
				}, completion: { (bool) in
					self.sheetDisplayer.isHidden = false
					self.sheetDisplayerPrevious.isHidden = false
					
					currentImageView.removeFromSuperview()
					nextImageView.removeFromSuperview()
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
						
						currentSheetView = SheetTitleContent.createWith(frame: sheetDisplayer.bounds, title: selectedCluster?.title, sheet: selectedSheet as? SheetTitleContentEntity, tag: selectedSheet.hasTag ?? selectedCluster?.hasTag, scaleFactor: scaleFactor)
						
					case .SheetTitleImage:
						
						currentSheetView = SheetTitleImage.createWith(frame: sheetDisplayer.bounds, sheet: selectedSheet as! SheetTitleImageEntity, tag: selectedSheet.hasTag, scaleFactor: scaleFactor)
						
						
					case .SheetSplit:
						
						currentSheetView = SheetSplit.createWith(frame: sheetDisplayer.bounds, sheet: selectedSheet as! SheetSplitEntity, tag: selectedSheet.hasTag, scaleFactor: scaleFactor)
						
					case .SheetEmpty:
						
						currentSheetView = SheetEmpty.createWith(frame: sheetDisplayer.bounds, tag: selectedSheet.hasTag, scaleFactor: scaleFactor)
					case .SheetActivities:
						currentSheetView = SheetActivitiesView.createWith(frame: sheetDisplayer.bounds, sheet: selectedSheet as? SheetActivities, tag: selectedSheet.hasTag, scaleFactor: scaleFactor)
					}
					
					switch previousSheet?.type {
					case .none: break
					case .some(.SheetTitleContent):
						previousSheetView = SheetTitleContent.createWith(frame: sheetDisplayer.bounds, title: isNextOrPreviousCluster ? previousCluster?.title : selectedCluster?.title, sheet: previousSheet as? SheetTitleContentEntity, tag: isNextOrPreviousCluster ? previousSheet?.hasTag ?? previousCluster?.hasTag : previousSheet?.hasTag ?? selectedCluster?.hasTag, scaleFactor: scaleFactor)
					case .some(.SheetTitleImage):
						previousSheetView = SheetTitleImage.createWith(frame: sheetDisplayer.bounds, sheet: previousSheet as! SheetTitleImageEntity, tag: previousSheet?.hasTag, scaleFactor: scaleFactor)
					case .some(.SheetSplit):
						previousSheetView = SheetSplit.createWith(frame: sheetDisplayer.bounds, sheet: previousSheet as! SheetSplitEntity, tag: previousSheet?.hasTag, scaleFactor: scaleFactor)
					case .some(.SheetEmpty):
						previousSheetView = SheetEmpty.createWith(frame: sheetDisplayer.bounds, tag: previousSheet?.hasTag, scaleFactor: scaleFactor)
					case .some(.SheetActivities):
						currentSheetView = SheetActivitiesView.createWith(frame: sheetDisplayer.bounds, sheet: previousSheet as? SheetActivities, tag: previousSheet?.hasTag, scaleFactor: scaleFactor)
					}
					
				}
				
				if let currentSheetView = currentSheetView, let previousSheetView = previousSheetView {
					
					let imageCurrentSheet = currentSheetView.asImage()
					let currentImageView = UIImageView(frame: sheetDisplayer.frame)
					currentImageView.image = imageCurrentSheet
					
					let previousImage = previousSheetView.asImage()
					let previousImageView = UIImageView(frame: sheetDisplayerPrevious.frame)
					previousImageView.image = previousImage
					
					view.addSubview(currentImageView)
					view.addSubview(previousImageView)
					sheetDisplayer.isHidden = true
					sheetDisplayerPrevious.isHidden = true
					sheetDisplayerNext.isHidden = getNextSheet() == nil
					
					UIView.animate(withDuration: 0.3, animations: {
						
						previousImageView.frame = self.sheetDisplayer.frame
						currentImageView.frame = self.sheetDisplayerNext.frame

					}, completion: { (bool) in
						self.sheetDisplayer.isHidden = false
						self.sheetDisplayerPrevious.isHidden = false
						previousImageView.removeFromSuperview()
						currentImageView.removeFromSuperview()
						completion()
					})
				}
			}
		}
	}
	
	private func getNextSheet() -> Sheet? {
		if let sheetsForSelectedCluster = sheetsForSelectedCluster, let position = selectedSheet?.position {
			let nextPosition = Int(position) + 1
			if nextPosition < sheetsForSelectedCluster.count {
				return sheetsForSelectedCluster[nextPosition]
			} else if isPlaying{
				return sheetsForSelectedCluster.first
			}else if let clusterPosition = selectedCluster?.position, Int(clusterPosition) + 1 < clusters.count {
				nextCluster = self.clustersOrdened[Int(clusterPosition) + 1]
				return nextCluster?.hasSheetsArray.first
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
				previousCluster = clustersOrdened[Int(clusterPosition) - 1]
				return previousCluster?.hasSheetsArray.first
			} else {
				return nil
			}
		} else {
			return nil
		}
	}
	
	private func getTagForPreviousSheet(sheet: Sheet?) -> Tag? {
		if let previousCluster = previousCluster, let sheet = sheet {
			return previousCluster.hasSheetsArray.contains(sheet) ? previousCluster.hasTag : selectedCluster?.hasTag
		} else {
			return selectedCluster?.hasTag
		}
	}
	
	private func getTagForNextSheet(sheet: Sheet?) -> Tag? {
		if let nextCluster = nextCluster, let sheet = sheet {
			return nextCluster.hasSheetsArray.contains(sheet) ? sheet.hasTag ?? nextCluster.hasTag : selectedCluster?.hasTag
		} else {
			return selectedCluster?.hasTag
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
	
	func databaseDidChange( _ notification: Notification) {
		selectedCluster = nil
		selectedSheet = nil
		
		if clusters.count > 0 {
			for cluster in clusters {
				CoreCluster.predicates.append("id", equals: cluster.id)
			}
			clusters = CoreCluster.getEntities()
		}
	}
	
	func externalDisplayDidChange(_ notification: Notification) {
		scaleFactor = 1
		updateSheetDisplayersRatios()
		displaySheets()
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
	
	private func startPlay() {
		isPlaying = true
		
		// is cluster has time (advertisement)
		if let time = selectedCluster?.duration {
			DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
				if self.isPlaying {
					self.respondToSwipeGesture(self.leftSwipe)
					
					// keep doing while isPlaying is true
					if self.isPlaying {
						self.startPlay()
					}
				}
			})
		}
			
			// else if sheet has time (mp3 song)
		else if let time = selectedSheet?.time, time > 0 {
			DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
				if self.isPlaying {
					self.respondToSwipeGesture(self.leftSwipe)
					
					// keep doing while isPlaying is true
					if self.isPlaying {
						self.startPlay()
					}
				}
			})
		}
	}
	
	private func stopPlay() {
		isPlaying = false
	}
	
}
