//
//  ViewController.swift
//  HanayamaLaby
//
//  Created by Phil Stern on 1/15/22.
//

import UIKit

struct Constants {
    static let probeRadius: CGFloat = 2.5
    static let handleWidth: CGFloat = 5 * probeRadius
    static let handleHeight: CGFloat = 50
    static let probeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let handleColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
}

class ViewController: UIViewController {

    let backHandleView = HandleView()
    let frontHandleView = HandleView()

    @IBOutlet weak var backPuzzleView: PuzzleView!
    @IBOutlet weak var frontPuzzleView: PuzzleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backPuzzleView)
        createHandleViews()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(screenPanned))
        view.addGestureRecognizer(panGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateViewFromModel()
    }
    
    private func updateViewFromModel() {
        backPuzzleView.ringRadiusFactors = backPuzzle.ringRadiusFactors
        backPuzzleView.spokes = backPuzzle.spokes
        backPuzzleView.arcs = backPuzzle.arcs
        
        frontPuzzleView.ringRadiusFactors = frontPuzzle.ringRadiusFactors
        frontPuzzleView.spokes = frontPuzzle.spokes
        frontPuzzleView.arcs = frontPuzzle.arcs
        
        backHandleView.center = backPuzzleView.center
        frontHandleView.center = frontPuzzleView.center
    }
    
    private func createHandleViews() {
        backHandleView.frame = CGRect(x: 0, y: 0, width: Constants.handleWidth, height: Constants.handleHeight)
        backHandleView.probeOffset = 0.85
        view.addSubview(backHandleView)

        frontHandleView.frame = CGRect(x: 0, y: 0, width: Constants.handleWidth, height: Constants.handleHeight)
        frontHandleView.probeOffset = 0.15
        view.addSubview(frontHandleView)
    }
    
    @objc private func screenPanned(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        // try moving first, then determine if it should not have
        let pastBackHandleViewCenter = backHandleView.center
        backHandleView.center = (backHandleView.center + translation).limitedToView(view, withInset: 20)  // in view coordinates
        let backProbePositionInPuzzleCoords = view.convert(backHandleView.probePositionInSuperview, to: backPuzzleView)

        let pastFrontHandleViewCenter = frontHandleView.center
        frontHandleView.center = (frontHandleView.center + translation).limitedToView(view, withInset: 20)  // in view coordinates
        let frontProbePositionInPuzzleCoords = view.convert(frontHandleView.probePositionInSuperview, to: frontPuzzleView)
        
        if backPuzzleView.wallPath.contains(backProbePositionInPuzzleCoords) ||
            frontPuzzleView.wallPath.contains(frontProbePositionInPuzzleCoords) {
            // handle probe inside a wall (reset its position)
            backHandleView.center = pastBackHandleViewCenter
            frontHandleView.center = pastFrontHandleViewCenter
        }
        recognizer.setTranslation(.zero, in: view)
    }

    let backPuzzle =
    Puzzle(
        spokes: [
            Spoke(innerRing: 1, outerRing: 2, angle: -1.60),
            Spoke(innerRing: 0, outerRing: 1, angle: -2.06),
            Spoke(innerRing: 2, outerRing: 3, angle: -2.32),
            Spoke(innerRing: 1, outerRing: 3, angle: -2.64),
            Spoke(innerRing: 0, outerRing: 1, angle:  3.08),
            Spoke(innerRing: 2, outerRing: 3, angle:  2.95),
            Spoke(innerRing: 1, outerRing: 2, angle:  2.91),
            Spoke(innerRing: 0, outerRing: 1, angle:  2.48),
            Spoke(innerRing: 2, outerRing: 3, angle:  1.93),
            Spoke(innerRing: 1, outerRing: 2, angle:  1.78),
            Spoke(innerRing: 1, outerRing: 2, angle:  0.66),
            Spoke(innerRing: 1, outerRing: 2, angle:  0.52),
            Spoke(innerRing: 2, outerRing: 3, angle:  0.42),
            Spoke(innerRing: 0, outerRing: 2, angle: -0.52),
            Spoke(innerRing: 2, outerRing: 3, angle: -0.91)
        ],
        arcs: [
            Arc(ring: 3, startAngle: -2.39, endAngle: -1.21),
            Arc(ring: 3, startAngle: -3.11, endAngle: -2.64),
            Arc(ring: 3, startAngle:  2.90, endAngle:  2.96),
            Arc(ring: 3, startAngle:  0.64, endAngle:  2.66),
            Arc(ring: 3, startAngle: -0.63, endAngle:  0.42),
            Arc(ring: 3, startAngle: -0.98, endAngle: -0.88),
            Arc(ring: 2, startAngle: -2.38, endAngle: -1.23),
            Arc(ring: 2, startAngle:  2.84, endAngle: -2.91),
            Arc(ring: 2, startAngle: -0.01, endAngle:  2.58),
            Arc(ring: 2, startAngle: -0.99, endAngle: -0.26),
            Arc(ring: 1, startAngle: -1.71, endAngle: -0.87),
            Arc(ring: 1, startAngle: -2.80, endAngle: -2.06),
            Arc(ring: 1, startAngle:  2.87, endAngle: -3.14),
            Arc(ring: 1, startAngle:  2.19, endAngle:  2.51),
            Arc(ring: 1, startAngle:  1.66, endAngle:  1.85),
            Arc(ring: 1, startAngle:  0.20, endAngle:  1.29),
            Arc(ring: 1, startAngle: -0.52, endAngle: -0.16),
            Arc(ring: 0, startAngle:  3.08, endAngle: -2.60),
            Arc(ring: 0, startAngle:  2.48, endAngle:  2.66),
            Arc(ring: 0, startAngle: -2.06, endAngle:  1.98)
        ]
    )

    let frontPuzzle =
    Puzzle(
        spokes: [
            Spoke(innerRing: 2, outerRing: 3, angle: -1.22),
            Spoke(innerRing: 0, outerRing: 1, angle: -0.56),
            Spoke(innerRing: 1, outerRing: 2, angle: -0.08),
            Spoke(innerRing: 2, outerRing: 3, angle:  1.30),
            Spoke(innerRing: 0, outerRing: 1, angle:  1.51),
            Spoke(innerRing: 1, outerRing: 2, angle:  1.57),
            Spoke(innerRing: 2, outerRing: 3, angle:  2.37),
            Spoke(innerRing: 1, outerRing: 2, angle:  2.54),
            Spoke(innerRing: 0, outerRing: 1, angle:  2.84),
            Spoke(innerRing: 2, outerRing: 3, angle: -2.59),
            Spoke(innerRing: 1, outerRing: 2, angle: -2.10),
            Spoke(innerRing: 2, outerRing: 3, angle: -1.73),
        ],
        arcs: [
            Arc(ring: 3, startAngle: -2.24, endAngle:  1.32),
            Arc(ring: 3, startAngle:  1.56, endAngle: -2.48),
            Arc(ring: 2, startAngle: -2.78, endAngle: -2.06),
            Arc(ring: 2, startAngle: -1.78, endAngle: -1.53),
            Arc(ring: 2, startAngle: -1.26, endAngle: -0.48),
            Arc(ring: 2, startAngle: -0.20, endAngle:  0.87),
            Arc(ring: 2, startAngle:  1.12, endAngle:  1.62),
            Arc(ring: 2, startAngle:  1.93, endAngle: -3.07),
            Arc(ring: 1, startAngle: -3.05, endAngle: -1.65),
            Arc(ring: 1, startAngle: -1.34, endAngle:  0.37),
            Arc(ring: 1, startAngle:  0.78, endAngle:  1.82),
            Arc(ring: 1, startAngle:  2.27, endAngle:  2.85),
            Arc(ring: 0, startAngle: -2.32, endAngle:  1.01),
            Arc(ring: 0, startAngle:  1.51, endAngle:  1.61),
            Arc(ring: 0, startAngle:  2.13, endAngle: -2.87)
        ]
    )
}
