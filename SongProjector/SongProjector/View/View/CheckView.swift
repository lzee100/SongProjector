//
//  CheckView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 16/11/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import UIKit

class CheckView: UIView {
    
    var lineWidth: CGFloat = 3
    private var shapeLayer: CAShapeLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = nil
    }
    
    func setup() {
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        self.layer.borderWidth = 2
    }
    
    func drawLine(skipAnimation: Bool) {
        
        layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        self.shapeLayer?.path = nil
        self.layoutIfNeeded()
        self.layer.borderColor = nil
        self.layer.borderWidth = 0
        
        
        // create shape layer for that path
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer.strokeColor = UIColor.green1.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.path = getPath()
        shapeLayer.position = CGPoint(x: 0, y: 0)
        
        // animate it
        layer.addSublayer(shapeLayer)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = 0.2
        
        if !skipAnimation {
            shapeLayer.add(animation, forKey: "drawFilledLine")
        }
        
        self.shapeLayer = shapeLayer
        
        
    }
    
    public func getPath() -> CGPath {
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: bounds.width * 0.2, y: bounds.height / 2))
        
        path.addLine(to: CGPoint(x: bounds.width / 2.5, y: bounds.height * 0.7))
        
        path.addLine(to: CGPoint(x: bounds.width * 0.8, y: bounds.height * 0.3))
        
        return path.cgPath
    }
    
}
