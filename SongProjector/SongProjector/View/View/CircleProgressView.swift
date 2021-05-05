//
//  CircleProgressView.swift
//  SongProjector
//
//  Created by Leo van der Zee on 28/06/2020.
//  Copyright © 2020 iozee. All rights reserved.
//

import Foundation
import UIKit

class CircleProgressView: UIView {
    
    private var circleLayer: CAShapeLayer!
    var progressColor: UIColor = themeHighlighted
    var strokeWidth: CGFloat = 6.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        layer.addSublayer(circleLayer)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        layer.addSublayer(circleLayer)
        self.backgroundColor = UIColor.clear
    }
    
    private func setupView() {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.width - 10)/2, startAngle: 0.0, endAngle: CGFloat(Double.pi * 2.0), clockwise: true)

        circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = progressColor.cgColor
        circleLayer.lineWidth = strokeWidth
        circleLayer.cornerRadius = 3.0/2
        circleLayer.strokeEnd = 0.0

    }
    
    func reset() {
        circleLayer.removeAllAnimations()
    }
    
    func setProgress(percentage: CGFloat) {

        let animation = CABasicAnimation(keyPath: "strokeEnd")

        animation.fromValue = circleLayer.strokeEnd
        animation.toValue = percentage / 100
        animation.beginTime = CACurrentMediaTime()
        animation.duration = 0.001

        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)

        circleLayer.strokeEnd = percentage / 100
        circleLayer.lineCap = .round

        circleLayer.add(animation, forKey: "animateCircle")
    }
}
