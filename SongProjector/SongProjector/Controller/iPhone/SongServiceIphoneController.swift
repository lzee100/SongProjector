//
//  SongServiceIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 23-12-17.
//  Copyright © 2017 iozee. All rights reserved.
//

import UIKit
import QuartzCore
import MediaPlayer
import AWSAuthCore
import AWSAuthUI

extension NSLayoutConstraint {
	func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
		return NSLayoutConstraint(item: self.firstItem, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
	}
}

class SongServiceIphoneController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, NewSongServiceDelegate, FetcherObserver {

	@IBOutlet var new: UIBarButtonItem!
	@IBOutlet var sheetDisplaySwipeView: UIView!

	@IBOutlet var sheetDisplayerPrevious: UIView!
	@IBOutlet var sheetDisplayer: UIView!
	@IBOutlet var sheetDisplayerNext: UIView!
	@IBOutlet var emptyViewTableView: UIView!
	
	@IBOutlet var swipeUpDownImageView: UIImageView!
	@IBOutlet var swipeLineLeft: UIView!
	@IBOutlet var swipeLineRight: UIView!
	@IBOutlet var sheetDisplayerSwipeViewTopConstraint: NSLayoutConstraint!
	@IBOutlet var swipeLineLeftWidthConstraint: NSLayoutConstraint!
	@IBOutlet var swipeLineRightWidthConstraint: NSLayoutConstraint!
	
	@IBOutlet var sheetDisplayerNextLeftConstraint: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerPreviousRightConstraint: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerSwipeViewHeight: NSLayoutConstraint!
	
	@IBOutlet var sheetDisplayerRatioConstraint: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerPreviousRatioConstraint: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerNextRatioConstraint: NSLayoutConstraint!
	
	private var playerTimer = Timer()
	private var displayTimeTimer = Timer()
	var customSheetDisplayerRatioConstraint: NSLayoutConstraint?
	var customSheetDisplayerPreviousRatioConstraint: NSLayoutConstraint?
	var customSheetDisplayerNextRatioConstraint: NSLayoutConstraint?
	var sheetDisplaySwipeViewCustomHeightConstraint: NSLayoutConstraint?
	var swipeAnimationIsActive = false
	@IBOutlet var mixerHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet var mixerContainerView: UIView!
	@IBOutlet var moveUpDownSection: UIView!
	@IBOutlet var tableView: UITableView!
	
	
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
			stopPlay()
		}
		didSet {
			if let hasEmptySheet = selectedCluster?.hasTag?.hasEmptySheet, hasEmptySheet {
				addEmptySheet(selectedCluster, isEmptySheetFirst: selectedCluster?.hasTag?.isEmptySheetFirst)
			} else {
				selectedSheet = sheetsForSelectedCluster?.first
			}
			updateTime()
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
	
	
	
	// MARK: - Functions
	
	// MARK: UIViewController Functions
	
	override func viewDidLoad() {
		super.viewDidLoad()
//		GoogleActivityFetcher.addObserver(self)
		setup()
		if !AWSSignInManager.sharedInstance().isLoggedIn {
			AWSAuthUIViewController
				.presentViewController(with: self.navigationController!,
									   configuration: nil,
									   completionHandler: { (provider: AWSSignInProvider, error: Error?) in
										if error != nil {
											print("Error occurred: \(String(describing: error))")
										} else {
											OrganizationsCRUD.insertOrganizationWith(id: "id", name: "leo")
										}
				})
		} else {
			OrganizationsCRUD.insertOrganizationWith(id: "id", name: "leo")

		}

	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
//		GoogleActivityFetcher.fetch(false)
		update()
		OrganizationsCRUD.insertOrganizationWith(id: "id", name: "leo")

	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let controller = segue.destination as? UINavigationController, let newSongServiceIphoneController = controller.viewControllers.first as? NewSongServiceIphoneController {
			newSongServiceIphoneController.delegate = self
			newSongServiceIphoneController.selectedSongs = clusters
		}
	}
	
	
	
	// MARK: UITableViewDelegate Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if clusters.count == 0 {
			// return No songs selected cell
			return 1
			// return only 1 cell if song has but 1 sheet
		} else {
			if selectedCluster != nil {
				return clusters.count +  (sheetsForSelectedCluster?.count == 1 ? 0 : sheetsForSelectedCluster?.count ?? 0)
			} else {
				return clusters.count
			}
		}
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
	
	func didFinishSongServiceSelection(clusters: [Cluster], completion: () -> Void) {
		self.clusters = clusters
		completion()
	}
	
	
	// MARK: Fetcher Functions
	
	func FetcherDidStart() {
		
	}
	
	func FetcherDidFinish(result: ResultTypes) {
		update()
	}
	
	
	// MARK: - Private Functions
	
	private func setup() {
		
		navigationController?.title = Text.SongService.title
		title = Text.SongService.title
		mixerHeightConstraint.constant = 0
		
		new.title = Text.Actions.add
		swipeUpDownImageView.tintColor = themeHighlighted
//		GoogleActivityFetcher.fetch(true)
		view.backgroundColor = themeWhiteBlackBackground
		emptyViewTableView.backgroundColor = themeWhiteBlackBackground
		moveUpDownSection.backgroundColor = themeWhiteBlackBackground
		swipeLineLeft.backgroundColor = themeHighlighted
		swipeLineRight.backgroundColor = themeHighlighted
		swipeLineLeftWidthConstraint.constant = UIScreen.main.bounds.width * 0.35
		swipeLineRightWidthConstraint.constant = UIScreen.main.bounds.width * 0.35
		
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
		
		leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))

		leftSwipe.direction = .left
		rightSwipe.direction = .right
		
		sheetDisplayerNextLeftConstraint.constant = UIScreen.main.bounds.width
		sheetDisplayerPreviousRightConstraint.constant = -UIScreen.main.bounds.width
		
		sheetDisplaySwipeView.addGestureRecognizer(leftSwipe)
		sheetDisplaySwipeView.addGestureRecognizer(rightSwipe)
		
		tableView.register(cell: Cells.basicCellid)
		updateSheetDisplayersRatios()
		sheetDisplayerInitialFrame = sheetDisplayer.bounds
		sheetDisplayerSwipeViewInitialHeight = sheetDisplaySwipeViewCustomHeightConstraint?.constant ?? sheetDisplaySwipeView.bounds.height
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
						self.tableView.scrollToRow(at: IndexPath(row: Int(clusterPosition) + nextPosition, section: 0), at: .middle, animated: true)
					} else {
						
						// don't go to next song but play first sheet again
						if isPlaying {
							animateSheetsWith(.left, completion: {
								self.swipeAnimationIsActive = false
								self.selectedSheet = self.sheetsForSelectedCluster?.first
							})
							return
						}
						// display next song
						if let clusterPosition = selectedCluster?.position, Int(clusterPosition) + 1 < clusters.count {
							swipeAnimationIsActive = true
							animateSheetsWith(.left, isNextOrPreviousCluster: true, completion: {
								self.swipeAnimationIsActive = false
								self.selectedClusterRow += 1
								self.selectedCluster = self.clustersOrdened[Int(clusterPosition) + 1]
								self.selectedSheet = self.sheetsForSelectedCluster?.first
							})
							self.tableView.scrollToRow(at: IndexPath(row: Int(clusterPosition) + nextPosition, section: 0), at: .middle, animated: true)
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
							animateSheetsWith(.right, isNextOrPreviousCluster: true, completion: {
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
			if !isAnimatingUpDown {
				isAnimatingUpDown = true
				switch sender.direction {
				case .up:
					print("up")
					switch displayMode {
					case .mixer:
						if let topConstraint = newSheetDisplayerSwipeViewTopConstraint, topConstraint.isActive {
							
							mixerHeightConstraint.constant = 0

							
							sheetDisplayerSwipeViewTopConstraint.isActive = true
							topConstraint.isActive = false
							
							UIView.animate(withDuration: 0.3, animations: {
								self.view.layoutIfNeeded()
							}, completion: { (bool) in
								self.displayMode = .normal
								self.isAnimatingUpDown = false
								for subView in self.mixerContainerView.subviews {
									subView.removeFromSuperview()
								}
							})
							
						}
					case .normal:
						if let heightConstraint = sheetDisplaySwipeViewCustomHeightConstraint, heightConstraint.isActive, heightConstraint.constant > (sheetDisplayerSwipeViewInitialHeight / 2) {
							
							// old height copy to image
							let image = sheetDisplayer.asImage()
							let imageView = UIImageView(frame: sheetDisplayer.bounds)
							imageView.image = image
							view.addSubview(imageView)
							
							// new height
							self.sheetDisplaySwipeViewCustomHeightConstraint?.constant = (heightConstraint.constant / 2)
							sheetDisplayer.isHidden = true
							self.view.layoutIfNeeded()
							
							// set image to new height
							
							UIView.animate(withDuration: 0.2, animations: {
								imageView.frame = self.sheetDisplayer.frame
							}, completion: { (bool) in
								self.sheetDisplayer.isHidden = false
								imageView.removeFromSuperview()
								self.scaleFactor = self.sheetDisplayer.bounds.width / self.sheetDisplayerInitialFrame.width
								self.displaySheets()
								self.displayMode = .small
								self.isAnimatingUpDown = false
							})
							
							
						}
					default:
						isAnimatingUpDown = false
						break
					}
					
				case .down:
					print("down")
					switch displayMode {
					case .small:
						if let heightConstraint = sheetDisplaySwipeViewCustomHeightConstraint, heightConstraint.isActive, heightConstraint.constant < sheetDisplayerSwipeViewInitialHeight && heightConstraint.constant > 0 {
							// MAKE BIGGER
							
							// old height copy to image
							let image = sheetDisplayer.asImage()
							let imageView = UIImageView(frame: sheetDisplayer.frame)
							imageView.image = image
							view.addSubview(imageView)
							sheetDisplayer.isHidden = true
							
							// new height
							self.sheetDisplaySwipeViewCustomHeightConstraint?.constant = sheetDisplayerSwipeViewInitialHeight
							self.view.layoutIfNeeded()
							
							// set image to new height
							
							UIView.animate(withDuration: 0.3, animations: {
								imageView.frame = self.sheetDisplayer.frame
							}, completion: { (bool) in
								self.sheetDisplayer.isHidden = false
								imageView.removeFromSuperview()
								self.scaleFactor = self.sheetDisplayer.bounds.width / self.sheetDisplayerInitialFrame.width
								self.displaySheets()
								self.displayMode = .normal
								self.isAnimatingUpDown = false
							})
						}
						
					case .normal:
						if let heightConstraint = sheetDisplaySwipeViewCustomHeightConstraint, heightConstraint.isActive, heightConstraint.constant == sheetDisplayerSwipeViewInitialHeight { // SHOW MIXER
							
							let mixerView = MixerView(frame: CGRect(x: 0, y: 0, width: mixerContainerView.bounds.width, height: sheetDisplayerSwipeViewInitialHeight + 100))
							mixerContainerView.addSubview(mixerView)
							view.layoutIfNeeded()
							
							// move sheets up
							sheetDisplayerSwipeViewTopConstraint.isActive = false
							newSheetDisplayerSwipeViewTopConstraint = NSLayoutConstraint(item: sheetDisplaySwipeView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: -sheetDisplayerSwipeViewInitialHeight)
							newSheetDisplayerSwipeViewTopConstraint?.isActive = true
							
							// move mixer 50 down and to top of superview
							mixerHeightConstraint.constant = sheetDisplayerSwipeViewInitialHeight + 100

							
							UIView.animate(withDuration: 0.3, animations: {
								self.view.layoutIfNeeded()
							}, completion: { (bool) in
								self.displayMode = .mixer
								self.isAnimatingUpDown = false
							})
						}
					default:
						isAnimatingUpDown = false
						break
					}
				default:
					break
				}
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
		scaleFactor = 1
		updateSheetDisplayersRatios()
		displaySheets()
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
		}
		if let externalDisplayWindow = externalDisplayWindow {
			let view = UIView(frame: externalDisplayWindow.frame)
			view.backgroundColor = .black
			externalDisplayWindow.addSubview(view)
			viewToBeamer?.removeFromSuperview()
		}
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
						previousSheetView = SheetTitleContent.createWith(frame: sheetDisplayer.bounds, title: isNextOrPreviousCluster ? previousCluster?.title : selectedCluster?.title, sheet: previousSheet as? SheetTitleContentEntity, tag: isNextOrPreviousCluster ? getTagForPreviousSheet(sheet: previousSheet) : previousSheet?.hasTag ?? selectedCluster?.hasTag, scaleFactor: scaleFactor)
					case .some(.SheetTitleImage):
						previousSheetView = SheetTitleImage.createWith(frame: sheetDisplayer.bounds, sheet: previousSheet as! SheetTitleImageEntity, tag: previousSheet?.hasTag, scaleFactor: scaleFactor)
					case .some(.SheetSplit):
						previousSheetView = SheetSplit.createWith(frame: sheetDisplayer.bounds, sheet: previousSheet as! SheetSplitEntity, tag: previousSheet?.hasTag, scaleFactor: scaleFactor)
					case .some(.SheetEmpty):
						previousSheetView = SheetEmpty.createWith(frame: sheetDisplayer.bounds, tag: previousSheet?.hasTag, scaleFactor: scaleFactor)
					case .some(.SheetActivities):
						currentSheetView = SheetActivitiesView.createWith(frame: sheetDisplayer.bounds, sheet: previousSheet as? SheetActivities, tag: previousSheet?.hasTag, scaleFactor: scaleFactor)
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
	
	private func updateTime() {
		if let displayTimeTag = selectedCluster?.hasTag?.displayTime, displayTimeTag {
			let date = Date()
			let seconds = Calendar.current.component(.second, from: date)
			let remainder = 60 - seconds
			let fireDate = date.addingTimeInterval(.seconds(Double(remainder)))
			print(fireDate.description)
			displayTimeTimer = Timer(fireAt: fireDate, interval: 60, target: self, selector: #selector(updateScreen), userInfo: nil, repeats: true)
			RunLoop.main.add(displayTimeTimer, forMode: RunLoopMode.commonModes)
			
		} else {
			displayTimeTimer.invalidate()
		}
	}
	
	@objc private func updateScreen() {
		displaySheets()
	}
	
	
	// MARK - player
	
	private func startPlay() {
		if let time = selectedCluster?.duration {
			isPlaying = true
			playerTimer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(swipeAutomatically), userInfo: nil, repeats: true)
		}
		
		// else if sheet has time (mp3 song)
		else if let time = selectedSheet?.time, time > 0 {
			isPlaying = true
			playerTimer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(swipeAutomatically), userInfo: nil, repeats: true)
		}
	}
	
	@objc private func swipeAutomatically() {
		self.respondToSwipeGesture(self.leftSwipe)
	}
	
	
	private func stopPlay() {
		playerTimer.invalidate()
		isPlaying = false
	}
	
	
	@IBAction func deleteDB(_ sender: UIBarButtonItem) {
		
		if let song = CoreSong.getEntities().first {
			SoundPlayer.play(song: song)
		}
	}
	
}
