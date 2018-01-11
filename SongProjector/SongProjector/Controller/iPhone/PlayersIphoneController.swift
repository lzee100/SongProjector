//
//  PlayersIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 04-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class PlayersIphoneController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIPopoverPresentationControllerDelegate {

	@IBOutlet var new: UIBarButtonItem!
	
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var collectionViewSheets: UICollectionView!
	
	var songTitle = ""
	var tags: [Tag] = []
	var selectedTag: Tag?
	var sheets: [Sheet] = []
	var multiplier: CGFloat = 9/16
	var sheetSize = CGSize(width: 375, height: 281)
	var sheetPreviewView = SheetView()
	var isFirstTime = true
	var delay = 0.0
	
	
	override func viewDidLoad() {
        super.viewDidLoad()

        setup()
		
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		//segue for the popover configuration window
		if segue.identifier == "PlayerMenuSegue" {
				segue.destination.popoverPresentationController!.delegate = self
				segue.destination.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: 180)
		}
	}
	
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		collectionView.reloadData()
	}

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return collectionView == collectionViewSheets ? sheets.count : 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return collectionView == collectionViewSheets ? tags.count : 1
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		if collectionView == collectionViewSheets {
			let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.sheetCollectionCell, for: indexPath)
			
			if let collectionCell = collectionCell as? SheetCollectionCell {
				collectionCell.setPreviewViewAspectRatioConstraint(multiplier: multiplier)
				
				let view = buildSheetViewFor(title: songTitle, sheet: sheets[indexPath.row], tag: selectedTag, frame: collectionCell.bounds)
				collectionCell.previewView.addSubview(view)
				
				if isFirstTime {
					let attributes: UICollectionViewLayoutAttributes = self.collectionView.layoutAttributesForItem(at: indexPath)!
					let frame = attributes.frame
					
					collectionCell.frame = CGRect(x: self.view.bounds.width, y: frame.minY, width: collectionCell.bounds.width, height: collectionCell.bounds.height)
					UIView.animate(withDuration: 0.5, delay: delay, usingSpringWithDamping: 0.4, initialSpringVelocity: 9, options: .curveEaseInOut, animations: {
						collectionCell.frame = CGRect(x: self.collectionView.frame.minX, y: frame.minY, width: collectionCell.bounds.width, height: collectionCell.bounds.height)
					})
					delay += 0.1
				}
			}
			
			let navigationBarHeight = UIApplication.shared.statusBarFrame.height + navigationController!.navigationBar.frame.height
			let tagBarHeight = self.collectionView.bounds.height
			if indexPath.section == Int(round(Double((UIScreen.main.bounds.height - navigationBarHeight - tagBarHeight) / (sheetSize.height + 10)))) - 1 {
				isFirstTime = false
			}
			
			return collectionCell
		} else {
			let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.tagCellCollection, for: indexPath)
			
			if let collectionCell = collectionCell as? TagCellCollection {
				collectionCell.setup(tagName: tags[indexPath.row].title ?? "")
				collectionCell.isSelectedCell = selectedTag?.id == tags[indexPath.row].id
			}
			return collectionCell
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return sheetSize
	}
    

	private func setup() {
		
		collectionView.register(UINib(nibName: Cells.sheetCollectionCell, bundle: nil), forCellWithReuseIdentifier: Cells.sheetCollectionCell)
		collectionView.register(UINib(nibName: Cells.tagCellCollection, bundle: nil), forCellWithReuseIdentifier: Cells.tagCellCollection)

		navigationController?.title = Text.Players.title
		title = Text.Players.title
		view.backgroundColor = themeWhiteBlackBackground
		
		tags = CoreTag.getEntities()
		
		new.title = Text.Actions.new
		
		let cellHeight = multiplier * (UIScreen.main.bounds.width - 20)
		sheetSize = CGSize(width: UIScreen.main.bounds.width - 20, height: cellHeight)
		
		update()
	}
	
	private func update() {
		collectionView.reloadData()
		collectionViewSheets.reloadData()
		isFirstTime = true
	}
	
	
	
	private func buildSheetViewFor(title: String?, sheet: Sheet?, tag: Tag?, displayToBeamer: Bool = false, frame: CGRect) -> SheetView {
		let defaults = UserDefaults.standard
		let view = SheetView(frame: frame)
		view.isEmptySheet = false
		view.selectedTag = tag
		view.songTitle = title
		view.lyrics = sheet?.lyrics
		view.isEditable = true
		if let heightExternalDisplay = defaults.object(forKey: "externalDisplayWindowHeight") as? CGFloat {
			view.scaleFactor = heightExternalDisplay / (frame.size.height * UIScreen.main.scale)
		}
		view.update()
		return view
	}
	@IBAction func showMenu(_ sender: UIBarButtonItem) {
		Menu.showMenu()
	}
	
}
