//
//  ErrorAnimationView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 18/11/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import UIKit

class ErrorAnimationView: UIView {
    
    var lineWidth: CGFloat = 6
    
    private var shapeLayer: CAShapeLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = nil
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
        shapeLayer.strokeColor = UIColor.red1.cgColor
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
        
        path.move(to: CGPoint(x: bounds.width * 0.2, y: bounds.height * 0.2))
        
        path.addLine(to: CGPoint(x: bounds.width * 0.8, y: bounds.height * 0.8))
        
        path.move(to: CGPoint(x: bounds.width * 0.8, y: bounds.height * 0.2))

        path.addLine(to: CGPoint(x: bounds.width * 0.2, y: bounds.height * 0.8))
        
        return path.cgPath
    }
    
}
