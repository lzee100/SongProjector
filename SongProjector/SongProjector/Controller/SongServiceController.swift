//
//  SongServiceController.swift
//  SongViewer
//
//  Created by Leo van der Zee on 05-12-17.
//  Copyright © 2017 Topicus Onderwijs BV. All rights reserved.
//

import UIKit
import CoreData
import SwiftUI

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



class SongServiceController: ChurchBeamViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, SongsControllerDelegate  {
	
	
	
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
    lazy var dataSource: SongServiceCollectionViewDataSource = {
        SongServiceCollectionViewDataSource(collectionView: songCollectionView, cellProvider: { [unowned self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SheetCollectionCell.identitier, for: indexPath) as! SheetCollectionCell
            
            cell.setupWith(cluster: self.songService.selectedSong?.cluster, sheet: item, theme: item.hasTheme ?? self.songService.selectedSong?.cluster.hasTheme(moc: moc), didDeleteSheet: nil, isDeleteEnabled: false, scaleFactor: getScaleFactor(width: self.getSheetSize().width))
            
            if item.id != self.songService.selectedSheet?.id {
                cell.styleDark()
            }
            
            cell.layer.cornerRadius = 10
            cell.clipsToBounds = true
            
            return cell
        })
    }()
	
	// MARK: - Types
	
	private enum displayModeTypes {
		case small
		case normal
		case mixer
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
	private var isPlaying = false
	private var leftSwipe = UISwipeGestureRecognizer()
	private var isMixerVisible = false
	private var model: TempClustersModel?
	
	private var songService: SongService!
    private var canPlay: Bool = true
    
    override var requesters: [RequesterBase] {
        return [UniversalClusterFetcher, SongServicePlayDateFetcher]
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
        UniversalClusterFetcher.initialFetch()
        GoogleActivityFetcher.fetch(force: true)
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
    
    private func didSelectSection(cluster: VCluster) {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let song = songService.selectedSong?.cluster else { return }
        guard song.time == 0 && !song.isTypeSong else { return }
        songService.selectedSheet = song.hasSheets[indexPath.row]
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getSheetSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if view.bounds.height > view.bounds.width {
            return CGSize(width: collectionView.bounds.width, height: 80)
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
        var snapshot = SongServiceCollectionViewDataSource.snapshot()
        snapshot.deleteSections(dataSource.snapshot().sectionIdentifiers)
        model.updateSnapshotFromModel(&snapshot)
        dataSource.apply(snapshot)
        songService.songs = snapshot.sectionIdentifiers
        self.update(scroll: true)
        self.temptSwiftUIModel = model
	}
	
    var temptSwiftUIModel: TempClustersModel?
    @objc func startSwiftUI() {
        
//        let bla = (cluster: ClusterCodable.makeDefault()!, sheet: SheetTitleContentCodable.makeDefault()!)
//        let model = EditSheetOrThemeViewModel(editMode: .sheet(bla, sheetType: .SheetTitleContent), isUniversal: false)!
//
//        let editView = EditThemeOrSheetViewUI(dismiss: { dismissPresenting in
//            self.presentedViewController?.dismiss(animated: true)
//        }, navigationTitle: "test", editSheetOrThemeModel: WrappedStruct(withItem: model))
//        let controller = UIHostingController(rootView: editView)
//        controller.modalPresentationStyle = .formSheet
//        controller.preferredContentSize = CGSize(width: min(UIScreen.main.bounds.width, 500), height: UIScreen.main.bounds.height)
//        present(controller, animated: true)


        // SONGSERVICE UI

        guard let temptSwiftUIModel = temptSwiftUIModel else { return }

        var predicates: [NSPredicate] = []
        predicates += [.skipDeleted, .skipRootDeleted]

//        predicates.append(NSPredicate(format: "not instrumentIds = nil"))

        var songObjects: [SongObjectUI] = []

        for (index, clusterOrCommentArray) in temptSwiftUIModel.sectionedClusterOrComment.enumerated() {
            let sectionTitle = temptSwiftUIModel.songServiceSettings?.sections[index].title
            let clusters = clusterOrCommentArray.compactMap { $0.cluster }.compactMap { ClusterCodable(managedObject: $0.getManagedObject(context: moc), context: moc) }

            for (index, cluster) in clusters.enumerated() {
                if index == 0 {
                    songObjects.append(SongObjectUI(cluster: cluster, sectionHeader: sectionTitle))
                } else {
                    songObjects.append(SongObjectUI(cluster: cluster, sectionHeader: nil))
                }
            }
        }

        let songServiceUI = WrappedStruct(withItem: SongServiceUI(songs: songObjects))
        let controller = UIHostingController(rootView: SongServiceViewUI(songService: songServiceUI, dismiss: {
            self.presentedViewController?.dismiss(animated: true)
        }))
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true)


        // SONGSERVICE UI
//
//
//        let beamerController = UIHostingController(rootView: BeamerViewUI(songsService: songServiceUI))
//        if let externalDisplay = externalDisplayWindow {
//            for subview in externalDisplay.subviews {
//                subview.removeFromSuperview()
//            }
//            externalDisplay.addSubview(beamerController.view)
//        }

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
        songCollectionView.register(cell: SheetCollectionCell.identitier)
        
        if #available(iOS 16.0, *) {
            let swiftUIInterfaceButton = UIBarButtonItem(title: "SwiftUI", style: .plain, target: self, action: #selector(startSwiftUI))
            navigationItem.leftBarButtonItem = swiftUIInterfaceButton
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionHeadersPinToVisibleBounds = true
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        songCollectionView.collectionViewLayout = layout
        
        let headerRegistration = UICollectionView.SupplementaryRegistration
        <SongServiceHeaderCollectionReusableViewOne>(elementKind: UICollectionView.elementKindSectionHeader) {
            [weak self] (headerView, elementKind, indexPath) in
            guard let self = self else { return }
            let songObject = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]

            let isSelected = (SoundPlayer.song?.id == songObject.cluster.id && !SoundPlayer.isPianoOnlyPlaying) || self.songService.selectedSong?.cluster.id == songObject.cluster.id
            let isPianoSoloPlaying = SoundPlayer.song?.id == songObject.cluster.id && SoundPlayer.isPianoOnlyPlaying

            headerView.buildHeader(sectionTitle: nil, title: songObject.cluster.title, cluster: songObject.cluster, isSelected: isSelected, onSectionClick: { [weak self] in
                self?.onSectionClick(indexPath: indexPath, kind: elementKind)
            }, onPianoSoloClick: { [weak self] in
                guard let self = self else { return }
                self.shutDownDisplayer()

                if SoundPlayer.song?.id == songObject.cluster.id && SoundPlayer.isPianoOnlyPlaying {
                    self.songService.selectedSong = nil
                    self.songService.selectedSection = nil
                    SoundPlayer.stop()
                } else {
                    let snapshot = self.songService.didSelect(.none)
                    self.dataSource.apply(snapshot)

                    self.songService.selectedSong = nil
                    self.songService.selectedSection = nil

                    SoundPlayer.play(song: songObject.cluster, pianoSolo: true)
                }
                self.update(scroll: false)
            }, isPianoSoloPlaying: isPianoSoloPlaying)
        }
        
        dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) -> SongServiceHeaderCollectionReusableViewOne? in
            if elementKind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: headerRegistration, for: indexPath)
            }
            return nil
        }
        
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
    }
	
	private func update(scroll: Bool = false) {
        songCollectionView.reloadData()
	}
    
    private func onSectionClick(indexPath: IndexPath, kind: String) {
        guard self.canPlay else {
            let alert = UIAlertController(title: nil, message: AppText.SongService.warnCannotPlay, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: AppText.Actions.ok, style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        dataSource.apply(songService.didSelect(.song(dataSource.snapshot().sectionIdentifiers[indexPath.section])))

        let attributes = self.songCollectionView.collectionViewLayout.layoutAttributesForSupplementaryView(ofKind: kind, at: indexPath)
        if songService.selectedSong != nil {
            if UIDevice.current.orientation.isPortrait {
                self.songCollectionView.setContentOffset(CGPoint(x: 0, y: attributes!.frame.origin.y - self.songCollectionView.contentInset.top), animated: true)
            } else {
                self.songCollectionView.setContentOffset(CGPoint(x: attributes!.frame.origin.x - self.songCollectionView.contentInset.left, y: 0), animated: true)
            }
        }
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
		switch direction {
		case .left:

			if let sheet = songService.selectedSheet, let nextSheet = songService.nextSheet(select: false) {
                let currentSheetView = SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.selectedSong?.cluster, sheet: sheet, theme: songService.selectedTheme, scaleFactor: getScaleFactor(width: sheetDisplayer.bounds.width), toExternalDisplay: true)
                
				let nextSheetView = SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.getSongForNextSheet()?.cluster, sheet: nextSheet, theme: songService.nextTheme, scaleFactor: getScaleFactor(width: sheetDisplayer.bounds.width))
                nextSheetView.frame = sheetDisplayer.frame
                nextSheetView.center = sheetDisplayerNext.center
                nextSheetView.transform = CGAffineTransform(scaleX: sheetDisplayerNext.bounds.width / sheetDisplayer.bounds.width, y: sheetDisplayerNext.bounds.height / sheetDisplayer.bounds.height)

                view.addSubview(currentSheetView)
                view.addSubview(nextSheetView)
                
				sheetDisplayer.isHidden = true
				sheetDisplayerNext.isHidden = true
				
				UIView.animate(withDuration: 0.3, animations: {
                    currentSheetView.transform = CGAffineTransform(scaleX: self.sheetDisplayerPrevious.bounds.width / self.sheetDisplayer.bounds.width, y: self.sheetDisplayerPrevious.bounds.height / self.sheetDisplayer.bounds.height)
                    currentSheetView.center = self.sheetDisplayerPrevious.center
                    nextSheetView.transform = .identity
                    nextSheetView.center = self.sheetDisplayer.center

					
				}, completion: { (bool) in
                    self.view.subviews.filter({ $0.tag == 222 }).first?.removeFromSuperview()
					self.sheetDisplayer.isHidden = false
					self.sheetDisplayerPrevious.isHidden = false
                    currentSheetView.removeFromSuperview()
                    nextSheetView.removeFromSuperview()
					completion()
				})
			}
			
		case .right:
			
			if let sheet = songService.selectedSheet, let previousSheet = songService.previousSheet(select: false) {
				
                let currentSheetView = SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.selectedSong?.cluster, sheet: sheet, theme: songService.selectedTheme, scaleFactor: getScaleFactor(width: sheetDisplayer.bounds.width),  toExternalDisplay: true)
                currentSheetView.center = sheetDisplayer.center
                
				let previousSheetView = SheetView.createWith(frame: sheetDisplayer.bounds, cluster: songService.getSongForPreviousSheet()?.cluster, sheet: previousSheet, theme: songService.previousTheme, scaleFactor: getScaleFactor(width: sheetDisplayer.bounds.width))
                previousSheetView.transform = CGAffineTransform(scaleX: sheetDisplayerPrevious.bounds.width / sheetDisplayer.bounds.width, y: sheetDisplayerPrevious.bounds.height / sheetDisplayer.bounds.height)
                previousSheetView.center = sheetDisplayerPrevious.center

                view.addSubview(currentSheetView)
                view.addSubview(previousSheetView)

				sheetDisplayer.isHidden = true
				sheetDisplayerPrevious.isHidden = true
				sheetDisplayerNext.isHidden = songService.nextSheet(select: false) == nil
				
				UIView.animate(withDuration: 0.3, animations: {
					
                    currentSheetView.transform = CGAffineTransform(scaleX: self.sheetDisplayerNext.bounds.width / self.sheetDisplayer.bounds.width, y: self.sheetDisplayerNext.bounds.height / self.sheetDisplayer.bounds.height)
                    currentSheetView.center = self.sheetDisplayerNext.center
                    previousSheetView.transform = .identity
                    previousSheetView.center = self.sheetDisplayer.center

				}, completion: { (bool) in
					self.sheetDisplayer.isHidden = false
					self.sheetDisplayerPrevious.isHidden = false
                    currentSheetView.removeFromSuperview()
                    previousSheetView.removeFromSuperview()
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
            songService.songs = filteredClusters.map({ SongObject(cluster: VCluster(cluster: $0, context: moc), headerTitle: nil) })
        }
	}
	
	func externalDisplayDidChange(_ notification: Notification) {
		updateSheetDisplayersRatios()
        if let selectedSheet = songService.selectedSheet, songService.selectedSong != nil {
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
        }
    }
}

extension SongServiceController: SongServiceDelegate {
    
    func countDown(value: Int) {
        guard value > 0 else {
            view.subviews.compactMap({ $0 as? CountDownView }).forEach({ $0.removeFromSuperview() })
            return
        }
        
        if let countDownView = view.subviews.compactMap({ $0 as? CountDownView }).first {
            countDownView.countDownLabel.text = value.stringValue
            view.bringSubviewToFront(countDownView)
        } else {
            let countDownView = CountDownView(frame: sheetDisplayer.bounds)
            countDownView.countDownLabel.text = value.stringValue
            view.addSubview(countDownView)
            view.bringSubviewToFront(countDownView)
            countDownView.anchorTo(sheetDisplayer)
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
