//
//  CustomSheetsController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10-02-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit
import SwiftUI

protocol CustomSheetsControllerDelegate {
    func didCloseCustomSheet()
}

class CustomSheetsController: ChurchBeamViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, NewOrEditIphoneControllerDelegate, LyricsControllerDelegate {
	
	
	
	// MARK: - Properties
	
	@IBOutlet var cancel: UIBarButtonItem!
	@IBOutlet var save: UIBarButtonItem!
	@IBOutlet weak var edit: UIBarButtonItem?
	
	@IBOutlet var collectionViewThemes: UICollectionView!
	@IBOutlet var collectionView: UICollectionView!
    @IBOutlet var themesBackgroundView: UIView!
    
    @IBOutlet var tagsCollectionViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet var tagCollectionViewRightConstraint: NSLayoutConstraint!
    @IBOutlet var tagsCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var songsTableViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet var songTableViewRightConstraint: NSLayoutConstraint!
    @IBOutlet var songsTableViewBottomConstraint: NSLayoutConstraint!
    
    var isNew = true
	var themes: [VTheme] = []
	var selectedTheme: VTheme? {
		didSet {
            if let themeId = selectedTheme?.id {
                cluster?.themeId = themeId
            }
            if let cluster = cluster, (cluster.isTypeSong || cluster.hasBibleVerses) {
                updateWithAnimation()
            } else {
                update()
            }
		}
	}
	var isEdited = false
	var delegate: CustomSheetsControllerDelegate?
    
	var cluster: VCluster? {
		didSet {
			if let cluster = cluster {
				sheets = cluster.hasSheets
			}
		}
	}
	var sheets: [VSheet] = [] {
		didSet {
			save.isEnabled = sheets.count > 0
			for (index, sheet) in sheets.enumerated() {
				sheet.position = index
			}
		}
	}
	var isBibleStudySheetGenerator = false
    var hasSaveOption = true
    
	// MARK: Private properties
    private var itemSize = CGSize.zero
	private var longPressGesture: UILongPressGestureRecognizer!
	private var generateEmptySheetsBibleStudy = true
	
	// MARK - UIView functions
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        view.layoutIfNeeded()
        collectionView.layoutIfNeeded()
        itemSize = isIpad ? getSizeWith(height: collectionView.bounds.height, width: nil) : getSizeWith(height: nil, width: collectionView.bounds.width)
        layout.scrollDirection = isIpad  ? .horizontal : .vertical
        layout.itemSize = itemSize
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 30
        collectionView.collectionViewLayout = layout
        collectionView.reloadData()
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		update()
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination.unwrap() as? SaveNewSongTitleTimeVC {
            controller.didSave = didSaveSongWith
            controller.cluster = cluster
            controller.selectedTheme = selectedTheme
        }
        
        if let controller = segue.destination.unwrap() as? SheetPickerMenuController {
            controller.delegate = self
            let isSong = (cluster?.isTypeSong ?? false) && getTextFromSheets().length > 0
            let isCustom = sheets.contains(where: { $0.hasTheme?.isHidden == true })
            controller.mode = isSong ? .song : isCustom ? .custom : .none

        }
        
        if segue.identifier == "BibleStudyIphoneGeneratorSegue" {
            let controller = segue.destination as! BibleStudyGeneratorIphoneController
            controller.selectedTheme = selectedTheme
        }
        if segue.identifier == "BibleStudyGeneratorSegue" {
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! BibleStudyGeneratorController
            controller.selectedTheme = selectedTheme
        }
        
        if let vc = segue.destination.unwrap() as? LyricsViewController {
            vc.isBibleTextGenerator = isBibleStudySheetGenerator
            if isBibleStudySheetGenerator {
                vc.text = getBibleStudyTextFromSheets()
            } else {
                vc.text = getTextFromSheets()
            }
            vc.delegate = self
        }
    }
	
	
	
	// MARK: - UICollectionView Functions
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionView == collectionViewThemes ? themes.count : sheets.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if collectionView == collectionViewThemes {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.themeCellCollection, for: indexPath) as! ThemeCellCollection
			
			cell.setup(themeName: themes[indexPath.row].title ?? "")
            cell.isSelectedCell = themes[indexPath.row].id == selectedTheme?.id
			return cell
			
		} else {
            let isBibleStudy = (sheets[indexPath.row] as? VSheetTitleContent)?.isBibleVers ?? false
            let isSong = cluster?.isTypeSong ?? false
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.sheetCollectionCell, for: indexPath) as! SheetCollectionCell
			cell.setupWith(
				cluster: cluster,
				sheet: sheets[indexPath.row],
				theme: sheets[indexPath.row].hasTheme ?? selectedTheme,
                didDeleteSheet: isBibleStudy ? nil : didDeleteSheet(sheet:),
                isDeleteEnabled: !isBibleStudy && !isSong,
                scaleFactor: getScaleFactor(width: itemSize.width))
			return cell
		}
		
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == collectionViewThemes {
			let font = UIFont.systemFont(ofSize: 17)
			let width = (themes[indexPath.row].title ?? "").width(withConstrainedHeight: 22, font: font) + 50
			return CGSize(width: width, height: 50)
		} else {
			return itemSize
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == collectionViewThemes {
            selectedTheme = selectedTheme?.id == themes[indexPath.row].id ? nil : themes[indexPath.row]
		} else {
            Queues.main.async {
                let isBibleStudyVersion = self.sheets.compactMap({ $0 as? VSheetTitleContent }).contains(where: { $0.isBibleVers })
                if self.cluster?.isTypeSong ?? false {
                    self.isBibleStudySheetGenerator = self.sheets.compactMap({ $0 as? VSheetTitleContent }).contains(where: { $0.isBibleVers })
                    self.performSegue(withIdentifier: "ChangeLyricsSegue", sender: self)
                    return
                } else if isBibleStudyVersion {
                    self.checkAndShowBibleStudyController()
                } else {
                    let sheet = self.sheets[indexPath.row]
                    let controller = self.storyboard?.instantiateViewController(withIdentifier: "NewOrEditIphoneController") as! NewOrEditIphoneController
                    controller.modificationMode = .editCustomSheet
                    controller.sheet = sheet
                    controller.theme = sheet.hasTheme
                    controller.delegate = self
                    let nav = UINavigationController(rootViewController: controller)
                    self.present(nav, animated: true)
                }
            }
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let sourceItem = sheets[sourceIndexPath.row]
		sheets.remove(at: sourceIndexPath.row)
		sheets.insert(sourceItem, at: destinationIndexPath.row)
		collectionView.visibleCells.forEach { $0.layer.removeAllAnimations() }
	}
	
	
	
	// MARK: - Delegate Functions
	
	func didCreate(sheet: VSheet) {
		if sheets.first(where: {  $0.id == sheet.id }) == nil {
			sheets.append(sheet)
			cluster?.hasSheets = sheets.sorted(by: { $0.position < $1.position })
		}
		
		isEdited = true
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
			if let index = self.sheets.firstIndex(of: sheet) {
				self.collectionView.insertItems(at: [IndexPath(row: index, section: 0)])
			}
		}
        setRightBarButtonItem()
	}
	
	func didCloseNewOrEditIphoneController() {
		presentedViewController?.dismiss(animated: true, completion: nil)
		delegate?.didCloseCustomSheet()
	}
	
    func didPressDone(text: String, isCompleted: Bool) {
        guard !(cluster?.hasRemoteMusic ?? false) else {
            
            buildSheets(fromText: text) { (numberOfSheets) in
                // you cannot change the number of sheets on a universal song, these hase display time set on every sheet
                if numberOfSheets != self.sheets.count {
                    let controller = UIAlertController(title: AppText.CustomSheets.universalSongEditErrorTitle, message: AppText.CustomSheets.universalSongEditErrorMessage, preferredStyle: .alert)
                    controller.addAction(UIAlertAction(title: AppText.Actions.ok, style: .default))
                    self.present(controller, animated: true)
                } else {
                    
                    // update sheets, but set the original times again
                    let times = self.sheets.compactMap({ $0.time })
                    self.buildSheets(fromText: text, onlyCount: nil)
                    for (index, sheet) in self.sheets.enumerated() {
                        sheet.time = times[index]
                    }
                    if let cluster = self.cluster {
                        for (index, sheet) in cluster.hasSheets.enumerated() {
                            sheet.time = times[index]
                        }
                    }
                }
            }
            return
        }
        collectionView.isHidden = true
        if isCompleted {
            buildSheets(fromText: text, onlyCount: nil)
        }
	}
	
	
	
	// MARK: - Submit Observer Functionse t6b6v
	
	override func handleRequestFinish(requesterId: String, result: Any?) {
		Queues.main.async {
            NotificationCenter.default.post(name: .dataBaseDidChange, object: nil)
			self.delegate?.didCloseCustomSheet()
            self.dismiss(animated: true)
            ClusterSubmitter.removeObserver(self)
            UniversalClusterSubmitter.removeObserver(self)
		}
	}
	
    
    
	// MARK: - Functions
	
	@objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
		
		switch(gesture.state) {
			
		case .began:
			guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
				break
			}
			collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
			collectionView.visibleCells.forEach { animate(cell: $0) }
		case .changed:
			collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
		case .ended:
			collectionView.visibleCells.forEach { $0.layer.removeAllAnimations() }
			collectionView.endInteractiveMovement()
		default:
			collectionView.visibleCells.forEach { $0.layer.removeAllAnimations() }
			collectionView.cancelInteractiveMovement()
		}
	}
	
	func didDeleteSheet(sheet: VSheet) {
		
		if let index = sheets.firstIndex(of: sheet) {
			sheets.remove(at: index)
            if let index = cluster?.hasSheets.firstIndex(entity: sheet) {
                let deletedSheetImage = (cluster?.hasSheets[index] as? VSheetPastors)?.imagePathAWS ?? (cluster?.hasSheets[index] as? VSheetTitleImage)?.imagePathAWS
                let deletedThemeImage = cluster?.hasSheets[index].hasTheme?.imagePathAWS
                cluster?.deletedSheetsImageURLs.append(contentsOf: [deletedSheetImage, deletedThemeImage].compactMap({ $0 }))
                cluster?.hasSheets.remove(at: index)
            }
			collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
			self.collectionView.reloadData()
		}
        setRightBarButtonItem()
	}
	
	func didSaveSongWith() {
		if let themeId = selectedTheme?.id {
			cluster?.themeId = themeId
		}
		if let cluster = cluster {
            let method: RequestMethod = cluster.updatedAt == nil ? .post : .put
            if uploadSecret == nil {
                if cluster.hasSheets.filter({ $0.hasTheme?.tempSelectedImage != nil }).count > 0 {
                    showProgress(requester: ClusterSubmitter)
                } else {
                    showLoader()
                    ClusterSubmitter.addObserver(self)
                }
                ClusterSubmitter.submit([cluster], requestMethod: method)
            } else {
                cluster.hasSheetPastors = cluster.hasSheets.contains(where: { $0 is VSheetPastors })
                if cluster.hasSheets.filter({ $0.hasTheme?.tempSelectedImage != nil }).count > 0 {
                    showProgress(requester: UniversalClusterSubmitter)
                } else {
                    UniversalClusterSubmitter.addObserver(self)
                    UniversalClusterSubmitter.dontUploadFiles = true
                }
                UniversalClusterSubmitter.submit([cluster], requestMethod: method)
            }
		} else {
			Queues.main.async {
				self.dismiss(animated: true)
			}
		}
	}
	
    
	
	// MARK: - Private functions
	
	private func setup() {
		
        collectionViewThemes.register(cell: Cells.themeCellCollection)
        collectionView.register(cell: SheetCollectionCell.identitier)

        save.title = AppText.Actions.save
		cancel.title = AppText.Actions.cancel
        cancel.tintColor = .orange
        save.tintColor = .orange
        themesBackgroundView.backgroundColor = .whiteColor
        if !hasSaveOption {
            navigationItem.rightBarButtonItems = navigationItem.rightBarButtonItems?.filter({ $0 != save })
        }
        
		navigationController?.title = AppText.CustomSheets.title
		title = AppText.CustomSheets.title
        
		hideKeyboardWhenTappedAround()

		longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
		longPressGesture.minimumPressDuration = 1
		collectionView.addGestureRecognizer(longPressGesture)

        var bottomEdge: CGFloat = 20
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.windows[0]
            bottomEdge += window.safeAreaInsets.bottom
        }
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomEdge, right: 0)
        var predicates: [NSPredicate] = [.skipDeleted]
        predicates.append("isHidden", notEquals: true)
//        let checkthemes: [Theme] = DataFetcher().getEntities(moc: moc, predicates: predicates)
//        self.themes = checkthemes.map({ VTheme(theme: $0, context: moc) })

        if let cluster = cluster {
            selectedTheme = cluster.hasTheme(moc: moc)
        } else {
            cluster = VCluster()
        }

        updateBorderConstraints()
        setRightBarButtonItem()
	}
	
	override func update() {
		removeRedBorder()
		collectionViewThemes.reloadData()
		collectionView.reloadData()
	}
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        preferredContentSize = CGSize(width: UIScreen.main.bounds.width * 0.95, height: 450)
        updateBorderConstraints()
    }
    
    private func updateBorderConstraints() {
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        let padding: CGFloat = isIpad ? 40 : 10
        tagsCollectionViewHeightConstraint.constant = isIpad ? 60 : 50
        tagsCollectionViewLeftConstraint.constant = padding
        tagCollectionViewRightConstraint.constant = padding
        songTableViewRightConstraint.constant = padding
        songsTableViewLeftConstraint.constant = padding
        songsTableViewBottomConstraint.constant = isIpad ? 40 : 0
    }
    		
	private func hasThemeSelected(_ hasTheme: Bool) {
		if hasTheme {
			collectionViewThemes.layer.borderColor = nil
			collectionViewThemes.layer.borderWidth = 0
			collectionViewThemes.layer.cornerRadius = 0
		} else {
			collectionViewThemes.layer.borderColor = UIColor.red.cgColor
			collectionViewThemes.layer.borderWidth = 2
			collectionViewThemes.layer.cornerRadius = 5
		}
	}
	
    private func buildSheets(fromText: String, onlyCount: ((Int) -> Void)?) {
		if cluster == nil, onlyCount == nil {
			cluster = VCluster()
		}
		
		cluster?.deleteDate = nil
		if let themeId = selectedTheme?.id, onlyCount == nil {
			cluster?.themeId = themeId
		}
        
        guard !isBibleStudySheetGenerator else {
            buildBibleSheets(fromText: fromText)
            return
        }
        
        
		var contentToDevide = fromText + "\n\n"
		
		// get title
		if let range = contentToDevide.range(of: "\n\n") {
			let start = contentToDevide.index(contentToDevide.startIndex, offsetBy: 0)
			let rangeSheet = start..<range.lowerBound
			let rangeRemove = start..<range.upperBound
            if onlyCount == nil {
                cluster?.title = String(contentToDevide[rangeSheet])
            }
			contentToDevide.removeSubrange(rangeRemove)
		}
		
		var position = 0
		var newSheets: [VSheet] = []
		// get sheets
		while let range = contentToDevide.range(of: "\n\n") {
			
			// get content
			let start = contentToDevide.index(contentToDevide.startIndex, offsetBy: 0)
			let rangeSheet = start..<range.lowerBound
			let rangeRemove = start..<range.upperBound
			
			let sheetLyrics = String(contentToDevide[rangeSheet])
			var sheetTitle: String = AppText.NewSong.noTitleForSheet
			
			// get title
			if let rangeTitle = contentToDevide.range(of: "\n") {
				let startTitle = contentToDevide.index(contentToDevide.startIndex, offsetBy: 0)
				let rangeSheetTitle = startTitle..<rangeTitle.lowerBound
				sheetTitle = String(contentToDevide[rangeSheetTitle])
			}
			
			let newSheet = VSheetTitleContent()
            newSheet.id = UUID().uuidString
			newSheet.title = sheetTitle
			newSheet.content = sheetLyrics
			newSheet.position = position
			
			newSheets.append(newSheet)
			
			contentToDevide.removeSubrange(rangeRemove)
			position += 1
		}
        
        guard onlyCount == nil else {
            onlyCount?(newSheets.count)
            return
        }
		
		newSheets.sort{ $0.position < $1.position }
		
		if let sheets = newSheets as? [VSheetTitleContent] {
			for tempSheet in sheets {
				let sheet = VSheetTitleContent()
				sheet.title = tempSheet.title
				sheet.content = tempSheet.content
				sheet.position = tempSheet.position
				cluster?.hasSheets.append(sheet)
			}
		}
		sheets = newSheets
        cluster?.hasSheets = newSheets
		isEdited = true
		updateWithAnimation()
        setRightBarButtonItem()
	}
    
    private func buildBibleSheets(fromText: String) {
        
        var position = 0
        var newSheets: [VSheet] = []
        // get sheets
        
        let devided = fromText.components(separatedBy: "\n\n")
        let allTitles = devided.compactMap({ $0.split(separator: "\n").first }).compactMap({ String($0) })
        let onlyScriptures: [String] = devided.compactMap({
            guard $0.count > 1 else { return nil }
            var splitOnReturns = $0.split(separator: "\n")
            splitOnReturns.removeFirst()
            return splitOnReturns.joined(separator: "\n")
        })
        
        for (index, title) in allTitles.enumerated() {
            let sheets = getSheetsFor(text: onlyScriptures[index], position: &position, title: title)
            newSheets.append(contentsOf: sheets)
            position += 1
        }
        
        newSheets.sort{ $0.position < $1.position }
        
        sheets = newSheets
        cluster?.hasSheets = newSheets
        isEdited = true
        updateWithAnimation()
        isBibleStudySheetGenerator = false
        setRightBarButtonItem()
    }
    
    private func setRightBarButtonItem() {
        let isTypeSong = !sheets.contains(where: { $0.hasTheme?.isHidden == true  }) && sheets.count > 0 && !sheets.compactMap({ $0 as? VSheetTitleContent }).contains(where: { $0.isBibleVers })
        if isTypeSong {
            self.isBibleStudySheetGenerator = self.sheets.compactMap({ $0 as? VSheetTitleContent }).contains(where: { $0.isBibleVers })
            let editButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showLyricsController))
            editButton.tintColor = themeHighlighted
            navigationItem.rightBarButtonItem = editButton
        } else {
            let showLyricsOption = !self.sheets.contains(where: { $0.hasTheme != nil || (($0 as? VSheetTitleContent)?.isBibleVers ?? false) })
            let editButton = UIBarButtonItem(systemItem: .add, primaryAction: nil, menu: SheetTypeMenu.createMenu(delegate: self, showLyricsOption: showLyricsOption, checkCustomSheets: {
                self.checkAndShowBibleStudyController()
            }, hasThemeSelected: hasThemeSelected))
            editButton.tintColor = themeHighlighted
            navigationItem.rightBarButtonItem = editButton
        }
        
    }
    
    @objc private func showLyricsController() {
        self.performSegue(withIdentifier: "ChangeLyricsSegue", sender: self)
    }
    
    private func checkAndShowBibleStudyController() {
        if self.sheets.filter({ $0.isNotLyricsAndNotBibleVers }).count > 0 {
            // show warning deleting those custom sheets
            let alert = UIAlertController(title: nil, message: AppText.CustomSheets.errorLoseOtherSheets, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: AppText.Actions.edit, style: .destructive, handler: { _ in
                self.showBibleStudyInputController()
            }))
            alert.addAction(UIAlertAction(title: AppText.Actions.cancel, style: .cancel))
            self.present(alert, animated: true)
        } else {
            self.showBibleStudyInputController()
        }
    }
    	
	private func getTextFromSheets() -> String {
		if let sheets = sheets as? [VSheetTitleContent], sheets.count != 0 {
            var totalString = isBibleStudySheetGenerator ? "" : (cluster?.title ?? "") + "\n\n"
			let tempSheets:[VSheetTitleContent] = sheets.count > 0 ? sheets : cluster?.hasSheets as? [VSheetTitleContent] ?? []
			for (index, sheet) in tempSheets.enumerated() {
				totalString += sheet.content ?? ""
				if index < tempSheets.count - 1 { // add only \n\n to second last, not the last one, or it will add empty sheet
					totalString +=  "\n\n"
				}
			}
			return totalString
		}
		return ""
	}
    
    private func getBibleStudyTextFromSheets() -> String {
        guard sheets.count > 0 else { return "" }
        var titleContentSheets = sheets
        titleContentSheets = titleContentSheets.filter({ $0.hasTheme == nil })
        
        var totalString = ""
        var currentTitle = ""
        var currentScripture = ""
        
        repeat {
            let sheet = titleContentSheets.first
            
            if let sheet = sheet as? VSheetTitleContent {
                currentTitle = sheet.title ?? ""
                currentScripture = [currentScripture, sheet.content ?? ""].joined(separator: " ").trimmingCharacters(in: .whitespaces)
            } else if sheet is VSheetEmpty {
                currentScripture = currentScripture.replacingOccurrences(of: "\n\(currentTitle)", with: "")
                var addSpace = false
                if titleContentSheets.filter({ $0 is VSheetEmpty }).count > 1 {
                    addSpace = true
                }
                totalString += currentScripture
                totalString += addSpace ? "\n\n" : ""
                currentScripture = ""
            }
            titleContentSheets.remove(at: 0)
            
        } while titleContentSheets.count > 0
        
        return totalString
    }
    
    private func getSheetsFor(text: String, position: inout Int, title: String) -> [VSheet] {
        
        guard let selectedTheme = selectedTheme else {
            return []
        }
        
        var textWithoutTitle = text
        if let range = text.range(of: "\n" + title) {
            textWithoutTitle.removeSubrange(range)
        }
        let sheetHeight = UIDevice.current.userInterfaceIdiom == .pad ? getSizeWith(height: collectionView.frame.height).height : getSizeWith(height: nil, width: collectionView.frame.width).height
        let topBottomMargin: CGFloat = 3 * 10 * getScaleFactor(width: itemSize.width) // superview top to title top, title bottom to tv top, tv bottom to superview bottom
        let textViewHeight = sheetHeight - topBottomMargin
        var words = textWithoutTitle.words
        var currentSheetText: [String] = []
        var sheetTexts: [String ] = []
        var sheets: [VSheet] = []
        
        let width: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? getSizeWith(height: collectionView.frame.height).width : getSizeWith(height: nil, width: collectionView.frame.width).width
        let scaleFactor = getScaleFactor(width: width)
        let attributes = selectedTheme.getLyricsAttributes(scaleFactor)
        let font = (attributes[.font] as? UIFont) ?? UIFont.normal
        let textViewPaddings: CGFloat = 2 * 10 * scaleFactor
        
        func isLessThanHeightTextViewFor(sheetNumber: Int) -> Bool {
            let subTitle = sheetNumber == 0 ? "" : "\n" + title
            let title = sheetNumber == 0 ? title + "\n" : ""
            let nextSheetText = ([title] + currentSheetText + [String(words.first ?? "")] + [subTitle]).joined(separator: " ")
            return nextSheetText.height(withConstrainedWidth: width - textViewPaddings, font: font) < textViewHeight
        }
        
        repeat {
            
            repeat {
                if let word = words.first {
                    currentSheetText.append(String(word))
                    words.removeFirst()
                }
            } while isLessThanHeightTextViewFor(sheetNumber: sheetTexts.count) && words.count > 0
            
            if sheetTexts.count == 0 {
                sheetTexts.append(title + "\n" + currentSheetText.joined(separator: " "))
            } else {
                sheetTexts.append(currentSheetText.joined(separator: " ") + "\n" + title)
            }
            currentSheetText = []
            
        } while words.count > 0
        
        for sheetText in sheetTexts {
            let newSheet = VSheetTitleContent()
            newSheet.id = UUID().uuidString
            newSheet.title = title
            newSheet.content = sheetText
            newSheet.position = position
            newSheet.isBibleVers = true
            sheets.append(newSheet)
            position += 1
        }
        let sheet = VSheetEmpty()
        sheet.position = position
        sheets.append(sheet)
        position += 1
        
        return sheets
    }
	
	private func animate(cell: UICollectionViewCell) {
		if let cell = cell as? SheetCollectionCell {
			let transformAnim  = CAKeyframeAnimation(keyPath:"transform")
			transformAnim.values  = [NSValue(caTransform3D: CATransform3DMakeRotation(0.01, 0.0, 0.0, 1.0)),NSValue(caTransform3D: CATransform3DMakeRotation(-0.01 , 0, 0, 1))]
			transformAnim.autoreverses = true
			transformAnim.duration = 0.115
			transformAnim.repeatCount = Float.infinity
			cell.layer.add(transformAnim, forKey: "transform")
		}
	}
    
    var timer: Timer?
	var cellIndex = 0
	private func updateWithAnimation() {
        update()
        view.layoutIfNeeded()
        timer?.invalidate()
        cellIndex = 0
        timer = nil
        let cells = collectionView.visibleCells

        for cell in collectionView.visibleCells {
            cell.transform = CGAffineTransform(translationX: 0, y: view.bounds.height + cell.frame.minY)
        }
        collectionView.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(animateCell), userInfo: cells, repeats: true)
	}
    
    @objc private func animateCell(_ timer: Timer) {
        guard let cells = timer.userInfo as? [UICollectionViewCell], cells.count > 0 else { return }

        UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut) {
            cells[self.cellIndex].transform = .identity
        } completion: { [weak self] _ in
            guard let _self = self else { return }
            if _self.cellIndex + 1 == _self.collectionView.visibleCells.count {
                _self.timer?.invalidate()
                _self.cellIndex = 0
                _self.timer = nil
            }
        }
        
        if cellIndex + 1 < cells.count {
            cellIndex += 1
        }
        
    }
    
    private func showBibleStudyInputController() {
        self.isBibleStudySheetGenerator = true
        Queues.main.async {
            self.performSegue(withIdentifier: "ChangeLyricsSegue", sender: self)
        }
    }
	
    @discardableResult
	private func hasThemeSelected() -> Bool {
		if selectedTheme != nil {
			removeRedBorder()
			return true
		} else {
			collectionViewThemes.layer.borderColor = UIColor.red.cgColor
			collectionViewThemes.layer.borderWidth = 2
			collectionViewThemes.layer.cornerRadius = 5
			collectionViewThemes.shake()
            show(message: AppText.CustomSheets.errorSelectTheme)
			return false
		}
	}
	
	private func removeRedBorder() {
		collectionViewThemes.layer.borderColor = nil
		collectionViewThemes.layer.borderWidth = 0
		collectionViewThemes.layer.cornerRadius = 0
	}
    
    private func themeSelected() -> Bool {
        return selectedTheme != nil
    }
	
    
    
	// MARK: - IBAction functions
	
	@IBAction func cancel(_ sender: UIBarButtonItem) {
        cluster?.deletedSheetsImageURLs = []
		presentingViewController?.viewWillAppear(false)
		dismiss(animated: true)
	}
    
	@IBAction func saveIphonePressed(_ sender: UIBarButtonItem) {
		if hasThemeSelected() {
			performSegue(withIdentifier: "saveNewSongSegue", sender: self)
		}
	}
    
}

extension CustomSheetsController: UIPopoverPresentationControllerDelegate {
	
	func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}
	
}

extension CustomSheetsController: SheetPickerMenuControllerDelegate {
    
    func didSelectOption(option: SheetPickerMenuOption) {
//        presentedViewController?.dismiss(animated: false)
//        switch option {
//        case .lyrics:
//            isBibleStudySheetGenerator = false
//            Queues.main.async {
//                self.performSegue(withIdentifier: "ChangeLyricsSegue", sender: self)
//            }
//        case .SheetTitleContent: show(mode: .sheet(nil, sheetType: .SheetTitleContent))
//        case .SheetTitleImage: show(mode: .sheet(nil, sheetType: .SheetTitleImage))
//        case .SheetPastors: show(mode: .sheet(nil, sheetType: .SheetPastors))
//        case .SheetSplit: show(mode: .sheet(nil, sheetType: .SheetSplit))
//        case .SheetEmpty: show(mode: .sheet(nil, sheetType: .SheetEmpty))
//        case .SheetActivities: show(mode: .sheet(nil, sheetType: .SheetActivities))
//        case .bibleStudy:
//            showBibleStudyInputController()
//        }
    }
    
//    private func show(mode: SheetViewModel.EditMode) {
////        guard let editModel = SheetViewModel(editMode: mode, isUniversal: uploadSecret != nil) else { return }
//
////        let controllerView = EditThemeOrSheetViewUI(dismiss: { [weak self] dismissPresenting in
////            if dismissPresenting {
////                self?.dismiss(animated: true)
////            } else {
////                self?.presentedViewController?.dismiss(animated: true)
////            }
////        }, navigationTitle: AppText.NewSheetTitleImage.title, editSheetOrThemeModel: WrappedStruct(withItem: editModel))
////
////        present(UIHostingController(rootView: controllerView), animated: true)
//
//    }
//    
}

private extension VSheet {
    
    var isNotLyricsAndNotBibleVers: Bool {
        
        if let sheet = self as? VSheetTitleContent {
            if let theme = sheet.hasTheme, theme.isHidden {
                return false
            }
            return !sheet.isBibleVers
        } else {
            return true
        }
    }
    
}

private extension CGFloat {
    
    func numberOfLines(width: CGFloat, font: UIFont) -> Int {
        let charSize = font.lineHeight
        let linesRoundedUp = Int(ceil(self/charSize))
        return linesRoundedUp
    }
}

private extension String {
    
    func numberOfLines(width: CGFloat, font: UIFont) -> Int {
        let maxSize = CGSize(width: width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = self as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
    
}
