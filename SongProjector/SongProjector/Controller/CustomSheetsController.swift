//
//  CustomSheetsController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 10-02-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

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
	
	@IBOutlet weak var addLyricsButton: UIButton?
	@IBOutlet weak var addSheetButton: UIButton?
	
	var isNew = true
	var themes: [Theme] = []
	var selectedTheme: Theme? {
		didSet {
			clusterTemp?.hasTheme = selectedTheme
			if clusterTemp?.isTypeSong ?? false {
				updateWithAnimation()
			}
		}
	}
	var isEdited = false
	var delegate: CustomSheetsControllerDelegate?
	
	var cluster: Cluster? {
		didSet {
			if let cluster = cluster {
				clusterTemp = cluster.tempVersion
				sheets = cluster.hasSheetsArray
			}
		}
	}
	override var requesterId: String {
		return "CustomSheetsController"
	}
	var clusterTemp: Cluster?
	var sheets: [Sheet] = [] {
		didSet {
			sheetsTemp = []
			sheetHasSheet = []
			save.isEnabled = sheets.count > 0
			for (index, sheet) in sheets.enumerated() {
				sheet.position = Int16(index)
				let tempSheet = sheet.getTemp
				sheetHasSheet.append(SheetHasSheet(sheetId: sheet.id, sheetTempId: tempSheet.id))
				sheetsTemp.append(tempSheet)
			}
		}
	}
	var sheetsTemp: [Sheet] = [] {
		didSet {
			var index: Int16 = 0
			sheetsTemp.forEach({
				$0.hasCluster = clusterTemp
				$0.position = index
				index += 1
			})
			sheetsTemp.sort(by: { $0.position < $1.position })
			save.isEnabled = sheetsTemp.count > 0
		}
	}
	var sheetHasSheet: [SheetHasSheet] = []
	
	
	
	// MARK: Private properties
	private var sheetSize = CGSize(width: 250 * externalDisplayWindowRatioHeightWidth, height: 250)
	private var longPressGesture: UILongPressGestureRecognizer!
	
	
	
	// MARK - UIView functions
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setup()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		update()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
			print(self.clusterTemp?.id ?? -2)
			CoreEntity.predicates.append("id", equals: self.clusterTemp?.id)
			let entities = CoreEntity.getEntities()
			let temps = entities.map({ $0.isTemp })
			print(temps)
			CoreEntity.managedObjectContext = mocBackground
			CoreEntity.predicates.append("id", equals: self.clusterTemp?.id)
			let entitiesb = CoreEntity.getEntities()
			let tempsb = entitiesb.map({ $0.isTemp })
			print(tempsb)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if let controller = segue.destination.unwrap() as? SaveNewSongTitleTimeVC {
			controller.didSave = didSaveSongWith
			controller.cluster = clusterTemp
			controller.selectedTheme = selectedTheme
		}
	}
	
	
	
	// MARK: - UICollectionView Functions
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionView == collectionViewThemes ? themes.count : sheetsTemp.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		if collectionView == collectionViewThemes {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.themeCellCollection, for: indexPath) as! ThemeCellCollection
			
			cell.setup(themeName: themes[indexPath.row].title ?? "")
			cell.isSelectedCell = themes[indexPath.row] == selectedTheme
			return cell
			
		} else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.sheetCollectionCell, for: indexPath) as! SheetCollectionCell
			cell.setupWith(
				cluster: clusterTemp,
				sheet: sheetsTemp[indexPath.row],
				theme: sheetsTemp[indexPath.row].hasTheme ?? clusterTemp?.hasTheme,
				didDeleteSheet: didDeleteSheet(sheet:))
			return cell
		}
		
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if collectionView == collectionViewThemes {
			let font = UIFont.systemFont(ofSize: 17)
			let width = (themes[indexPath.row].title ?? "").width(withConstrainedHeight: 22, font: font) + 50
			return CGSize(width: width, height: 50)
		} else {
			return UIDevice.current.userInterfaceIdiom == .pad ? getSizeWith(height: collectionView.frame.height) : getSizeWith(height: nil, width: collectionView.frame.width)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == collectionViewThemes {
			selectedTheme = selectedTheme == themes[indexPath.row] ? nil : themes[indexPath.row]
			update()
		} else {
			if clusterTemp?.isTypeSong ?? false {
				performSegue(withIdentifier: "ChangeLyricsSegue", sender: self)
				return
			}
			let sheet = sheetsTemp[indexPath.row]
			let controller = storyboard?.instantiateViewController(withIdentifier: "NewOrEditIphoneController") as! NewOrEditIphoneController
			controller.modificationMode = .editCustomSheet
			controller.sheet = sheet
			controller.delegate = self
			let nav = UINavigationController(rootViewController: controller)
			present(nav, animated: true)
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
		let sourceItem = sheetsTemp[sourceIndexPath.row]
		sheetsTemp.remove(at: sourceIndexPath.row)
		sheetsTemp.insert(sourceItem, at: destinationIndexPath.row)
		collectionView.visibleCells.forEach { $0.layer.removeAllAnimations() }
	}
	
	
	
	// MARK: - Delegate Functions
	
	func didCreate(sheet: Sheet) {
		if sheetsTemp.first(where: {  $0.id == sheet.id }) == nil {
			sheets.append(sheet)
		}
		
		isEdited = true
		checkAddButton()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
			let sheetTempId = self.sheetHasSheet.first(where: { $0.sheetId == sheet.id })?.sheetTempId
			if let id = sheetTempId, let index = self.sheetsTemp.index(where: { $0.id == id }) {
				self.collectionView.insertItems(at: [IndexPath(row: index, section: 0)])
			}
		}
	}
	
	func didCloseNewOrEditIphoneController() {
		presentedViewController?.dismiss(animated: true, completion: nil)
		delegate?.didCloseCustomSheet()
	}
	
	func didPressDone(text: String) {
		buildSheets(fromText: text)
		checkAddButton()
	}
	
	
	
	// MARK: - Submit Observer Functions
	
	override func handleRequestFinish(requesterId: String, result: AnyObject?) {
		Queues.main.async {
			self.sheetsTemp.forEach({ $0.delete(false) })
			self.clusterTemp?.delete(true)
			self.delegate?.didCloseCustomSheet()
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
	
	func didDeleteSheet(sheet: Sheet) {
		
		if let sheetId = sheetHasSheet.first(where: { $0.sheetTempId == sheet.id })?.sheetId, let sheet = sheets.first(where: { $0.id == sheetId }) {
			if let index = sheets.index(where: { $0 == sheet }) {
				sheets.delete(entity: sheet)
				collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
			}
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
			self.collectionView.reloadData()
		}
		checkAddButton()
	}
	
	func didSaveSongWith() {
		clusterTemp?.hasTheme = selectedTheme
		
		if let cluster = cluster {
			clusterTemp?.mergeSelfInto(cluster: cluster)
		}

		for sheet in sheetsTemp {
			if let sheetId = sheetHasSheet.first(where: { $0.sheetTempId == sheet.id })?.sheetId, let sheetOriginal = sheets.first(where: { $0.id == sheetId }) {
				sheet.mergeSelfInto(sheet: sheetOriginal)
				if let theme = sheet.hasTheme, let originalTheme = sheetOriginal.hasTheme {
					theme.mergeSelfInto(theme: originalTheme, sheetType: sheet.type)
				}
			}
		}
		
		cluster?.hasSheets = NSSet(array: sheets)
		cluster?.hasTheme = selectedTheme
		
		if let cluster = cluster {
			let method: RequestMethod = cluster.isTemp ? .post : .put
			ClusterSubmitter.submit([cluster], requestMethod: method)
		} else {
			Queues.main.async {
				self.dismiss(animated: true)
			}
		}
	}
	
	
	
	// MARK: - Private functions
	
	private func setup() {
		
		ClusterSubmitter.addObserver(self)
		
		selectedTheme = cluster?.hasTheme

		if clusterTemp == nil {
			cluster = CoreCluster.createEntityNOTsave()
			clusterTemp = CoreCluster.createEntityNOTsave()
			clusterTemp?.deleteDate = NSDate()
		}
		save.title = Text.Actions.save
		cancel.title = Text.Actions.cancel
		addSheetButton?.backgroundColor = themeHighlighted
		addSheetButton?.setTitleColor(themeWhiteBlackTextColor, for: .normal)
		addSheetButton?.layer.cornerRadius = 5
		addLyricsButton?.backgroundColor = themeHighlighted
		addLyricsButton?.setTitleColor(themeWhiteBlackTextColor, for: .normal)
		addLyricsButton?.layer.cornerRadius = 5
		
		navigationController?.title = Text.CustomSheets.title
		title = Text.CustomSheets.title
		view.backgroundColor = themeWhiteBlackBackground
		
		hideKeyboardWhenTappedAround()
		
		longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
		longPressGesture.minimumPressDuration = 1
		collectionView.addGestureRecognizer(longPressGesture)
		
		collectionViewThemes.register(UINib(nibName: Cells.themeCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.themeCellCollection)
		
		CoreTheme.predicates.append("isHidden", notEquals: true)
		themes = CoreTheme.getEntities()
		
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.scrollDirection = (UIDevice.current.userInterfaceIdiom == .pad) ? .horizontal : .vertical
		layout.itemSize = sheetSize
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 30
		collectionView.collectionViewLayout = layout
		collectionView.register(UINib(nibName: SheetCollectionCell.identitier, bundle: nil), forCellWithReuseIdentifier: SheetCollectionCell.identitier)
		
		update()
	}
	
	private func update() {
		removeRedBorder()
		checkAddButton()
		collectionViewThemes.reloadData()
		collectionView.reloadData()
	}
	
	private func checkAddButton() {
		let isSong = (clusterTemp?.isTypeSong ?? false) && getTextFromSheets().length > 0
		let isCustom = sheetsTemp.contains(where: { $0.hasTheme?.isHidden == true })
		
		edit?.isEnabled = !isSong
		edit?.tintColor = isSong ? .clear : themeHighlighted

//		if !isNew || isEdited {
//			if cluster?.isTypeSong ?? clusterTemp?.isTypeSong ?? false {
//				addSheetButton?.removeFromSuperview()
//			} else {
//				addLyricsButton?.removeFromSuperview()
//			}
//		}
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
	
	private func buildSheets(fromText: String) {
		let newCluster: Cluster?
		if cluster == nil {
			newCluster = CoreCluster.createEntityNOTsave()
		} else {
			newCluster = cluster?.tempVersion
		}
		
		newCluster?.deleteDate = nil
		newCluster?.hasTheme = selectedTheme
		
		var contentToDevide = fromText + "\n\n"
		
		// get title
		if let range = contentToDevide.range(of: "\n\n") {
			let start = contentToDevide.index(contentToDevide.startIndex, offsetBy: 0)
			let rangeSheet = start..<range.lowerBound
			let rangeRemove = start..<range.upperBound
			newCluster?.title = String(contentToDevide[rangeSheet])
			contentToDevide.removeSubrange(rangeRemove)
		}
		
		var position: Int16 = 0
		var newSheets: [Sheet] = []
		// get sheets
		while let range = contentToDevide.range(of: "\n\n") {
			
			// get content
			let start = contentToDevide.index(contentToDevide.startIndex, offsetBy: 0)
			let rangeSheet = start..<range.lowerBound
			let rangeRemove = start..<range.upperBound
			
			let sheetLyrics = String(contentToDevide[rangeSheet])
			var sheetTitle: String = Text.NewSong.NoTitleForSheet
			
			// get title
			if let rangeTitle = contentToDevide.range(of: "\n") {
				let startTitle = contentToDevide.index(contentToDevide.startIndex, offsetBy: 0)
				let rangeSheetTitle = startTitle..<rangeTitle.lowerBound
				sheetTitle = String(contentToDevide[rangeSheetTitle])
			}
			
			let newSheet = CoreSheetTitleContent.createEntityNOTsave()
			newSheet.title = sheetTitle
			newSheet.content = sheetLyrics
			newSheet.position = position
			
			newSheets.append(newSheet)
			
			contentToDevide.removeSubrange(rangeRemove)
			position += 1
		}
		
		newSheets.sort{ $0.position < $1.position }
		
		if let sheets = newSheets as? [SheetTitleContentEntity] {
			for tempSheet in sheets {
				let sheet = CoreSheetTitleContent.createEntityNOTsave()
				sheet.title = tempSheet.title
				sheet.content = tempSheet.content
				sheet.position = tempSheet.position
				newCluster?.addToHasSheets(sheet)
			}
		}
		sheets = newSheets
		clusterTemp = newCluster
		isEdited = true
		updateWithAnimation()
	}
	
	private func getTextFromSheets() -> String {
		if let sheets = sheetsTemp as? [SheetTitleContentEntity], sheetsTemp.count != 0 {
			var totalString = (cluster?.title ?? "") + "\n\n"
			let tempSheets:[SheetTitleContentEntity] = sheets.count > 0 ? sheets : cluster?.hasSheetsArray as? [SheetTitleContentEntity] ?? []
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
	
	private func updateWithAnimation() {
		self.collectionView.alpha = 0
		UIView.animate(withDuration: 0.3, animations: {
		}) { _ in
			self.update()
			self.collectionView.layer.setAffineTransform(CGAffineTransform(translationX: 1, y: -6))
			UIView.animate(withDuration: 1, animations: {
				self.collectionView.alpha = 1
				self.collectionView.layer.setAffineTransform(CGAffineTransform.identity)
			})
		}
	}
	
	private func hasThemeSelected() -> Bool {
		if selectedTheme != nil {
			removeRedBorder()
			return true
		} else {
			collectionViewThemes.layer.borderColor = UIColor.red.cgColor
			collectionViewThemes.layer.borderWidth = 2
			collectionViewThemes.layer.cornerRadius = 5
			collectionViewThemes.shake()
			return false
		}
	}
	
	private func removeRedBorder() {
		collectionViewThemes.layer.borderColor = nil
		collectionViewThemes.layer.borderWidth = 0
		collectionViewThemes.layer.cornerRadius = 0
	}

	
	// MARK: - IBAction functions
	
	@IBAction func cancel(_ sender: UIBarButtonItem) {
		// remove all
		if cluster?.isTemp ?? false {
			cluster?.delete(true)
		}
		clusterTemp?.delete(true)
		for sheet in sheetsTemp {
			sheet.delete(false)
		}
		dismiss(animated: true)
	}
	
	@IBAction func savedPressed(_ sender: UIBarButtonItem) {
		if hasThemeSelected() {
			performSegue(withIdentifier: "saveNewSongSegue", sender: self)
		}
	}
	
	@IBAction func saveIphonePressed(_ sender: UIBarButtonItem) {
		if hasThemeSelected() {
			performSegue(withIdentifier: "saveNewSongSegue", sender: self)
		}
	}
	
	@IBAction func editPressed(_ sender: UIBarButtonItem) {
		guard let controller = storyboard?.instantiateViewController(withIdentifier: "SheetPickerMenuController") as? SheetPickerMenuController else {
			return
		}
		
		let isSong = (clusterTemp?.isTypeSong ?? false) && getTextFromSheets().length > 0
		let isCustom = sheetsTemp.contains(where: { $0.hasTheme?.isHidden == true })

		controller.didCreateSheet = didCreate(sheet:)
		controller.selectedTheme = selectedTheme
		controller.delegate = self
		controller.mode = isSong ? .song : isCustom ? .custom : .none
		controller.lyricsControllerDelegate = self
		controller.text = getTextFromSheets()
		
		let rect = view.bounds.insetBy(dx: view.bounds.width / 10, dy: view.bounds.height / 10)
		controller.preferredContentSize = rect.size
		
		controller.modalPresentationStyle = .popover
		controller.popoverPresentationController?.delegate = self
		controller.popoverPresentationController?.barButtonItem = edit
		
		present(controller, animated: true, completion: nil)
		return
//
//		if (clusterTemp?.isTypeSong ?? false) && getTextFromSheets().length > 0 {
//			self.performSegue(withIdentifier: "ChangeLyricsSegue", sender: self)
//			return
//		}
//
//		let hasLyrics = getTextFromSheets() != ""
//
//		let optionsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//
//		let changeGeneralSettings = UIAlertAction(title: Text.NewSong.changeTitleTime, style: .default) { _ in
//			self.performSegue(withIdentifier: "changeTitleTimeSegue", sender: self)
//		}
//		let addSheet = UIAlertAction(title: Text.NewSong.addSheet, style: .default) { _ in
//			self.performSegue(withIdentifier: "SheetPickerMenuControllerSegue", sender: self)
//		}
//		let changeLyrics = UIAlertAction(title: hasLyrics ? Text.NewSong.changeLyrics : Text.NewSong.newLyrics, style: .default) { _ in
//			self.performSegue(withIdentifier: "ChangeLyricsSegue", sender: self)
//		}
//		let cancel = UIAlertAction(title: Text.Actions.cancel, style: .cancel)
//
//		if sheetsTemp.count == 0 {
//			optionsMenu.addAction(addSheet)
//			optionsMenu.addAction(changeLyrics)
//		} else {
//			if sheetsTemp.contains(where: { $0.hasTheme?.isHidden == true }) {
//				optionsMenu.addAction(addSheet)
//				optionsMenu.addAction(changeGeneralSettings)
//			} else {
//				optionsMenu.addAction(changeLyrics)
//			}
//		}
//		optionsMenu.addAction(cancel)
//
//		present(optionsMenu, animated: true)
	}
	
}

extension CustomSheetsController: UIPopoverPresentationControllerDelegate {
	
	func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}
	
}
