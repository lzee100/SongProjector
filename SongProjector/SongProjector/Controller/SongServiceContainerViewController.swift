//
//  SongServiceContainerViewController.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17-06-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class SongServiceContainerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	@IBOutlet var collectionView: UICollectionView!
	var songService: SongService!
	var selectedSong: SongObject { return songService.selectedSong! }

	override func viewDidLoad() {
        super.viewDidLoad()
		
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .horizontal
		layout.minimumLineSpacing = 5
		layout.minimumInteritemSpacing = 5
		layout.sectionInset = UIEdgeInsets(top: 0, left: collectionView.bounds.width - (250 * externalDisplayWindowRatioHeightWidth), bottom: 0, right: collectionView.bounds.width - (250 * externalDisplayWindowRatioHeightWidth))
		collectionView.collectionViewLayout = layout
		
		collectionView.register(UINib(nibName: Cells.sheetCollectionCell, bundle: nil), forCellWithReuseIdentifier: Cells.sheetCollectionCell)
		collectionView.reloadData()
    }
	
	func transForm(cell: UICollectionViewCell) {
		let coverView = cell.convert(cell.bounds, to: self.view)
		
		
		
		let transFormOffsetXMax = collectionView.bounds.width * 22/30
		let transFormOffsetXMin = collectionView.bounds.width * 8/30
		
		if coverView.minX < transFormOffsetXMin {
			let percent = getPercent(value: (transFormOffsetXMin - coverView.minX) / transFormOffsetXMin)
			
			let maxScaleDifference: CGFloat = 0.5
			let scale = percent * maxScaleDifference
			
			let scaling = CGAffineTransform(scaleX: 1-scale, y: 1-scale)
			let positioning = CGAffineTransform(translationX: 1+scale, y: 1)
			cell.transform = scaling.concatenating(positioning)
			
		} else {
			let percent = getPercent(value: (coverView.maxX - transFormOffsetXMax) / (collectionView.bounds.width - transFormOffsetXMax))
			
			let maxScaleDifference: CGFloat = 0.5
			let scale = percent * maxScaleDifference
			cell.transform = CGAffineTransform(scaleX: 1-scale, y: 1-scale)
		}
		
	}
	
	func getPercent(value: CGFloat) -> CGFloat {
		let lowerBound: CGFloat = 0
		let upperBound: CGFloat = 1
		
		if value < lowerBound {
			return lowerBound
		}
		
		if value > upperBound {
			return upperBound
		}
		
		return value
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return selectedSong.sheets.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.sheetCollectionCell, for: indexPath)
		
//		if let collectionCell = collectionCell as? SheetCollectionCell {
////			collectionCell.previewView.addSubview(SheetView.createWith(frame: collectionView.frame, cluster: selectedSong.cluster, sheet: selectedSong.sheets[indexPath.row], tag: selectedSong.sheets[indexPath.row].hasTag, scaleFactor: 1, isPreview: true, position: indexPath.row, toExternalDisplay: false))
//		}
		transForm(cell: collectionCell)
		return collectionCell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 240 * externalDisplayWindowRatioHeightWidth, height: 240)
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		collectionView.visibleCells.forEach { transForm(cell: $0) }
	}
	
	
	
	
	
}
