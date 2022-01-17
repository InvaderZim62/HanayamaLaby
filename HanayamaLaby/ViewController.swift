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
}
