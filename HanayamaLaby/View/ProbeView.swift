//
//  ProbeView.swift
//  HanayamaLaby
//
//  Created by Phil Stern on 1/17/22.
//

import UIKit

struct ProbeConst {
    static let probeRadius: CGFloat = 2.5
    static let probeColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
}

class ProbeView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false  // makes background clear, instead of black
    }

    required init?(coder: NSCoder) {  // called for views created in storyboard
        super.init(coder: coder)
    }

    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let circle = UIBezierPath(arcCenter: center,
                                  radius: bounds.width / 2,
                                  startAngle: 0,
                                  endAngle: 2 * CGFloat.pi,
                                  clockwise: true)
        ProbeConst.probeColor.setFill()
        circle.fill()
    }
}
