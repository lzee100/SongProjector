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



class SongServiceController: ChurchBeamViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SongsControllerDelegate  {
	
	
	
	// MARK: - Properties
	
	@IBOutlet var sheetDisplaySwipeView: UIView!
	@IBOutlet var sheetDisplayerPrevious: UIView!
	@IBOutlet var sheetDisplayer: UIView!
	@IBOutlet var sheetDisplayerNext: UIView!
	@IBOutlet var swipeUpDownImageView: UIImageView!
	@IBOutlet var add: UIBarButtonItem!
	@IBOutlet var mixerContainerView: UIView!
	@IBOutlet var moveUpDownSection: UIView!
    @IBOutlet var songCollectionView: UICollectionView!
    
	@IBOutlet var sheetDisplayerSwipeViewTop: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerSwipeViewHeight: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerRatioConstraint: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerPreviousRatioConstraint: NSLayoutConstraint!
	@IBOutlet var sheetDisplayerNextRatioConstraint: NSLayoutConstraint!
	@IBOutlet var moveUpDownSectionTopConstraint: NSLayoutConstraint!
	@IBOutlet var mixerBottomToTopSwipeViewConstraint: NSLayoutConstraint!
    @IBOutlet var mixerTopStackViewConstraint: NSLayoutConstraint!
    @IBOutlet var sheetDisplayerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var songsCollectionViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet var songsCollectionViewRightConstraint: NSLayoutConstraint!
    
    var sheetDisplayerWipeViewEqualHeightConstraint: NSLayoutConstraint?
    var customSheetDisplayerRatioConstraint: NSLayoutConstraint?
	var customSheetDisplayerPreviousRatioConstraint: NSLayoutConstraint?
	var customSheetDisplayerNextRatioConstraint: NSLayoutConstraint?
	var sheetDisplaySwipeViewCustomHeightConstraint: NSLayoutConstraint?
	var swipeAnimationIsActive = false
    var softPianoPlayingSong: Cluster?
	
	// MARK: - Types
	
	private enum displayModeTypes {
		case small
		case normal
		case mixer
	}
    
    private enum SongServiceListItems {
        case sectionedCluster(section: String?, cluster: VCluster)
        case sheet(vsheet: VSheet)
        
        var isSection: Bool {
            switch self {
            case .sectionedCluster(cluster: _): return true
            default: return false
            }
        }
    }
    
    private struct InsertAction {
        let section: Int
        let items: Int
        let none: Bool
        
        var indexPaths: [IndexPath] {
            var index = 0
            var indexPaths: [IndexPath] = []
            repeat {
                indexPaths.append(IndexPath(row: index, section: section))
                index += 1
            } while index < items
            return indexPaths
        }
    }

	
	// MARK: - Private Properties
	
	private var newSheetDisplayerSwipeViewTopConstraint: NSLayoutConstraint?
	
	private var isAnimatingUpDown = false
	private var displayMode: displayModeTypes = .normal
	private var sheetDisplayerInitialFrame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
	private var sheetDisplayerSwipeViewInitialHeight: CGFloat = 0
	private var isPlaying = false
	private var leftSwipe = UISwipeGestureRecognizer()
	private var isMixerVisible = false
	private var model: TempClustersModel?
	
	private var songService: SongService!
    private var collectionViewItems: [SongServiceListItems] = []
    private var canPlay: Bool = true
    
    override var requesters: [RequesterBase] {
        return [SongServicePlayDateFetcher]
    }

	
	// MARK: - Functions
	
	// MARK: UIViewController Functions
    
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
        self.navigationController?.navigationBar.barStyle = .black
        self.setNeedsStatusBarAppearanceUpdate()
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SongServicePlayDateFetcher.fetch()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		update()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let controller = segue.destination as? UINavigationController, let songsController = controller.viewControllers.first as? SongsController {
			songsController.delegate = self
			songsController.tempClusterModel = model
		}
		if let controller = segue.destination as? TestView {
			controller.songService = songService
		}
	}
	
    
    // MARK: UICollectionView Functions
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionViewItems.count == 0 {
            return 0
        }
        let sections = collectionViewItems.filter({ $0.isSection }).count
        return sections == 0 ? 1 : sections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let index = collectionViewItems.firstIndex(where: { !$0.isSection }), max(index - 1, 0) == section {
            return collectionViewItems.filter({ !$0.isSection }).count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SheetCollectionCell.identitier, for: indexPath) as! SheetCollectionCell
        switch collectionViewItems.filter({ !$0.isSection })[indexPath.row] {
        case .sheet(vsheet: let sheet):
            cell.setupWith(cluster: songService.selectedSong?.cluster, sheet: sheet, theme: sheet.hasTheme ?? songService.selectedSong?.cluster.hasTheme(moc: moc), didDeleteSheet: nil, isDeleteEnabled: false, scaleFactor: getScaleFactor(width: getSheetSize().width))
            if sheet.id != songService.selectedSheet?.id {
                cell.styleDark()
            }
            cell.layer.cornerRadius = 10
            cell.clipsToBounds = true
        default: break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SongServiceHeaderCollectionReusableView.identifier, for: indexPath) as! SongServiceHeaderCollectionReusableView
        switch collectionViewItems.filter({ $0.isSection })[indexPath.section] {
        case .sectionedCluster(_, cluster: let cluster):
            headerView.data = cluster
            headerView.sectionBackgroundView.backgroundColor = cluster.id == songService.selectedSong?.cluster.id ? .softBlueGrey : .grey1
            headerView.pianoButton.add {
                self.shutDownDisplayer()
                
                if SoundPlayer.song?.id == cluster.id && SoundPlayer.isPianoOnlyPlaying {
                    self.songService.selectedSong = nil
                    self.songService.selectedSection = nil
                    SoundPlayer.stop()
                } else {
                    self.songService.selectedSong = nil
                    self.songService.selectedSection = nil

                    SoundPlayer.play(song: cluster, pianoSolo: true)
                }
                self.update(scroll: false)
            }
            if SoundPlayer.song?.id == cluster.id, SoundPlayer.isPianoOnlyPlaying {
                headerView.startPlay()
            } else {
                headerView.stopPlaying()
            }
            if cluster.hasPianoSolo {
                headerView.showPianoOption()
            }
            headerView.updatePianoButtonConstraints()
            headerView.setup(title: cluster.title ?? "Geen naam voor nummer") {
                
                guard self.canPlay else {
                    let alert = UIAlertController(title: nil, message: AppText.SongService.warnCannotPlay, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: AppText.Actions.ok, style: .default, handler: nil))
                    self.present(alert, animated: true)
                    return
                }
                if SoundPlayer.isPianoOnlyPlaying {
                    let pianoCluster = SoundPlayer.song
                    if let index = self.collectionViewItems.filter({ $0.isSection }).firstIndex(where: {
                        switch $0 {
                        case .sectionedCluster(section: _, cluster: let cluster):
                            return cluster.id == pianoCluster?.id
                        default: return false
                        }
                    }) {
                        if let view = self.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, at: IndexPath(row: 0, section: index)) as? SongServiceHeaderCollectionReusableView {
                            view.stopPlaying()
                        }
                    }
                    SoundPlayer.stop()
                }
                collectionView.performBatchUpdates({
                    if self.songService.selectedSong == nil || (self.songService.selectedSong != nil && self.songService.selectedSong?.cluster.id != cluster.id) {
                        if let selectedClusterId = self.songService.selectedSong?.cluster.id, selectedClusterId != cluster.id {
                            let sectionIndexSectioned = self.model?.sectionedClusterOrComment.flatMap({ $0 }).firstIndex(where: { $0.id == selectedClusterId })
                            let sectionIndexUnsectioned = self.model?.clusters.firstIndex(where: { $0.id == selectedClusterId })
                            if let sectionIndex = sectionIndexSectioned ?? sectionIndexUnsectioned  {
                                let endIndex = self.collectionViewItems.filter({ !$0.isSection }).count
                                var currentIndex = 0
                                var indexPaths: [IndexPath] = []
                                repeat {
                                    indexPaths.append(IndexPath(row: currentIndex, section: sectionIndex))
                                    currentIndex += 1
                                } while currentIndex < endIndex
                                self.songCollectionView.deleteItems(at: indexPaths)
                            }
                        }
                        self.songService.selectedSong = SongObject(cluster: cluster)
                        let inserted = self.refreshCollectionViewListItems()
                        self.songCollectionView.insertItems(at: inserted.indexPaths)
                    } else {
                        let endIndex = self.collectionViewItems.filter({ !$0.isSection }).count
                        var currentIndex = 0
                        var indexPaths: [IndexPath] = []
                        repeat {
                            indexPaths.append(IndexPath(row: currentIndex, section: indexPath.section))
                            currentIndex += 1
                        } while currentIndex < endIndex
                        self.songCollectionView.deleteItems(at: indexPaths)
                        self.songService.selectedSheet = nil
                        self.refreshCollectionViewListItems()
                    }
                }) { (completed) in
                    Queues.main.async {
                        if collectionView.numberOfItems(inSection: indexPath.section) != 0 {
                            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                        }
                    }
                    collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).compactMap({ $0 as? SongServiceHeaderCollectionReusableView }).forEach({ $0.setSelected(isSelected: false) })
                    if let selectedSongId = self.songService.selectedSong?.cluster.id {
                        collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).compactMap({ $0 as? SongServiceHeaderCollectionReusableView }).first(where: { ($0.data as? VCluster)?.id == selectedSongId })?.setSelected(isSelected: true)
                    }
                }
            }
        default: break
            
        }
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getSheetSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if view.bounds.height > view.bounds.width {
            return CGSize(width: collectionView.bounds.width, height: 100)
        }
        return CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if UIDevice.current.orientation.isPortrait {
            return UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        } else {
            return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        }
    }
    
	
	
	// MARK: UITableViewDelegate Functions
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 60
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		update()
	}
	
    
    override func handleRequestFinish(requesterId: String, result: Any?) {
        if requesterId == SongServicePlayDateFetcher.id, let playEntity = result as? [VSongServicePlayDate] {
            canPlay = playEntity.last?.allowedToPlay ?? true
        }
        update()

    }
    
    
	
	// MARK: SongsControllerDelegate Functions

	func finishedSelection(_ model: TempClustersModel) {
		self.model = model
		let clusters = model.clusters.compactMap({ $0.cluster })
		if clusters.count != 0 {
			self.songService.songs = clusters.map({ SongObject(cluster: $0) })
		} else {
			 self.songService.songs = model.sectionedClusterOrComment
				.flatMap({ $0 })
				.compactMap({ $0.cluster })
				.map({ SongObject(cluster: $0) })
		}
        if songService.songs.count > 0 {
            SongServicePlayDateFetcher.fetch()
        }
        self.update(scroll: true)
	}
	
	
	
	// MARK: - Private Functions
	
	private func setup() {
        songService = SongService(delegate: self)
		swipeUpDownImageView.image = #imageLiteral(resourceName: "More")
		swipeUpDownImageView.tintColor = themeHighlighted
		navigationController?.title = AppText.SongService.title
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = UIColor(hex: "2E2C2C")
        view.backgroundColor = UIColor(hex: "000000")
		sheetDisplayer.layer.cornerRadius = 4
		sheetDisplayerNext.layer.cornerRadius = 3
		sheetDisplayerPrevious.layer.cornerRadius = 3
        
        NotificationCenter.default.addObserver(forName: .didSubmitSongServiceSettings, object: nil, queue: .main) { (_) in
            self.songService = SongService(delegate: self)
            self.model = nil
        }
		
		add.title = AppText.Actions.add
        add.tintColor = themeHighlighted
		title = AppText.SongService.title
        songCollectionView.backgroundColor = UIColor(hex: "000000")
        moveUpDownSection.backgroundColor = UIColor(hex: "000000")
        songCollectionView.registerHeader(reusableView: SongServiceHeaderCollectionReusableView.identifier)
        songCollectionView.register(cell: SheetCollectionCell.identitier)
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        songCollectionView.collectionViewLayout = layout
        
        
        NotificationCenter.default.addObserver(forName: .externalDisplayDidChange, object: nil, queue: nil, using: externalDisplayDidChange)
//        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)

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
		
        rotated()
		update()
		
	}
    
    override func update() {
        super.update()
        UniversalClusterFetcher.initialFetch()
    }
	
	private func update(scroll: Bool = false) {
        refreshCollectionViewListItems()
        songCollectionView.reloadData()
	}
	
	private func display(sheet: VSheet) {
		for subview in sheetDisplayer.subviews {
			subview.removeFromSuperview()
		}
		for subview in sheetDisplayerPrevious.subviews {
			subview.removeFromSuperview()
		}
		for subview in sheetDisplayerNext.subviews {
			subview.removeFromSuperview()
		}
        
        if let selectedSong = songService.selectedSong, let section = songService.songs.firstIndex(of: selectedSong), let selectedSheet = songService.selectedSheet, let row = selectedSong.sheets.firstIndex(of: selectedSheet), songCollectionView.numberOfItems(inSection: section) > 0 {
            songCollectionView.scrollToItem(at: IndexPath(row: row, section: section), at: .centeredHorizontally, animated: true)
        }
		
        let nextPreviousScaleFactor: CGFloat = getScaleFactor(width: sheetDisplayerNext.bounds.width)
		
        sheetDisplayer.addSubview(SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.selectedSong?.cluster, sheet: sheet, theme: songService.selectedTheme, scaleFactor: getScaleFactor(width: sheetDisplayer.bounds.width), toExternalDisplay: true))
		sheetDisplayer.isHidden = false
		
		if let sheetNext = songService.nextSheet(select: false) {
			sheetDisplayerNext.isHidden = false
			sheetDisplayerNext.addSubview(SheetView.createWith(frame: sheetDisplayerNext.bounds, cluster: songService.getSongForNextSheet()?.cluster, sheet: sheetNext, theme: songService.nextTheme, scaleFactor: nextPreviousScaleFactor))
		} else {
			sheetDisplayerNext.isHidden = true
		}
		if let sheetPrevious = songService.previousSheet(select: false) {
			sheetDisplayerPrevious.isHidden = false
			sheetDisplayerPrevious.addSubview(SheetView.createWith(frame: sheetDisplayerPrevious.bounds, cluster: songService.getSongForPreviousSheet()?.cluster, sheet: sheetPrevious, theme: songService.previousTheme, scaleFactor: nextPreviousScaleFactor))
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
			view.backgroundColor = .blackColor
			externalDisplayWindow.addSubview(view)
		}
	}
    
    private func getSheetSize() -> CGSize {
        if view.bounds.height > view.bounds.width {
            return getSizeWith(height: nil, width: songCollectionView.bounds.width)
        }
        return getSizeWith(height: songCollectionView.bounds.height, width: nil)
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
			if isMixerVisible { // SHOW MIXER
				
				// move sheets up
				sheetDisplayerSwipeViewTop.constant = 0
				moveUpDownSectionTopConstraint.constant = 0
				mixerBottomToTopSwipeViewConstraint.isActive = false
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
			if !isMixerVisible { // SHOW MIXER

				let mixerView = MixerView(frame: CGRect(x: 0, y: 0, width: mixerContainerView.bounds.width, height: mixerContainerView.bounds.height + 100))
				mixerContainerView.addSubview(mixerView)
				view.layoutIfNeeded()

				// move sheets up
				moveUpDownSectionTopConstraint.constant = sheetDisplaySwipeView.bounds.height + 100
				sheetDisplayerSwipeViewTop.constant = -sheetDisplaySwipeView.bounds.height
				mixerBottomToTopSwipeViewConstraint.isActive = true
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
	
	@IBAction func addNewSongServicePressed(_ sender: UIBarButtonItem) {
		if let nav = Storyboard.MainStoryboard.instantiateViewController(withIdentifier: "newSongServiceIphoneNav") as? UINavigationController, let vc = nav.topViewController  as? NewSongServiceIphoneController {
			vc.delegate = self
			vc.clusterModel = model ?? TempClustersModel()
			present(nav, animated: true)
		}
	}
	
	
	
	private func animateSheetsWith(_ direction : AnimationDirection, completion: @escaping () -> Void) {
        let nextPreviousScaleFactor = getScaleFactor(width: sheetDisplayerNext.bounds.width)

		switch direction {
		case .left:

			if let sheet = songService.selectedSheet, let nextSheet = songService.nextSheet(select: false) {
                let currentSheetView = SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.selectedSong?.cluster, sheet: sheet, theme: songService.selectedTheme, scaleFactor: getScaleFactor(width: sheetDisplayer.bounds.width), toExternalDisplay: true)
				
				let nextSheetView = SheetView.createWith(frame: sheetDisplayerNext.bounds, cluster: songService.getSongForNextSheet()?.cluster, sheet: nextSheet, theme: songService.nextTheme, scaleFactor: nextPreviousScaleFactor)
				
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

                let currentSheetView = SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.selectedSong?.cluster, sheet: sheet, theme: songService.selectedTheme, scaleFactor: getScaleFactor(width: sheetDisplayer.bounds.width),  toExternalDisplay: true)
				
				let previousSheetView = SheetView.createWith(frame: sheetDisplayerPrevious.bounds, cluster: songService.getSongForPreviousSheet()?.cluster, sheet: previousSheet, theme: songService.previousTheme, scaleFactor: nextPreviousScaleFactor)
				
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
            let clusters: [Cluster] = DataFetcher().getEntities(moc: moc, predicates: [.skipDeleted, .skipRootDeleted])
            let filteredClusters = clusters.filter({ cluster in songService.songs.contains(where: { song in song.cluster.id == cluster.id }) })
            songService.songs = filteredClusters.map({ SongObject(cluster: VCluster(cluster: $0, context: moc)) })
        }
	}
	
	func externalDisplayDidChange(_ notification: Notification) {
		updateSheetDisplayersRatios()
        if let selectedSheet = songService.selectedSheet, songService.selectedSong != nil, externalDisplayWindow != nil {
			display(sheet: selectedSheet)
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
		sheetDisplaySwipeViewCustomHeightConstraint = NSLayoutConstraint(item: sheetDisplaySwipeView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: (UIScreen.main.bounds.width - 20) * externalDisplayWindowRatio)
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
    
    @objc private func rotated() {
        guard isViewLoaded else { return }
        if let constraint = sheetDisplayerWipeViewEqualHeightConstraint {
            view.removeConstraint(constraint)
        }
        sheetDisplayerHeightConstraint.isActive = false
        if UIDevice.current.orientation.isLandscape {
            let heightConstraint = NSLayoutConstraint(item: sheetDisplaySwipeView!, attribute: .height, relatedBy: .equal, toItem: view!, attribute: .height, multiplier: 0.65, constant: 0)
            sheetDisplayerWipeViewEqualHeightConstraint = heightConstraint
            heightConstraint.isActive = true
            view.addConstraint(heightConstraint)
        } else if UIDevice.current.orientation.isPortrait {
            let heightConstraint = NSLayoutConstraint(item: sheetDisplaySwipeView!, attribute: .height, relatedBy: .equal, toItem: view!, attribute: .height, multiplier: 0.3, constant: 0)
            sheetDisplayerWipeViewEqualHeightConstraint = heightConstraint
            heightConstraint.isActive = true
            view.addConstraint(heightConstraint)
        }
        view.layoutIfNeeded()
        externalDisplayDidChange(Notification(name: .dataBaseDidChange))
        
        let isHorizontal = view.bounds.height > view.bounds.width
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        layout.scrollDirection = isHorizontal ? .vertical : .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        songCollectionView.collectionViewLayout = layout
        songsCollectionViewLeftConstraint.constant = isHorizontal ? 100 : 0
        songsCollectionViewRightConstraint.constant = isHorizontal ? 100 : 0
        songCollectionView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (_) in
            self.rotated()
        }) { (_) in
            self.songCollectionView.reloadData()
        }
    }
        
    @discardableResult
    private func refreshCollectionViewListItems() -> InsertAction {
        var allValues: [SongServiceListItems] = []
        var insertAction = InsertAction(section: 0, items: 0, none: true)
        
        guard model?.clusters.count ?? 0 > 0 || model?.sectionedClusterOrComment.count ?? 0 > 0 else {
            collectionViewItems = []
            return insertAction
        }
        if let model = model, let songServiceSettings = model.songServiceSettings {
            var clusterIndex = 0
            for (sectionIndex, section) in songServiceSettings.sections.enumerated() {
                // append cluster
                for cluster in model.sectionedClusterOrComment[sectionIndex] {
                    allValues.append(.sectionedCluster(section: section.title, cluster: cluster.cluster!))
                    // append sheets
                    if let selectedSong = songService.selectedSong, selectedSong.cluster.id == cluster.id {
                        allValues += selectedSong.sheets.compactMap({ SongServiceListItems.sheet(vsheet: $0) })
                        insertAction = InsertAction(section: clusterIndex, items: selectedSong.sheets.count, none: false)
                    }
                    clusterIndex += 1
                }
            }
        } else if let model = model {
            for (index, cluster) in model.clusters.enumerated() {
                // append cluster
                allValues.append(.sectionedCluster(section: nil, cluster: cluster.cluster!))
                // append sheets
                if let selectedSong = songService.selectedSong, selectedSong.cluster.id == cluster.id {
                    allValues += selectedSong.sheets.compactMap({ SongServiceListItems.sheet(vsheet: $0) })
                    insertAction = InsertAction(section: index, items: selectedSong.sheets.count, none: false)
                }
            }
        }
        collectionViewItems = allValues
        return insertAction
    }
}

extension SongServiceController: SongServiceDelegate {
    
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
