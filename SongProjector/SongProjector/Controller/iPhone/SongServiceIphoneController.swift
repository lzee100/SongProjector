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
import GoogleSignIn

class SongServiceIphoneController: ChurchBeamViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, SongsControllerDelegate {
    
	
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
    @IBOutlet var swipeLineLeftHeightConstraint: NSLayoutConstraint!
    @IBOutlet var swipeLineRightHeightConstraint: NSLayoutConstraint!
    
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
	
	
	// MARK: - Properties
	
	var requesterId: String {
		return "SongServiceIphoneController"
	}
	var songServiceSettings: VSongServiceSettings?
	var songsPerSection: [[VCluster]]?
	var songsPerSectionWithComents: [[Any]]?
	var previewCluster: VCluster?

	// MARK: Private Properties
	
	private var newSheetDisplayerSwipeViewTopConstraint: NSLayoutConstraint?
	
	// new try
	
	private var songService: SongService!
	private var isAnimatingUpDown = false
	private var displayMode: displayModeTypes = .normal
	private var sheetDisplayerInitialFrame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
	private var sheetDisplayerSwipeViewInitialHeight: CGFloat = 0
	private var isPlaying = false
	private var leftSwipe = UISwipeGestureRecognizer()
	private var viewToBeamer: SheetView?
	private var emptySheet: VSheet?
	private var model: TempClustersModel?
    private var canPlay: Bool = true
    
    override var requesters: [RequesterBase] {
        return [UniversalClusterFetcher, SongServicePlayDateFetcher]
    }
    
	// MARK: - Functions
	
	// MARK: UIViewController Functions
    
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GoogleActivityFetcher.fetch(force: true)
        UniversalClusterFetcher.initialFetch()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		update()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let controller = segue.destination as? UINavigationController, let newSongServiceIphoneController = controller.viewControllers.first as? NewSongServiceIphoneController {
			newSongServiceIphoneController.delegate = self
			newSongServiceIphoneController.clusterModel = model ?? TempClustersModel()
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
			if songService.selectedSection == section {
				return songService.songs[section].sheets.count == 1 ? 0 : songService.songs[section].sheets.count
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
				cell.setup(title: AppText.NewSongService.noSelectedSongs)
				cell.selectedCell = false
				return cell
			}
			let title: String?
			if let sheet = currentSheet as? VSheetTitleContent {
				title = sheet.isEmptySheet ? AppText.Sheet.emptySheetTitle : sheet.title
			} else {
				title = currentSheet.title
			}
			cell.setup(title: title)
			cell.isInnerCell = true
            cell.selectionColor = .softBlueGrey
			cell.selectedCell = songService.selectedSheet?.id == currentSheet.id
			
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if SoundPlayer.isPlaying {
			return
		}
		let currentSheet = songService.songs[indexPath.section].sheets[indexPath.row]
		songService.selectedSheet = songService.selectedSheet == currentSheet ? nil : currentSheet
		update()
	}
	
	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let song = songService.songs[section]
		let firstClusters = model?.sectionedClusterOrComment.compactMap({ $0.first?.cluster })
		let hasHeader = firstClusters?.contains(entity: songService.songs[section].cluster) ?? false
		
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: SongHeaderView.identifier) as? SongHeaderView else { return nil }
        
        view.style()
        view.sectionButton.add {
            self.didSelectSection(section: section)
        }
        view.actionButton.add {
            self.didSelectPianoInSection(section: section)
        }
		if let model = model, let songServiceSetting = model.songServiceSettings, hasHeader {
			if let index = model.sectionedClusterOrComment.firstIndex(where: { sectionClusterOrComment in
				sectionClusterOrComment.compactMap({ $0.cluster }).contains(entity: song.cluster)
			}) {
				view.set(sectionHeader: songServiceSetting.sections[index].title ?? "")
			}
		}
		let isSelected = section == songService.selectedSection
		view.setup(title: song.cluster.title, isSelected: isSelected, hasPianoSolo: song.cluster.hasPianoSolo)
        let isPlaying = SoundPlayer.isPianoOnlyPlaying && SoundPlayer.isPlaying && SoundPlayer.song?.id == song.cluster.id
        view.setPianoAction(isPlaying: isPlaying)
		return view
	}
	
	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		let firstClusters = model?.sectionedClusterOrComment.compactMap({ $0.first?.cluster })
		let hasHeader = firstClusters?.contains(entity: songService.songs[section].cluster) ?? false
        return SongHeaderView.preferredHeight(hasSection: hasHeader)
	}
	
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.style(cell, forRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        tableView.styleHeaderView(view: view)
    }
	
	
	// MARK: NewSongServiceDelegate Functions
	
	func finishedSelection(_ model: TempClustersModel) {
		self.model = model
		let clusters = model.clusters.compactMap({ $0.cluster })
		if clusters.count != 0 {
			self.songService.songs = clusters.map({ SongObject(cluster: $0) })
		} else {
			self.songService.songs = model
				.sectionedClusterOrComment
				.flatMap({ $0 })
				.compactMap({ $0.cluster })
				.map({ SongObject(cluster: $0) })
		}
        if self.songService.songs.count > 0 {
            SongServicePlayDateFetcher.fetch()
        }
		update()
	}
	
	
	
	// MARK: Fetcher Functions
    
    override func handleRequestFinish(requesterId: String, result: Any?) {
        if requesterId == SongServicePlayDateFetcher.id, let playEntity = result as? [VSongServicePlayDate] {
            canPlay = playEntity.last?.allowedToPlay ?? true
        }
        update()
    }
    
    
	
	// MARK: - Private Functions
	
	private func setup() {
        songService = SongService(delegate: self)
		navigationController?.title = AppText.SongService.title
		title = AppText.SongService.title
		mixerHeightConstraint.constant = 0
		
		new.title = AppText.Actions.add
        new.tintColor = themeHighlighted
        swipeUpDownImageView.tintColor = .softBlueGrey
		view.backgroundColor = themeWhiteBlackBackground
		emptyViewTableView.backgroundColor = themeWhiteBlackBackground
		moveUpDownSection.backgroundColor = themeWhiteBlackBackground
        swipeLineLeft.backgroundColor = .grey3
        swipeLineRight.backgroundColor = .grey3
        swipeLineRightHeightConstraint.constant = 1 / 3
        swipeLineLeftHeightConstraint.constant = 1 / 3
		swipeLineLeftWidthConstraint.constant = UIScreen.main.bounds.width * 0.35
		swipeLineRightWidthConstraint.constant = UIScreen.main.bounds.width * 0.35
		
		NotificationCenter.default.addObserver(forName: .externalDisplayDidChange, object: nil, queue: nil, using: externalDisplayDidChange)
        
        NotificationCenter.default.addObserver(forName: .didSubmitSongServiceSettings, object: nil, queue: .main) { (_) in
            self.songService = SongService(delegate: self)
            self.model = nil
        }

        NotificationCenter.default.addObserver(forName: .googleCalendarNotAuthenticated, object: nil, queue: .main) { [weak self] (_) in
            self?.present(Storyboard.MainStoryboard.instantiateViewController(identifier: SignInCalendarController.nav), animated: true)
        }
        
        NotificationCenter.default.addObserver(forName: .universalClusterSubmitterFailed, object: nil, queue: .main) { [weak self] (not) in
            if let error = not.object as? RequestError {
                self?.show(error)
            }
        }
		
		NotificationCenter.default.addObserver(
			forName: .dataBaseDidChange,
			object: nil,
			queue: nil,
			using: databaseDidChange)

		
		let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipeManually))
		let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipeManually))
		
		upSwipe.direction = .up
		downSwipe.direction = .down
		
		moveUpDownSection.addGestureRecognizer(upSwipe)
		moveUpDownSection.addGestureRecognizer(downSwipe)
		
		leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipeManually))
		let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipeManually))

		leftSwipe.direction = .left
		rightSwipe.direction = .right
		
		sheetDisplayerNextLeftConstraint.constant = UIScreen.main.bounds.width
		sheetDisplayerPreviousRightConstraint.constant = -UIScreen.main.bounds.width
		
		sheetDisplaySwipeView.addGestureRecognizer(leftSwipe)
		sheetDisplaySwipeView.addGestureRecognizer(rightSwipe)
		
		tableView.register(cell: Cells.basicCellid)
        tableView.register(header: SongHeaderView.identifier)
		updateSheetDisplayersRatios()
		sheetDisplayerInitialFrame = sheetDisplayer.bounds
		sheetDisplayerSwipeViewInitialHeight = sheetDisplaySwipeViewCustomHeightConstraint?.constant ?? sheetDisplaySwipeView.bounds.height
		
		if let previewCluster = previewCluster {
			songService.songs = [SongObject(cluster: previewCluster)]
			navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppText.Actions.cancel, style: .plain, target: self, action: #selector(close))
		}
        
		update()
		
	}
	
    override func update() {
        update(scroll: false)
    }
    
	private func update(scroll: Bool = false) {
		if songService.selectedSong == nil {
			shutDownDisplayer()
		}
		tableView.reloadData()
		tableView.setNeedsDisplay()
		if scroll {
			if let section = songService.selectedSection, let row = songService.selectedSheet?.position, songService.selectedSong?.sheets.count ?? 0 > 1 {
				self.tableView.scrollToRow(at: IndexPath(row: Int(row), section: section), at: .middle, animated: true)
			}
		}
    }
    
    private func didSelectSection(section: Int) {
        guard canPlay else {
            let alert = UIAlertController(title: nil, message: AppText.SongService.warnCannotPlay, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: AppText.Actions.ok, style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        SoundPlayer.stop()
        songService.selectedSong = songService.selectedSection == section ? nil : songService.songs[section]
        songService.selectedSection = songService.selectedSection == section ? nil : section
        
        update()
    }
	
	private func didSelectPianoInSection(section: Int) {
		
		shutDownDisplayer()
		
		if !SoundPlayer.isPianoOnlyPlaying {
			
			songService.selectedSong = nil
			songService.selectedSection = nil

			let song = songService.songs[section].cluster
			SoundPlayer.play(song: song, pianoSolo: true)
		} else {
			songService.selectedSong = nil
			songService.selectedSection = nil
		}

		update()

	}
	
	@objc private func didSwipeManually(_ sender: UISwipeGestureRecognizer) {
		respondToSwipeGesture(sender, automatically: false)
	}

	
	private func respondToSwipeGesture(_ sender: UISwipeGestureRecognizer, automatically: Bool = false) {
		
		if sender.view == sheetDisplaySwipeView {
			switch sender.direction {
			
			case .left:
				if !automatically && songService.isPlaying {
					return
				}
				if let nextSheet = songService.nextSheet(select: false) {
					swipeAnimationIsActive = true
					self.display(sheet: nextSheet)
					
					guard displayMode != .mixer else {
						self.swipeAnimationIsActive = false
						self.songService.nextSheet()
						self.update(scroll: true)
						return
					}
					
					animateSheetsWith(.left, completion: {
						self.swipeAnimationIsActive = false
						self.songService.nextSheet()
						self.update(scroll: true)
					})
					
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
				
			case .right:
				if songService.isPlaying {
					return
				}
				
				if let previousSheet = songService.previousSheet(select: false) {
					swipeAnimationIsActive = true
					animateSheetsWith(.right, completion: {
						self.swipeAnimationIsActive = false
						self.display(sheet: previousSheet)

						self.songService.previousSheet()
						self.update(scroll: true)
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
								if let selectedSheet = self.songService.selectedSheet {
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
								if let selectedSheet = self.songService.selectedSheet {
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
							newSheetDisplayerSwipeViewTopConstraint = NSLayoutConstraint(item: sheetDisplaySwipeView!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: -sheetDisplayerSwipeViewInitialHeight)
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
		updateSheetDisplayersRatios()
        if let selectedSheet = songService.selectedSheet, songService.selectedSong != nil, externalDisplayWindow != nil {
			display(sheet: selectedSheet)
		}
	}
	
	func databaseDidChange( _ notification: Notification) {
        songService = SongService(delegate: self)
	}
	
	func updateSheetDisplayersRatios() {
		sheetDisplayerRatioConstraint.isActive = false
		sheetDisplayerPreviousRatioConstraint.isActive = false
		sheetDisplayerNextRatioConstraint.isActive = false
		
		sheetDisplayerSwipeViewHeight.isActive = false
		
		if let sheetDisplaySwipeViewCustomHeightConstraint = sheetDisplaySwipeViewCustomHeightConstraint {
			sheetDisplaySwipeView.removeConstraint(sheetDisplaySwipeViewCustomHeightConstraint)
		}
        sheetDisplaySwipeViewCustomHeightConstraint = NSLayoutConstraint(item: sheetDisplaySwipeView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: UIScreen.main.bounds.width * externalDisplayWindowRatio)

		sheetDisplaySwipeView.addConstraint(sheetDisplaySwipeViewCustomHeightConstraint!)
		
		if let customSheetDisplayerRatioConstraint = customSheetDisplayerRatioConstraint {
			sheetDisplayer.removeConstraint(customSheetDisplayerRatioConstraint)
		}
		customSheetDisplayerRatioConstraint = NSLayoutConstraint(item: sheetDisplayer!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: sheetDisplayer, attribute: NSLayoutConstraint.Attribute.width, multiplier: externalDisplayWindowRatio, constant: 0)
		sheetDisplayer.addConstraint(customSheetDisplayerRatioConstraint!)
		sheetDisplayer.layoutIfNeeded()
		sheetDisplayer.layoutSubviews()
		
		if let customSheetDisplayerPreviousRatioConstraint = customSheetDisplayerPreviousRatioConstraint {
			sheetDisplayer.removeConstraint(customSheetDisplayerPreviousRatioConstraint)
		}
		customSheetDisplayerPreviousRatioConstraint = NSLayoutConstraint(item: sheetDisplayerPrevious!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: sheetDisplayerPrevious, attribute: NSLayoutConstraint.Attribute.width, multiplier: externalDisplayWindowRatio, constant: 0)
		sheetDisplayerPrevious.addConstraint(customSheetDisplayerPreviousRatioConstraint!)
		
		if let customSheetDisplayerNextRatioConstraint = customSheetDisplayerNextRatioConstraint {
			sheetDisplayer.removeConstraint(customSheetDisplayerNextRatioConstraint)
		}
		customSheetDisplayerNextRatioConstraint = NSLayoutConstraint(item: sheetDisplayerNext!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: sheetDisplayerNext, attribute: NSLayoutConstraint.Attribute.width, multiplier: externalDisplayWindowRatio, constant: 0)
		sheetDisplayerNext.addConstraint(customSheetDisplayerNextRatioConstraint!)
		
		view.layoutIfNeeded()
		view.layoutSubviews()
		
	}
	
	func display(sheet: VSheet) {
		for subview in sheetDisplayer.subviews {
			subview.removeFromSuperview()
		}
		
		// display background
		sheetDisplayer.isHidden = false
		sheetDisplayerPrevious.isHidden = true
		sheetDisplayerNext.isHidden = true
		
        sheetDisplayer.addSubview(SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.selectedSong?.cluster, sheet: sheet, theme: songService.selectedTheme, scaleFactor: getScaleFactor(width: sheetDisplayer.bounds.width), toExternalDisplay: true))
        updateTime()
	}
	
	private func shutDownDisplayer() {
		
		for subView in sheetDisplayer.subviews {
			subView.removeFromSuperview()
		}
		if songService.songs.count > 0 {
			sheetDisplayer.isHidden = true
		}
		if let externalDisplayWindow = externalDisplayWindow {
			let view = UIView(frame: externalDisplayWindow.frame)
			view.backgroundColor = .blackColor
			externalDisplayWindow.addSubview(view)
			viewToBeamer?.removeFromSuperview()
		}
        displayTimeTimer.invalidate()
	}
	
	private func animateSheetsWith(_ direction : AnimationDirection, isNextOrPreviousCluster: Bool = false, completion: @escaping () -> Void) {
		switch direction {
		case .left:
						
			// current sheet
			// current sheet, move to left
			if let sheet = songService.selectedSheet, let nextSheet = songService.nextSheet(select: false) {
                let currentSheetView = SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.selectedSong?.cluster, sheet: sheet, theme: songService.selectedTheme, scaleFactor: getScaleFactor(width: sheetDisplayer.bounds.width))
				let nextSheetView = SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.getSongForNextSheet()?.cluster, sheet: nextSheet, theme: songService.nextTheme, scaleFactor: getScaleFactor(width: sheetDisplayer.bounds.width))
				
				currentSheetView.frame = CGRect(
					x: sheetDisplayer.frame.minX,
					y: sheetDisplaySwipeView.frame.minY,
					width: sheetDisplayer.bounds.width,
					height: sheetDisplayer.bounds.height)
				
				nextSheetView.frame = CGRect(
					x: UIScreen.main.bounds.width,
					y: sheetDisplaySwipeView.frame.minY,
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
						y: self.sheetDisplaySwipeView.frame.minY,
						width: self.sheetDisplayerPrevious.frame.width,
						height: self.sheetDisplayerPrevious.bounds.height)
					
					nextSheetView.frame = CGRect(
						x: self.sheetDisplayer.frame.minX,
						y: self.sheetDisplaySwipeView.frame.minY,
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
			
			if let sheet = songService.selectedSheet, let previousSheet = songService.previousSheet(select: false) {
				
				sheetDisplayerNext.isHidden = Int(sheet.position) == ((songService.selectedSong?.sheets.count ?? 0) - 1) ? true : false
				sheetDisplayerPrevious.isHidden = Int(sheet.position) == 0 ? true : false
				
					// current sheet
					// current sheet, move to left
                let currentSheetView = SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.selectedSong?.cluster, sheet: sheet, theme: songService.selectedTheme, scaleFactor: getScaleFactor(width: sheetDisplayer.bounds.width))
					let previousSheetView = SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.getSongForPreviousSheet()?.cluster, sheet: previousSheet, theme: songService.previousTheme, scaleFactor: getScaleFactor(width: sheetDisplayer.bounds.width))
					
					currentSheetView.frame = CGRect(
						x: sheetDisplayer.frame.minX,
						y: sheetDisplaySwipeView.frame.minY,
						width: sheetDisplayer.bounds.width,
						height: sheetDisplayer.bounds.height)
					
					previousSheetView.frame = CGRect(
						x: -UIScreen.main.bounds.width,
						y: self.sheetDisplaySwipeView.frame.minY,
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
							y: self.sheetDisplaySwipeView.frame.minY,
							width: self.sheetDisplayer.bounds.width,
							height: self.sheetDisplayer.bounds.height)
						
						currentSheetView.frame = CGRect(
							x: UIScreen.main.bounds.width,
							y: self.sheetDisplaySwipeView.frame.minY,
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
        if let displayTimeTheme = songService.selectedTheme?.displayTime ?? songService.selectedSong?.clusterTheme?.displayTime, displayTimeTheme {
			let date = Date()
			let seconds = Calendar.current.component(.second, from: date)
			let remainder = 60 - seconds
			let fireDate = date.addingTimeInterval(.seconds(Double(remainder)))
            displayTimeTimer.invalidate()
			displayTimeTimer = Timer(fireAt: fireDate, interval: 60, target: self, selector: #selector(updateScreen), userInfo: nil, repeats: true)
			RunLoop.main.add(displayTimeTimer, forMode: RunLoop.Mode.common)
		} else {
			displayTimeTimer.invalidate()
		}
	}
	
	@objc private func updateScreen() {
		if let sheet = songService.selectedSheet {
			display(sheet: sheet)
		}
	}
	
	@objc func swipeAutomatically() {
		self.respondToSwipeGesture(self.leftSwipe, automatically: true)
	}
	
	@objc private func close() {
		self.dismiss(animated: true)
	}
	
}

extension SongServiceIphoneController: SongServiceDelegate {
    
    func countDown(value: Int) {
        guard value > 0 else {
            sheetDisplayer.subviews.compactMap({ $0 as? CountDownView }).forEach({ $0.removeFromSuperview() })
            return
        }
        
        if let countDownView = sheetDisplayer.subviews.compactMap({ $0 as? CountDownView }).first {
            countDownView.countDownLabel.text = value.stringValue
        } else {
            let countDownView = CountDownView(frame: sheetDisplayer.bounds)
            countDownView.countDownLabel.text = value.stringValue
            sheetDisplayer.addSubview(countDownView)
            sheetDisplayer.topAnchor.constraint(equalTo: countDownView.topAnchor).isActive =  true
            sheetDisplayer.rightAnchor.constraint(equalTo: countDownView.rightAnchor).isActive =  true
            sheetDisplayer.bottomAnchor.constraint(equalTo: countDownView.bottomAnchor).isActive =  true
            sheetDisplayer.leftAnchor.constraint(equalTo: countDownView.leftAnchor).isActive =  true
        }
    }
    
    func swipeLeft() {
        swipeAutomatically()
    }
    
    func displaySheet(_ sheet: VSheet) {
        display(sheet: sheet)
    }
    
    func shutDownBeamer() {
        shutDownDisplayer()
    }
}
