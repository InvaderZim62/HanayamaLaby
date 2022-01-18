//
//  ViewController.swift
//  HanayamaLaby
//
//  Created by Phil Stern on 1/15/22.
//

import UIKit

class ViewController: UIViewController {

    let probeView = ProbeView()

    @IBOutlet weak var backPuzzleView: PuzzleView!
    @IBOutlet weak var frontPuzzleView: PuzzleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backPuzzleView)
        createProbeView()
        
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
        probeView.center = backPuzzleView.center
    }
    
    private func createProbeView() {
        probeView.frame = CGRect(x: 0, y: 0, width: 2 * ProbeConst.probeRadius, height: 2 * ProbeConst.probeRadius)
        view.addSubview(probeView)
    }
    
    @objc private func screenPanned(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        let positionInViewCoords = (probeView.center + translation).limitedToView(view, withInset: 20)
        let positionInPuzzleViewCoords = view.convert(positionInViewCoords, to: backPuzzleView)
        if !backPuzzleView.wallPath.contains(positionInPuzzleViewCoords) {
            // position not inside a wall (allow it to move)
            probeView.center = positionInViewCoords
        }
        recognizer.setTranslation(.zero, in: view)
    }

    let backPuzzle =
    Puzzle(
        spokes: [
            Spoke(innerRing: 1, outerRing: 2, angle: -1.54),
            Spoke(innerRing: 0, outerRing: 1, angle: -1.08),
            Spoke(innerRing: 2, outerRing: 3, angle: -0.82),
            Spoke(innerRing: 1, outerRing: 3, angle: -0.50),
            Spoke(innerRing: 0, outerRing: 1, angle:  0.06),
            Spoke(innerRing: 2, outerRing: 3, angle:  0.19),
            Spoke(innerRing: 1, outerRing: 2, angle:  0.24),
            Spoke(innerRing: 0, outerRing: 1, angle:  0.66),
            Spoke(innerRing: 2, outerRing: 3, angle:  1.21),
            Spoke(innerRing: 1, outerRing: 2, angle:  1.36),
            Spoke(innerRing: 1, outerRing: 2, angle:  2.49),
            Spoke(innerRing: 1, outerRing: 2, angle:  2.62),
            Spoke(innerRing: 2, outerRing: 3, angle:  2.72),
            Spoke(innerRing: 0, outerRing: 2, angle: -2.62),
            Spoke(innerRing: 2, outerRing: 3, angle: -2.23)
        ],
        arcs: [
            Arc(ring: 3, startAngle: -1.93, endAngle: -0.75),
            Arc(ring: 3, startAngle: -0.50, endAngle: -0.03),
            Arc(ring: 3, startAngle:  0.18, endAngle:  0.24),
            Arc(ring: 3, startAngle:  0.48, endAngle:  2.50),
            Arc(ring: 3, startAngle:  2.72, endAngle: -2.51),
            Arc(ring: 3, startAngle: -2.26, endAngle: -2.16),
            Arc(ring: 2, startAngle: -1.91, endAngle: -0.76),
            Arc(ring: 2, startAngle: -0.23, endAngle:  0.30),
            Arc(ring: 2, startAngle:  0.56, endAngle: -3.13),
            Arc(ring: 2, startAngle: -2.88, endAngle: -2.15),
            Arc(ring: 1, startAngle: -2.28, endAngle: -1.44),
            Arc(ring: 1, startAngle: -1.08, endAngle: -0.35),
            Arc(ring: 1, startAngle:  0.00, endAngle:  0.27),
            Arc(ring: 1, startAngle:  0.63, endAngle:  0.95),
            Arc(ring: 1, startAngle:  1.29, endAngle:  1.48),
            Arc(ring: 1, startAngle:  1.85, endAngle:  2.94),
            Arc(ring: 1, startAngle: -2.99, endAngle: -2.62),
            Arc(ring: 0, startAngle: -0.55, endAngle:  0.06),
            Arc(ring: 0, startAngle:  0.48, endAngle:  0.66),
            Arc(ring: 0, startAngle:  1.16, endAngle: -1.08)
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
