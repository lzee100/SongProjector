//
//  TableViewCellExtensions.swift
//  SongProjector
//
//  Created by Leo van der Zee on 17-08-18.
//  Copyright © 2018 iozee. All rights reserved.
//

import Foundation
import UIKit

//layerMaxXMaxYCorner – lower right corner
//layerMaxXMinYCorner – top right corner
//layerMinXMaxYCorner – lower left corner
//layerMinXMinYCorner – top left corner

enum LayerCornerRadius {
    case leftTop
    case leftBottom
    case rightTop
    case rightBottom
    case leftTopRightTop
    case leftBottomRightBottom
    case rightTopRightBottom
    case leftTopLeftBottom
    case all
}

extension CALayer {
    
    func setCornerRadius(corners: LayerCornerRadius) {
        cornerRadius = 6
        switch corners {
        case .leftTop: maskedCorners = .layerMinXMinYCorner
        case .leftBottom: maskedCorners = .layerMinXMaxYCorner
        case .rightTop: maskedCorners = .layerMaxXMinYCorner
        case .rightBottom: maskedCorners = .layerMaxXMaxYCorner
        case .leftTopRightTop: maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .leftBottomRightBottom: maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .rightTopRightBottom: maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        case .leftTopLeftBottom: maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        case .all:
            maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
        }
    }
    
    fileprivate func style(tableView: UITableView, forRowAt indexPath: IndexPath) {
        cornerRadius = 6
        masksToBounds = true
        if (indexPath.row == 0), tableView.numberOfRows(inSection: indexPath.section) == 1 {
            setCornerRadius(corners: .rightTopRightBottom)
        } else if (indexPath.row == 0), tableView.numberOfRows(inSection: indexPath.section) > 1 {
            setCornerRadius(corners: .rightTop)
        } else if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
            setCornerRadius(corners: .rightBottom)
        } else {
            cornerRadius = 0
        }
    }
}

extension UIView {
    
    func setCornerRadius(corners: UIRectCorner, frame: CGRect? = nil, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: frame ?? bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func style(tableView: UITableView, forRowAt indexPath: IndexPath) {
        clipsToBounds = true
        layer.style(tableView: tableView, forRowAt: indexPath)
    }

}

extension UITableViewCell {
    
	var tableView: UITableView? {
		var view = self.superview
		while (view != nil && view!.isKind(of: UITableView.self) == false) {
			view = view!.superview
		}
		return view as? UITableView
	}
    
    func setCornerRadiusAsMask(corners: LayerCornerRadius, cornerRadius: CGFloat = 7) {
        subviews.forEach({
            $0.clipsToBounds = true
            $0.backgroundColor = .clear
            $0.layer.setCornerRadius(corners: corners)
        })
        contentView.clipsToBounds = true
        contentView.backgroundColor = .grey0
        contentView.layer.setCornerRadius(corners: corners)
        switch corners {
        case .leftTop, .rightTop, .leftTopRightTop:
            layoutIfNeeded()
            let height: CGFloat = 1 / max(1, UIScreen.main.scale)
            if let view = subviews.first(where: { $0.tag == 999 }) {
                view.backgroundColor = .separatorColor
                view.frame = CGRect(x: 40, y: self.bounds.height - 1, width: view.bounds.width, height: height)
            } else {
                let view = UIView(frame: CGRect(x: 40, y: self.bounds.height - 1, width: bounds.width - 80, height: height))
                view.tag = 999
                view.backgroundColor = .separatorColor
                addSubview(view)
            }
        default: subviews.first(where: { $0.tag == 999 })?.removeFromSuperview()
        }
    }
    
    func setBorderMask() {
        subviews.forEach({
            $0.clipsToBounds = false
            $0.backgroundColor = .clear
            $0.layer.maskedCorners = []
        })
        contentView.backgroundColor = .grey0
        let height: CGFloat = 1 / max(1, UIScreen.main.scale)
        layoutIfNeeded()
        if let view = subviews.first(where: { $0.tag == 999 }) {
            view.backgroundColor = .separatorColor
            view.frame = CGRect(x: 40, y: self.bounds.height - 1, width: view.bounds.width, height: height)
        } else {
            let view = UIView(frame: CGRect(x: 40, y: self.bounds.height - 1, width: bounds.width - 80, height: height))
            view.tag = 999
            view.backgroundColor = .separatorColor
            addSubview(view)
        }
    }
    
}
