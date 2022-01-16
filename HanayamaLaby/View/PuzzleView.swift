//
//  PuzzleView.swift
//  HanayamaLaby
//
//  Created by Phil Stern on 1/15/22.
//

import UIKit

class PuzzleView: UIView {
    
    var ringRadiusFactors = [Double]()
    var spokes = [Spoke]()
    var arcs = [Arc]()
    
    lazy var puzzleCenter = CGPoint(x: bounds.midX, y: bounds.midY)

    override func draw(_ rect: CGRect) {
        drawSpokes()
        drawArcs()
    }
    
    private func drawSpokes() {
        for spoke in spokes {
            let innerRadius = ringRadiusFactors[spoke.innerRing] * bounds.width / 2
            let outerRadius = ringRadiusFactors[spoke.outerRing] * bounds.width / 2
            let innerEnd = CGPoint(x: puzzleCenter.x + innerRadius * cos(spoke.angle),
                                   y: puzzleCenter.y + innerRadius * sin(spoke.angle))
            let outerEnd = CGPoint(x: puzzleCenter.x + outerRadius * cos(spoke.angle),
                                   y: puzzleCenter.y + outerRadius * sin(spoke.angle))
            let line = UIBezierPath()
            line.move(to: innerEnd)
            line.addLine(to: outerEnd)
            line.lineWidth = 5
            UIColor.red.setStroke()
            line.stroke()
        }
    }
    
    private func drawArcs() {
        for arc in arcs {
            let radius = ringRadiusFactors[arc.ring] * bounds.width / 2
            let arc = UIBezierPath(arcCenter: puzzleCenter,
                                   radius: radius,
                                   startAngle: arc.startAngle,
                                   endAngle: arc.endAngle,
                                   clockwise: true)
            arc.lineWidth = 5
            UIColor.red.setStroke()
            arc.stroke()
        }
    }
}
