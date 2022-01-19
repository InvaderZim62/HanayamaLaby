//
//  HandleView.swift
//  HanayamaLaby
//
//  Created by Phil Stern on 1/17/22.
//

import UIKit

class HandleView: UIView {
    
    var probeOffset: CGFloat = 0  // percent offset from top
    
    private lazy var probeCenter = CGPoint(x: bounds.midX, y: probeOffset * bounds.height)  // position in HandleView coordinates
    
    var probePositionInSuperview: CGPoint {
        convert(probeCenter, to: superview)
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
        let handle = UIBezierPath(roundedRect: bounds, cornerRadius: 4)
        Constants.handleColor.setFill()
        handle.fill()
        
        let probe = UIBezierPath(arcCenter: probeCenter,
                                  radius: Constants.probeRadius,
                                  startAngle: 0,
                                  endAngle: 2 * CGFloat.pi,
                                  clockwise: true)
        Constants.probeColor.setFill()
        probe.fill()
    }
}
