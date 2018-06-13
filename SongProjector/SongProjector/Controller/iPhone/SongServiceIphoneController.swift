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
import MessageUI

extension NSLayoutConstraint {
	func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
		return NSLayoutConstraint(item: self.firstItem, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
	}
}

class SongService {
	var songs: [SongObject] = [] { didSet { songs.sort{ $0.cluster.position < $1.cluster.position } }}
	var selectedSong: SongObject? { return songs.first(where: { $0.selectedSheet != nil }) }
	
	var selectedTag: Tag? { return selectedSong?.selectedSheet?.hasTag ?? selectedSong?.cluster.hasTag }
	var previousTag: Tag? { return getPreviousTag() }
	var nextTag: Tag? { return getNextTag() }
	
	@discardableResult
	func nextSheet(select: Bool = true) -> Sheet? {
		if let selectedSong = selectedSong {
			let selectedSheetPosition = Int(selectedSong.selectedSheet!.position)
			if selectedSheetPosition + 1 < selectedSong.sheets.count {
				if !select {
					return selectedSong.sheets[selectedSheetPosition + 1]
				}
				selectedSong.selectedSheet = selectedSong.sheets[selectedSheetPosition + 1]
				return selectedSong.selectedSheet
			} else {
				guard let index = songs.index(where: { $0.selectedSheet != nil }) else {
					return nil
				}
				
				if index + 1 > songs.count {
					return nil
				}
				if !select {
					return songs[index + 1].sheets.first
				}
				selectedSong.selectedSheet = nil
				songs[index + 1].selectedSheet = songs[index + 1].sheets.first
				return selectedSong.selectedSheet
				
			}
		} else {
			if !select {
				return songs.first?.sheets.first
			}
			songs.first?.selectedSheet = songs.first?.sheets.first
			return selectedSong?.selectedSheet
		}
	}

	@discardableResult
	func previousSheet(select: Bool = true) -> Sheet? {
		if let selectedSong = selectedSong {
			let selectedSheetPosition = Int(selectedSong.selectedSheet!.position)
			if selectedSheetPosition - 1 > 0 {
				if !select {
					return selectedSong.sheets[selectedSheetPosition - 1]
				}
				selectedSong.selectedSheet = selectedSong.sheets[selectedSheetPosition - 1]
				return selectedSong.selectedSheet
			} else {
				guard let index = songs.index(where: { $0.selectedSheet != nil }) else {
					return nil
				}
				
				if index - 1 < 0 {
					return nil
				}
				
				if !select {
					return songs[index - 1].sheets.first
				}
				
				selectedSong.selectedSheet = nil
				songs[index - 1].selectedSheet = songs[index - 1].sheets.first
				return selectedSong.selectedSheet
				
			}
		} else {
			return nil
		}
	}

	func indexPathForNextSheet() -> IndexPath? {
		if let selectedSong = selectedSong {
			let selectedSheetPosition = Int(selectedSong.selectedSheet!.position)
			if selectedSheetPosition + 1 < selectedSong.sheets.count {
				return IndexPath(row: selectedSheetPosition + 1, section: Int(selectedSong.cluster.position))
			} else {
				guard let index = songs.index(where: { $0.selectedSheet != nil }) else {
					return nil
				}
				
				if index + 1 > songs.count {
					return nil
				}
				return IndexPath(row: 0, section: index + 1)
			}
		} else {
			if songs.first?.sheets.first != nil {
				return IndexPath(row: 0, section: 0)
			} else {
				return nil
			}
		}
	}
	
	func indexPathForPreviousSheet() -> IndexPath? {
		
		if let selectedSong = selectedSong {
			let selectedSheetPosition = Int(selectedSong.selectedSheet!.position)
			if selectedSheetPosition - 1 > 0 {
				return IndexPath(row: selectedSheetPosition - 1, section: Int(selectedSong.cluster.position))
			} else {
				guard let index = songs.index(where: { $0.selectedSheet != nil }) else {
					return nil
				}
				
				if index - 1 < 0 {
					return nil
				}
				return IndexPath(row: 0, section: index - 1)
			}
		} else {
			return nil
		}
	}
	
	func getSongForNextSheet() -> SongObject? {
		if let position = selectedSong?.selectedSheet?.position, Int(position) + 1 < (selectedSong?.sheets.count ?? 0) {
			return selectedSong
		} else {
			if let index = songs.index(where: { $0.selectedSheet != nil }) {
				if index + 1 <= songs.count {
					return songs[index + 1]
				}
				return nil
			} else {
				return songs.first
			}
		}
	}
	
	func getSongForPreviousSheet() -> SongObject? {
		if let position = selectedSong?.selectedSheet?.position, Int(position) - 1 > 0 {
			return selectedSong
		} else {
			if let index = songs.index(where: { $0.selectedSheet != nil }) {
				if index - 1 >= 0 {
					return songs[index - 1]
				}
				return nil
			} else {
				return nil
			}
		}
	}
	
	private func getPreviousTag() -> Tag? {
		if let selectedSong = selectedSong {
			let selectedSheetPosition = Int(selectedSong.selectedSheet!.position)
			if selectedSheetPosition - 1 > 0 {
				return selectedSong.sheets[selectedSheetPosition - 1].hasTag ?? selectedSong.cluster.hasTag
			} else {
				guard let index = songs.index(where: { $0.selectedSheet != nil }) else {
					return nil
				}
				
				if index - 1 < 0 {
					return nil
				}
				
				return songs[index - 1].sheets.first?.hasTag ?? songs[index - 1].cluster.hasTag
				
			}
		} else {
			return nil
		}
	}
	
	private func getNextTag() -> Tag? {
		if let selectedSong = selectedSong {
			let selectedSheetPosition = Int(selectedSong.selectedSheet!.position)
			if selectedSheetPosition + 1 < selectedSong.sheets.count {
				return selectedSong.sheets[selectedSheetPosition + 1].hasTag ?? selectedSong.cluster.hasTag
			} else {
				guard let index = songs.index(where: { $0.selectedSheet != nil }) else {
					return nil
				}
				
				if index + 1 > songs.count {
					return nil
				}
				return songs[index + 1].sheets.first?.hasTag ?? songs[index + 1].cluster.hasTag
				
			}
		} else {
			return songs.first?.sheets.first?.hasTag ?? songs.first?.cluster.hasTag
		}
	}
	
}

class SongObject {
	let cluster: Cluster
	var sheets: [Sheet] {
		return cluster.hasSheetsArray
	}
	var selectedSheet: Sheet? { didSet { if let sheet = selectedSheet {	displaySheet(sheet)	} } }
	var clusterTag: Tag? {
		return cluster.hasTag
	}
	
	var displaySheet: ((Sheet) -> Void)
	
	init(cluster: Cluster, displaySheet: @escaping ((Sheet) -> Void)) {
		self.cluster = cluster
		self.displaySheet = displaySheet
	}
}

class SongServiceIphoneController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, NewSongServiceDelegate, FetcherObserver {

	@IBOutlet var new: UIBarButtonItem!
	@IBOutlet var sheetDisplaySwipeView: UIView!

	@IBOutlet var sheetDisplayerPrevious: SheetView!
	@IBOutlet var sheetDisplayer: SheetView!
	@IBOutlet var sheetDisplayerNext: SheetView!
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
	
	// new try
	
	private var songService = SongService()
	private var isAnimatingUpDown = false
	private var displayMode: displayModeTypes = .normal
	private var scaleFactor: CGFloat = 1
	private var sheetDisplayerInitialFrame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
	private var sheetDisplayerSwipeViewInitialHeight: CGFloat = 0
	private var isPlaying = false
	private var leftSwipe = UISwipeGestureRecognizer()
	private var viewToBeamer: SheetView?
	private var emptySheet: Sheet?
	
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
			newSongServiceIphoneController.selectedSongs = songService.songs.compactMap { $0.cluster }
		}
	}
	
	
	
	// MARK: UITableViewDelegate Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return songService.songs.count
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if songService.songs.count == 0 {
			// return No songs selected cell
			return 1
			// return only 1 cell if song has but 1 sheet
		} else {
			if songService.songs[section].selectedSheet != nil {
				return songService.songs[section].sheets.count
			} else {
				return 0
			}
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
		let currentSheet = songService.songs[indexPath.section].sheets[indexPath.row]
		
		if let cell = cell as? BasicCell {
			if songService.songs.count == 0 {
				cell.setup(title: Text.NewSongService.noSelectedSongs)
				cell.isSelected = false
				return cell
			}
			
			cell.setup(title: currentSheet.title, icon: Cells.sheetIcon)
			cell.isInnerCell = true
			cell.selectedCell = songService.songs[indexPath.section].selectedSheet == currentSheet
			
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let currentSheet = songService.songs[indexPath.section].sheets[indexPath.row]
		if currentSheet == songService.songs[indexPath.section].selectedSheet {
			songService.songs[indexPath.section].selectedSheet = nil
		} else {
			songService.songs.forEach { $0.selectedSheet = nil }
			songService.songs[indexPath.section].selectedSheet = currentSheet
		}
		update()
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = SongHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 60))
		let song = songService.songs[section]
		view.didSelectHeader = didSelectSection(section:)
		view.setup(title: song.cluster.title, icon: Cells.songIcon, isSelected: song.selectedSheet != nil, tag: section)
		return view
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 60
	}
	
	// MARK: NewSongServiceDelegate Functions
	
	func didFinishSongServiceSelection(clusters: [Cluster]) {
		self.songService.songs = clusters.map{ SongObject(cluster: $0, displaySheet: display(sheet:)) }
		update()
	}
	
	
	
	// MARK: SongsControllerDelegate Functions
	
	func didFinishSongServiceSelection(clusters: [Cluster], completion: () -> Void) {
		self.songService.songs = clusters.map{ SongObject(cluster: $0, displaySheet: display(sheet:)) }
		completion()
		update()
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

	private func didSelectSection(section: Int) {
		let nothhingWasSelected = songService.selectedSong == nil
		songService.songs.forEach { $0.selectedSheet = nil }
		if nothhingWasSelected {
			songService.songs[section].selectedSheet = songService.songs[section].sheets.first
		}
		update()
	}
	
	@objc private func respondToSwipeGesture(_ sender: UISwipeGestureRecognizer) {
		
		if sender.view == sheetDisplaySwipeView {
			switch sender.direction {
				
			case .left:
				
				if let nextSheet = songService.nextSheet(select: false) {
					swipeAnimationIsActive = true
					animateSheetsWith(.left, completion: {
						self.swipeAnimationIsActive = false
						self.display(sheet: nextSheet)
						self.songService.nextSheet()
						self.update()
						if let indexPath = self.songService.indexPathForNextSheet() {
							self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
						}
					})
					
				} else {
					// don't go to next song but play first sheet again
					if isPlaying {
						animateSheetsWith(.left, completion: {
							self.swipeAnimationIsActive = false
							self.songService.selectedSong?.selectedSheet = self.songService.selectedSong?.sheets.first
							if let sheet = self.songService.selectedSong?.sheets.first {
								self.display(sheet: sheet)
							}
						})
						return
					}
				}
				
			case .right:
				print("right")
				
				if let previousSheet = songService.previousSheet(select: false) {
					swipeAnimationIsActive = true
					animateSheetsWith(.right, completion: {
						self.swipeAnimationIsActive = false
						self.display(sheet: previousSheet)
						self.songService.previousSheet()
						self.update()
						if let indexPath = self.songService.indexPathForPreviousSheet() {
							self.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
						}
					})
					
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
								if let selectedSheet = self.songService.selectedSong?.selectedSheet {
									self.display(sheet: selectedSheet)
								}
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
								if let selectedSheet = self.songService.selectedSong?.selectedSheet {
									self.display(sheet: selectedSheet)
								}
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
	
	func externalDisplayDidChange(_ notification: Notification) {
		scaleFactor = 1
		updateSheetDisplayersRatios()
		if let selectedSheet = songService.selectedSong?.selectedSheet {
			display(sheet: selectedSheet)
		}
	}
	
	func databaseDidChange( _ notification: Notification) {
		songService.selectedSong?.selectedSheet = nil
		
		if songService.songs.count > 0 {
			for cluster in songService.songs.compactMap({ $0.cluster }) {
				CoreCluster.predicates.append("id", equals: cluster.id)
			}
			songService.songs = CoreCluster.getEntities().compactMap { SongObject(cluster: $0, displaySheet: display(sheet:)) }
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
	
	
	func display(sheet: Sheet) {
		
		for subview in sheetDisplayer.subviews {
			subview.removeFromSuperview()
		}
		
		// display background
		sheetDisplayer.isHidden = false
		sheetDisplayerPrevious.isHidden = true
		sheetDisplayerNext.isHidden = true
		
		sheetDisplayer.addSubview(SheetView.createWith(frame: sheetDisplayer.bounds, cluster: sheet.hasCluster, sheet: sheet, tag: songService.selectedTag, scaleFactor: scaleFactor, toExternalDisplay: true))
		
		if !isPlaying {
			// check if needs to play
			if let duration = songService.selectedSong?.cluster.duration, duration > 0 {
				startPlay()
			} else if let sheetTime = songService.selectedSong?.selectedSheet?.time, sheetTime > 0 {
				startPlay()
			}
		}
	}
	
	private func shutDownDisplayer() {
		stopPlay()
		for subView in sheetDisplayer.subviews {
			subView.removeFromSuperview()
		}
		if songService.songs.count > 0 {
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
			if let sheet = songService.selectedSong?.selectedSheet, let nextSheet = songService.nextSheet(select: false) {
				let currentSheetView = SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.selectedSong?.cluster, sheet: sheet, tag: songService.selectedTag, scaleFactor: scaleFactor)
				let nextSheetView = SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.getSongForNextSheet()?.cluster, sheet: nextSheet, tag: songService.nextTag, scaleFactor: scaleFactor)
				
				currentSheetView.frame = CGRect(
					x: sheetDisplayer.bounds.minX,
					y: sheetDisplayer.bounds.minY,
					width: sheetDisplayer.bounds.width,
					height: sheetDisplayer.bounds.height)
				
				nextSheetView.frame = CGRect(
					x: UIScreen.main.bounds.width,
					y: sheetDisplayer.bounds.minY,
					width: sheetDisplayer.bounds.width,
					height: sheetDisplayer.bounds.height) // set the view
				
				nextSheetView.clipsToBounds = true
				currentSheetView.clipsToBounds = true
				
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
			
			if let sheet = songService.selectedSong?.selectedSheet, let previousSheet = songService.previousSheet(select: false) {
				
				sheetDisplayerNext.isHidden = Int(sheet.position) == ((songService.selectedSong?.sheets.count ?? 0) - 1) ? true : false
				sheetDisplayerPrevious.isHidden = Int(sheet.position) == 0 ? true : false
				
					// current sheet
					// current sheet, move to left
				let currentSheetView = SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.selectedSong?.cluster, sheet: sheet, tag: songService.selectedTag, scaleFactor: scaleFactor)
					let previousSheetView = SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.getSongForPreviousSheet()?.cluster, sheet: previousSheet, tag: songService.previousTag, scaleFactor: scaleFactor)
					
					currentSheetView.frame = CGRect(
						x: sheetDisplayer.frame.minX,
						y: sheetDisplayer.bounds.minY,
						width: sheetDisplayer.bounds.width,
						height: sheetDisplayer.bounds.height)
					
					previousSheetView.frame = CGRect(
						x: -UIScreen.main.bounds.width,
						y: self.sheetDisplayer.bounds.minY,
						width: sheetDisplayer.bounds.width,
						height: sheetDisplayerPrevious.bounds.height) // set the view
					
					currentSheetView.clipsToBounds = true
					previousSheetView.clipsToBounds = true
					
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

	private func updateTime() {
		if let displayTimeTag = songService.selectedTag?.displayTime, displayTimeTag {
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
		if let sheet = songService.selectedSong?.selectedSheet {
			display(sheet: sheet)
		}
	}
	
	
	// MARK - player
	
	private func startPlay() {
		if let time = songService.selectedSong?.cluster.duration {
			isPlaying = true
			playerTimer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(swipeAutomatically), userInfo: nil, repeats: true)
		}
		
		// else if sheet has time (mp3 song)
		else if let time = songService.selectedSong?.selectedSheet?.time, time > 0 {
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
