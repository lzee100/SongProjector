//
//  SheetCollectionCell.swift
//  SongProjector
//
//  Created by Leo van der Zee on 04-01-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import UIKit

class SheetCollectionCell: UICollectionViewCell {

	@IBOutlet var deleteIcon: UIImageView!
	@IBOutlet var deleteButton: UIButton!
	
	static let identitier: String = "SheetCollectionCell"
	
	var isDeleteEnabled: Bool = false
	var didDeleteSheet: ((VSheet) -> Void)?
	var sheet: VSheet!
	
	override func prepareForReuse() {
		for subView in subviews {
			if subView.tag == 7 {
				subView.removeFromSuperview()
			}
		}
	}
	
	private var customRatioConstraint = NSLayoutConstraint()
	
    func setupWith(cluster: VCluster?, sheet: VSheet, theme: VTheme?, didDeleteSheet: ((VSheet) -> Void)?, isDeleteEnabled: Bool = true, scaleFactor: CGFloat = 1) {
		self.sheet = sheet
		self.didDeleteSheet = didDeleteSheet
		self.isDeleteEnabled = isDeleteEnabled
		animateIcon()
		update()
        let view = SheetView.createWith(frame: self.bounds, cluster: cluster, sheet: sheet, theme: theme, scaleFactor: scaleFactor)
		view.tag = 7
		self.addSubview(view)
		sendSubviewToBack(view)
        self.clipsToBounds = false
	}
	
	private func update() {
        deleteIcon.tintColor = .red1
		deleteIcon.isHidden = !isDeleteEnabled
	}
	
	@IBAction func deleteButtonPressed(_ sender: UIButton) {
		didDeleteSheet?(sheet)
	}
	
	func animateIcon() {
		self.deleteIcon.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
		UIView.animate(withDuration: 1,
					   delay: 0,
					   usingSpringWithDamping: 0.2,
					   initialSpringVelocity: 3,
					   options: .curveEaseIn,
					   animations: {
						self.deleteIcon.transform = CGAffineTransform.identity
		})
	}
	
}
