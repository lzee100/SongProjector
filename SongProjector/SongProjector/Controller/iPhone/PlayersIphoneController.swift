//
//  PlayersIphoneController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 04-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class PlayersIphoneController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	@IBOutlet var collectionView: UICollectionView!
	
	var songTitle = ""
	var tag: Tag?
	var sheets: [Sheet] = []
	var multiplier: CGFloat = 4/3
	var sheetSize = CGSize(width: 375, height: 281)
	var sheetPreviewView = SheetView()
	var isFirstTime = true
	var delay = 0.0
	
	
	override func viewDidLoad() {
        super.viewDidLoad()

        setup()
		
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		collectionView.reloadData()
	}

	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return sheets.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.sheetCollectionCell, for: indexPath)
		
		if let collectionCell = collectionCell as? SheetCollectionCell {
			collectionCell.setPreviewViewAspectRatioConstraint(multiplier: multiplier)

			let view = buildSheetViewFor(title: songTitle, sheet: sheets[indexPath.row], tag: tag, frame: collectionCell.bounds)
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
		if indexPath.row == sheets.count - 1 {
			isFirstTime = false
		}
		return collectionCell
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return sheetSize
	}
    

	private func setup() {
		
		collectionView.register(UINib(nibName: Cells.sheetCollectionCell, bundle: nil), forCellWithReuseIdentifier: Cells.sheetCollectionCell)
		CoreCluster.predicates.append("title", equals: "Weereen")
		let song = CoreCluster.getEntities().first
		let defaults = UserDefaults.standard
		multiplier = CGFloat(defaults.float(forKey: "lastScreenRatioHeightWidth"))
		let cellHeight = multiplier * 375
		sheetSize = CGSize(width: 375, height: cellHeight)
		
		print(sheetSize)
		
		title = Text.Players.title
		if let sheets = song?.hasSheetsArray {
			self.sheets = sheets
		}
		self.tag = song?.hasTag
		songTitle = song?.title ?? ""
		
		sheetPreviewView = buildSheetViewFor(title: songTitle, sheet: sheets.first, tag: tag, frame: CGRect(x: 0, y: 0, width: sheetSize.width, height: sheetSize.height))

		collectionView.reloadData()
		
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
	
	private func sheetViewFor(indexPath: IndexPath) -> UIView {
		sheetPreviewView.lyrics = sheets[indexPath.row].lyrics
		sheetPreviewView.update()
		return sheetPreviewView
	}

}
