//
//  PuzzleView.swift
//  HanayamaLaby
//
//  Created by Phil Stern on 1/15/22.
//

import UIKit

struct PuzzleConst {
    static let wallWidth: CGFloat = 10
    static let wallColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
}

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
            line.lineWidth = PuzzleConst.wallWidth
            PuzzleConst.wallColor.setStroke()
            line.stroke()
        }
    }
    
    private func drawArcs() {
        for arc in arcs {
            let radius = ringRadiusFactors[arc.ring] * bounds.width / 2
            let line = UIBezierPath(arcCenter: puzzleCenter,
                                    radius: radius,
                                    startAngle: arc.startAngle,
                                    endAngle: arc.endAngle,
                                    clockwise: true)
            line.lineWidth = PuzzleConst.wallWidth
            PuzzleConst.wallColor.setStroke()
            line.stroke()
            let startPoint = CGPoint(x: puzzleCenter.x + radius * cos(arc.startAngle),
                                     y: puzzleCenter.y + radius * sin(arc.startAngle))
            drawWallEndAtPoint(startPoint)
            let endPoint = CGPoint(x: puzzleCenter.x + radius * cos(arc.endAngle),
                                   y: puzzleCenter.y + radius * sin(arc.endAngle))
            drawWallEndAtPoint(endPoint)
        }
    }
    
    private func drawWallEndAtPoint(_ point: CGPoint) {
        let circle = UIBezierPath(arcCenter: point,
                                  radius: PuzzleConst.wallWidth / 2,
                                  startAngle: 0,
                                  endAngle: 2 * CGFloat.pi,
                                  clockwise: true)
        PuzzleConst.wallColor.setFill()
        circle.fill()
    }
}
