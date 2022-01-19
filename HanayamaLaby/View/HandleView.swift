//
//  HandleView.swift
//  HanayamaLaby
//
//  Created by Phil Stern on 1/17/22.
//

import UIKit

class HandleView: UIView {
    
    var probeOffset: CGFloat = 0  // percent face length offset from top
    
    private lazy var probeCenter = CGPoint(x: bounds.midX, y: probeOffset * Constants.faceLength)  // position in HandleView coordinates
    private lazy var tailCenter = CGPoint(x: bounds.midX, y: Constants.handleLength - Constants.tailLength)

    var probePositionInSuperview: CGPoint {
        convert(probeCenter, to: superview)
    }
    
    var tailPositionInSuperview: CGPoint {
        convert(tailCenter, to: superview)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false  // makes background clear, instead of black
    }

    required init?(coder: NSCoder) {  // called for views created in storyboard
        self.probeOffset = 0
        super.init(coder: coder)
    }

    override func draw(_ rect: CGRect) {
        let handle = UIBezierPath()
        handle.move(to: CGPoint(x: 0, y: 10))  // 10: offset more than corner radius, to keep corners round
        handle.addLine(to: CGPoint(x: 0, y: bounds.height - 10))
        handle.move(to: CGPoint(x: bounds.width, y: 10))
        handle.addLine(to: CGPoint(x: bounds.width, y: bounds.height - 10))
        handle.lineWidth = 4
        Constants.handleColor.setStroke()
        handle.stroke()
        
        let face = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.width, height: Constants.faceLength), cornerRadius: 4)
        Constants.handleColor.setFill()
        face.fill()
        
        let probe = UIBezierPath(arcCenter: probeCenter,
                                  radius: Constants.probeRadius,
                                  startAngle: 0,
                                  endAngle: 2 * CGFloat.pi,
                                  clockwise: true)
        Constants.probeColor.setFill()
        probe.fill()
        
        let tail = UIBezierPath(roundedRect: CGRect(x: 0,
                                                    y: Constants.handleLength - Constants.tailLength,
                                                    width: bounds.width,
                                                    height: Constants.tailLength), cornerRadius: 4)
        Constants.probeColor.setFill()
        tail.fill()
    }
}
