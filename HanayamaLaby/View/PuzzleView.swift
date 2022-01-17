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
    static let floorColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
}

class PuzzleView: UIView {
    
    var ringRadiusFactors = [Double]()
    var spokes = [Spoke]()
    var arcs = [Arc]()
    
    private lazy var puzzleCenter = CGPoint(x: bounds.midX, y: bounds.midY)
//    private lazy var wholeView = UIBezierPath(rect: bounds)  // whole view to append holes in
    
    // rotate about point by translating (from 0,0) to point, rotating, and translating back
    private func transformToRotate(angle: Double, about point: CGPoint) -> CGAffineTransform {
        return CGAffineTransform(translationX: point.x, y: point.y).rotated(by: CGFloat(angle)).translatedBy(x: -point.x, y: -point.y)
    }

    override func draw(_ rect: CGRect) {
        drawFloor()
        drawSpokes()
        drawArcs()
        
//        let mask = CAShapeLayer()
//        mask.fillRule = .evenOdd
//        mask.path = wholeView.cgPath
//        layer.mask = mask
    }
    
    private func drawFloor() {
        let circle = UIBezierPath(arcCenter: puzzleCenter,
                                  radius: 0.48 * bounds.width,
                                  startAngle: 0,
                                  endAngle: 2 * CGFloat.pi,
                                  clockwise: true)
        PuzzleConst.floorColor.setFill()
        circle.fill()
    }
    
    private func drawSpokes() {
        let halfWidth = PuzzleConst.wallWidth / 2
        for spoke in spokes {
            let innerRadius = ringRadiusFactors[spoke.innerRing] * bounds.width / 2 + halfWidth
            let outerRadius = ringRadiusFactors[spoke.outerRing] * bounds.width / 2 - halfWidth
            let rect = CGRect(x: puzzleCenter.x + innerRadius, y: puzzleCenter.y - halfWidth, width: outerRadius - innerRadius, height: PuzzleConst.wallWidth)
            let shape = UIBezierPath(roundedRect: rect, cornerRadius: 0)
            shape.apply(transformToRotate(angle: spoke.angle, about: puzzleCenter))
            PuzzleConst.wallColor.setFill()
            shape.fill()
//            wholeView.append(shape)
        }
    }
    
    private func drawArcs() {
        let halfWidth = PuzzleConst.wallWidth / 2
        for arc in arcs {
            let radius = ringRadiusFactors[arc.ring] * bounds.width / 2
            let shape = UIBezierPath()
            // outer arc
            shape.addArc(withCenter: puzzleCenter,
                         radius: radius + halfWidth,
                         startAngle: arc.startAngle,
                         endAngle: arc.endAngle,
                         clockwise: true)
            // end cap
            let endCenter = CGPoint(x: puzzleCenter.x + radius * cos(arc.endAngle),
                                    y: puzzleCenter.y + radius * sin(arc.endAngle))
            shape.addArc(withCenter: endCenter,
                         radius: halfWidth,
                         startAngle: arc.endAngle,
                         endAngle: arc.endAngle + CGFloat.pi,
                         clockwise: true)
            // inner arc
            shape.addArc(withCenter: puzzleCenter,
                         radius: radius - halfWidth,
                         startAngle: arc.endAngle,
                         endAngle: arc.startAngle,
                         clockwise: false)
            // start cap
            let startCenter = CGPoint(x: puzzleCenter.x + radius * cos(arc.startAngle),
                                      y: puzzleCenter.y + radius * sin(arc.startAngle))
            shape.addArc(withCenter: startCenter,
                         radius: halfWidth,
                         startAngle: arc.startAngle + CGFloat.pi,
                         endAngle: arc.startAngle,
                         clockwise: true)
            PuzzleConst.wallColor.setFill()
            shape.fill()
//            wholeView.append(shape)
        }
    }
}
