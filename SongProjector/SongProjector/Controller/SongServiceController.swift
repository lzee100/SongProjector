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
	@IBOutlet var mixerContainerView: UIView!
	@IBOutlet var moveUpDownSection: UIView!
	
	@IBOutlet var sheetDisplayerSwipeViewTop: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerSwipeViewHeight: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerRatioConstraint: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerPreviousRatioConstraint: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerNextRatioConstraint: NSLayoutConstraint!
	@IBOutlet var moveUpDownSectionTopConstraint: NSLayoutConstraint!
	@IBOutlet var mixerTopStackViewConstraint: NSLayoutConstraint!
	@IBOutlet var mixerTopSuperViewConstraint: NSLayoutConstraint!

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
	private var isMixerVisible = false
	
	private var songService: SongService!
	
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
			newSongServiceController.selectedClusters = songService.songs.compactMap ({ $0.cluster })
		}
		if let controller = segue.destination as? UINavigationController, let songsController = controller.viewControllers.first as? SongsController {
			songsController.delegate = self
		}
		
		if let controller = segue.destination as? TestView {
			controller.songService = songService
		}
		
	}
	
	
	
	// MARK: UITableViewDelegate Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView == tableViewClusters {
			return songService.songs.count
		} else {
			if let selectedSection = songService.selectedSection {
				return songService.songs[selectedSection].sheets.count
			} else {
				return 0
			}
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		if tableView == tableViewClusters {
			let cell = tableViewClusters.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
			if let cell = cell as? BasicCell {
				cell.setup(title: songService.songs[indexPath.row].cluster.title, icon: Cells.songIcon)
				cell.selectedCell = songService.selectedSection == indexPath.row
			}
			return cell
		} else {
			
			let sheet = songService.songs[songService.selectedSection!].sheets[indexPath.row]
			let cell = tableViewSheets.dequeueReusableCell(withIdentifier: Cells.basicCellid, for: indexPath)
			let title: String?
			if let currentSheet = sheet as? SheetTitleContentEntity {
				title = currentSheet.isEmptySheet ? Text.Sheet.emptySheetTitle : currentSheet.title
			} else {
				title = sheet.title
			}
			if let cell = cell as? BasicCell {
				cell.setup(title: title, icon: Cells.sheetIcon)
				cell.selectedCell = songService.selectedSheet?.id == sheet.id
			}
			return cell
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView == tableViewClusters {
			let hasReselectedCurrentSong = songService.selectedSection == indexPath.row
			songService.selectedSection = hasReselectedCurrentSong ? nil : indexPath.row
			let selectedSong = songService.songs[indexPath.row]
			if selectedSong != songService.selectedSong {
				songService.selectedSheet = songService.songs[indexPath.row].sheets.first
			} else {
				songService.selectedSong = nil
				songService.selectedSheet = nil
				shutDownDisplayer()
			}
			
		} else {
			if songService.isPlaying || songService.isAnimating {
				return
			}
			let selectedSheet = songService.songs[songService.selectedSection!].sheets[indexPath.row]
			let previousSelected = songService.selectedSheet
			let isEqual = selectedSheet.isEqualTo(previousSelected)
			songService.selectedSheet = isEqual ? nil : selectedSheet
		}
		update()
	}
	
	
	
	// MARK: NewSongServiceDelegate Functions
	
	func didFinishSongServiceSelection(clusters: [Cluster], completion: () -> Void) {
		songService.songs = clusters.compactMap { SongObject(cluster: $0) }
		completion()
	}

	
	
	// MARK: SongsControllerDelegate Functions
	
	func didSelectClusters(_ clusters: [Cluster]) {
		songService.songs = clusters.map({ SongObject(cluster: $0) })
	}

	
	
	// MARK: - Private Functions
	
	private func setup() {
		
		songService = SongService(swipeLeft: swipeAutomatically, displaySheet: display(sheet:), shutDownBeamer: shutDownDisplayer)
		view.backgroundColor = themeWhiteBlackBackground
		songService.songs = CoreCluster.getEntities().compactMap { SongObject(cluster: $0) }
		swipeUpDownImageView.image = #imageLiteral(resourceName: "More")
		swipeUpDownImageView.tintColor = themeHighlighted
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
		
		leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		
		leftSwipe.direction = .left
		rightSwipe.direction = .right
		
		sheetDisplaySwipeView.addGestureRecognizer(leftSwipe)
		sheetDisplaySwipeView.addGestureRecognizer(rightSwipe)
		
		let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGestureUpDown))
		let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGestureUpDown))
		downSwipe.direction = .down
		upSwipe.direction = .up
		moveUpDownSection.addGestureRecognizer(downSwipe)
		moveUpDownSection.addGestureRecognizer(upSwipe)
		
		tableViewClusters.register(cell: Cells.basicCellid)
		tableViewSheets.register(cell: Cells.basicCellid)
		
		update()
		
	}
	
	private func update(scroll: Bool = false) {
		tableViewClusters.reloadData()
		tableViewClusters.setNeedsDisplay()
		tableViewSheets.reloadData()
		tableViewSheets.setNeedsDisplay()
		if scroll, let row = songService.selectedSong?.sheets.index(where: { $0.id == songService.selectedSheet?.id }), tableViewSheets.numberOfRows(inSection: 0) - 1 >= row {
				self.tableViewSheets.scrollToRow(at: IndexPath(row: Int(row), section: 0), at: .middle, animated: true)
		}
	}
	
	private func display(sheet: Sheet) {
		for subview in sheetDisplayer.subviews {
			subview.removeFromSuperview()
		}
		for subview in sheetDisplayerPrevious.subviews {
			subview.removeFromSuperview()
		}
		for subview in sheetDisplayerNext.subviews {
			subview.removeFromSuperview()
		}
		
		let nextPreviousScaleFactor: CGFloat = sheetDisplayerNext.bounds.height / sheetDisplayer.bounds.height
		
		sheetDisplayer.addSubview(SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.selectedSong?.cluster, sheet: sheet, tag: songService.selectedTag, scaleFactor: scaleFactor, toExternalDisplay: true))
		sheetDisplayer.isHidden = false
		
		if let sheetNext = songService.nextSheet(select: false) {
			sheetDisplayerNext.isHidden = false
			sheetDisplayerNext.addSubview(SheetView.createWith(frame: sheetDisplayerNext.bounds, cluster: songService.getSongForNextSheet()?.cluster, sheet: sheetNext, tag: songService.nextTag, scaleFactor: nextPreviousScaleFactor))
		} else {
			sheetDisplayerNext.isHidden = true
		}
		if let sheetPrevious = songService.previousSheet(select: false) {
			sheetDisplayerPrevious.isHidden = false
			sheetDisplayerPrevious.addSubview(SheetView.createWith(frame: sheetDisplayerPrevious.bounds, cluster: songService.getSongForPreviousSheet()?.cluster, sheet: sheetPrevious, tag: songService.previousTag, scaleFactor: nextPreviousScaleFactor))
		} else {
			sheetDisplayerPrevious.isHidden = true
		}
		
	}
	
	private func shutDownDisplayer() {
		for subView in sheetDisplayer.subviews {
			subView.removeFromSuperview()
		}
		if songService.songs.count > 0 {
			sheetDisplayer.isHidden = true
			sheetDisplayerPrevious.isHidden = true
			sheetDisplayerNext.isHidden = true
		}
		if let externalDisplayWindow = externalDisplayWindow {
			let view = UIView(frame: externalDisplayWindow.frame)
			view.backgroundColor = .black
			externalDisplayWindow.addSubview(view)
		}
	}
	
	@objc private func respondToSwipeGesture(_ sender: UISwipeGestureRecognizer, automatically: Bool = false) {
		switch sender.direction {
		case .right:
			if !automatically && songService.isPlaying {
				return
			}

			if let previousSheet = songService.previousSheet(select: false) {
				self.swipeAnimationIsActive = true
				self.display(sheet: previousSheet)
				animateSheetsWith(.right){
					self.swipeAnimationIsActive = false
					self.songService.previousSheet()
					self.update(scroll: true)
				}
			}
		case .left:
			if let nextSheet = songService.nextSheet(select: false) {
				
				self.swipeAnimationIsActive = true
				self.display(sheet: nextSheet)
				
				guard !songService.isPlaying && displayMode != .mixer else {
					songService.nextSheet()
					self.update(scroll: true)
					return
				}
				
				animateSheetsWith(.left) {
					self.swipeAnimationIsActive = false
					self.songService.nextSheet()
					self.update(scroll: true)
				}
				
			} else {
				// don't go to next song but play first sheet again
				if songService.isAnimating {
					swipeAnimationIsActive = true
					animateSheetsWith(.left, completion: {
						self.swipeAnimationIsActive = false
						self.songService.selectedSheet = self.songService.selectedSong?.sheets.first
						if let sheet = self.songService.selectedSong?.sheets.first {
							self.display(sheet: sheet)
						}
					})
					return
				}
			}
		default:
			break
		}
	}
	
	@objc private func respondToSwipeGestureUpDown(_ sender: UISwipeGestureRecognizer) {
		switch sender.direction {
		case .up:
			print("up")
			if isMixerVisible { // SHOW MIXER
				
				// move sheets up
				sheetDisplayerSwipeViewTop.constant = 0
				moveUpDownSectionTopConstraint.constant = 0
				mixerTopSuperViewConstraint.isActive = false
				mixerTopStackViewConstraint.isActive = true
				
				
				
				UIView.animate(withDuration: 0.3, animations: {
					self.view.layoutIfNeeded()
				}, completion: { (bool) in
					self.mixerContainerView.subviews.first?.removeFromSuperview()
					self.isMixerVisible = false
					self.displayMode = .normal
					self.isAnimatingUpDown = false
				})
			}
		case .down:
			print("down")
			
			if !isMixerVisible { // SHOW MIXER

				let mixerView = MixerView(frame: CGRect(x: 0, y: 0, width: mixerContainerView.bounds.width, height: mixerContainerView.bounds.height + 100))
				mixerContainerView.addSubview(mixerView)
				view.layoutIfNeeded()

				// move sheets up
				moveUpDownSectionTopConstraint.constant = sheetDisplaySwipeView.bounds.height + 100
				sheetDisplayerSwipeViewTop.constant = -sheetDisplaySwipeView.bounds.height
				mixerTopSuperViewConstraint.isActive = true
				mixerTopStackViewConstraint.isActive = false
				
				
				
				UIView.animate(withDuration: 0.3, animations: {
					self.view.layoutIfNeeded()
				}, completion: { (bool) in
					self.isMixerVisible = true
					self.displayMode = .mixer
					self.isAnimatingUpDown = false
				})
			}
		default:
			break
		}
	}

	
	@IBAction func clearButtonPressed(_ sender: UIBarButtonItem) {
		
	}
	
	private func animateSheetsWith(_ direction : AnimationDirection, completion: @escaping () -> Void) {
		switch direction {
		case .left:

			if let sheet = songService.selectedSheet, let nextSheet = songService.nextSheet(select: false) {
				let currentSheetView = SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.selectedSong?.cluster, sheet: sheet, tag: songService.selectedTag, scaleFactor: scaleFactor, toExternalDisplay: true)
				
				let nextSheetView = SheetView.createWith(frame: sheetDisplayerNext.bounds, cluster: songService.getSongForNextSheet()?.cluster, sheet: nextSheet, tag: songService.nextTag, scaleFactor: sheetDisplayerNext.bounds.height / sheetDisplayer.bounds.height)
				
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
			
			if let sheet = songService.selectedSheet, let previousSheet = songService.previousSheet(select: false) {
				
//				sheetDisplayerNext.isHidden = position == numberOfSheets ? true : false
//				sheetDisplayerPrevious.isHidden = position == 0 ? true : false

				let currentSheetView = SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.selectedSong?.cluster, sheet: sheet, tag: songService.selectedTag, scaleFactor: scaleFactor,  toExternalDisplay: true)
				
				let previousSheetView = SheetView.createWith(frame: sheetDisplayerPrevious.bounds, cluster: songService.getSongForPreviousSheet()?.cluster, sheet: previousSheet, tag: songService.previousTag, scaleFactor: sheetDisplayerNext.bounds.height / sheetDisplayer.bounds.height)
				
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
				sheetDisplayerNext.isHidden = songService.nextSheet(select: false) == nil
				
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
	
	
	func databaseDidChange( _ notification: Notification) {
		songService.selectedSheet = nil
		songService.selectedSection = nil
		
		if songService.songs.count > 0 {
			for cluster in songService.songs.compactMap({ $0.cluster }) {
				CoreCluster.predicates.append("id", equals: cluster.id)
			}
			songService.songs = CoreCluster.getEntities().compactMap { SongObject(cluster: $0) }
		}
	}
	
	func externalDisplayDidChange(_ notification: Notification) {
		scaleFactor = 1
		updateSheetDisplayersRatios()
		if let sheet = songService.selectedSheet {
			display(sheet: sheet)
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
	
	func swipeAutomatically() {
		respondToSwipeGesture(self.leftSwipe, automatically: true)
	}
	
	private func startPlay() {
		isPlaying = true
		
		// is cluster has time (advertisement)
		if let time = songService.selectedSong?.cluster.time {
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
		else if let time = songService.selectedSheet?.time, time > 0 {
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
