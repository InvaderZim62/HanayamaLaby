//
//  ViewController.swift
//  HanayamaLaby
//
//  Created by Phil Stern on 1/15/22.
//
//  To do...
//  - rename probe to peg?
//

import UIKit

struct Constants {
    static let probeRadius: CGFloat = 2.5
    static let handleWidth: CGFloat = 5 * probeRadius
    static let faceLength: CGFloat = 60
    static let tailLength: CGFloat = 30
    static let handleLength: CGFloat = 190
    static let tailOffset: CGFloat = 0.15  // percent of handle length from bottom
    static let panRotationSensitivity: CGFloat = 4  // ie. rotate handle views 4 times faster than rotation gesture
    static let probeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let handleColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    let backPuzzle = Puzzle(isFront: false)
    let frontPuzzle = Puzzle(isFront: true)
    let backHandleView = HandleView()
    let frontHandleView = HandleView()

    @IBOutlet weak var backPuzzleView: PuzzleView!
    @IBOutlet weak var frontPuzzleView: PuzzleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createHandleViews()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.delegate = self  // allows system to call gestureRecognizer (below) for simultaneous gestures
        view.addGestureRecognizer(pan)
        
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate))
        rotate.delegate = self
        view.addGestureRecognizer(rotate)
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
        
        let centerOffset = CGPoint(x: 0, y: (Constants.handleLength - Constants.faceLength) / 2)
        backHandleView.center = backPuzzleView.center + centerOffset
        frontHandleView.center = frontPuzzleView.center + centerOffset
    }
    
    private func createHandleViews() {
        backHandleView.frame = CGRect(x: 0, y: 0, width: Constants.handleWidth, height: Constants.handleLength)
        backHandleView.probeOffset = 0.15
        view.addSubview(backHandleView)

        frontHandleView.frame = CGRect(x: 0, y: 0, width: Constants.handleWidth, height: Constants.handleLength)
        frontHandleView.probeOffset = 0.85
        view.addSubview(frontHandleView)
    }
    
    // MARK: - Gesture actions
    
    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        // try moving first, then determine if it when through wall (reset, if it did)
        let pastBackHandleViewCenter = backHandleView.center
        backHandleView.center = (backHandleView.center + translation).limitedToView(view, withInset: 20)  // in view coordinates
        let backProbePositionInPuzzleCoords = view.convert(backHandleView.probePositionInSuperview, to: backPuzzleView)
        let backTailPositionInPuzzleCoords = view.convert(backHandleView.tailPositionInSuperview, to: backPuzzleView)

        let pastFrontHandleViewCenter = frontHandleView.center
        frontHandleView.center = (frontHandleView.center + translation).limitedToView(view, withInset: 20)  // in view coordinates
        let frontProbePositionInPuzzleCoords = view.convert(frontHandleView.probePositionInSuperview, to: frontPuzzleView)
        let frontTailPositionInPuzzleCoords = view.convert(frontHandleView.tailPositionInSuperview, to: frontPuzzleView)

        if backPuzzleView.wallPath.contains(backProbePositionInPuzzleCoords) ||
            backPuzzleView.wallPath.contains(backTailPositionInPuzzleCoords) ||
            frontPuzzleView.wallPath.contains(frontProbePositionInPuzzleCoords) ||
            frontPuzzleView.wallPath.contains(frontTailPositionInPuzzleCoords)
        {
            // handle probe inside a wall (reset its position)
            backHandleView.center = pastBackHandleViewCenter
            frontHandleView.center = pastFrontHandleViewCenter
        } else {
            // handle probe is in alleyway (good)
            // since the gestures are added to self.view, rather than the handle views, the handle view transforms need to be
            // updated with this translation; otherwise, the handle views jump back to their past position when the rotation
            // sets the rotational part of their transforms; also note, the pan direction needs to be converted from screen
            // coordinates to rotated handle view coordinates
            let backDeltaPosition = backHandleView.center - pastBackHandleViewCenter
            let backAngle = atan2(backHandleView.transform.b, backHandleView.transform.a)
            backHandleView.transform = backHandleView.transform.translatedBy(x: backDeltaPosition.x * cos(backAngle) + backDeltaPosition.y * sin(backAngle),
                                                                             y: -backDeltaPosition.x * sin(backAngle) + backDeltaPosition.y * cos(backAngle))
            let frontDeltaPosition = frontHandleView.center - pastFrontHandleViewCenter
            let frontAngle = atan2(frontHandleView.transform.b, frontHandleView.transform.a)
            frontHandleView.transform = frontHandleView.transform.translatedBy(x: frontDeltaPosition.x * cos(frontAngle) + frontDeltaPosition.y * sin(frontAngle),
                                                                             y: -frontDeltaPosition.x * sin(frontAngle) + frontDeltaPosition.y * cos(frontAngle))
        }
        recognizer.setTranslation(.zero, in: view)
    }
    
    private func transformToRotate(angle: Double, about point: CGPoint) -> CGAffineTransform {
        // rotate about point by translating (from 0,0) to point, rotating, and translating back
        return CGAffineTransform(translationX: point.x, y: point.y).rotated(by: CGFloat(angle)).translatedBy(x: -point.x, y: -point.y)
    }
    
    @objc private func handleRotate(recognizer: UIRotationGestureRecognizer) {
        // try moving first, then determine if it when through wall (reset, if it did)
        let pastBackHandleViewTransform = backHandleView.transform
        backHandleView.transform = backHandleView.transform.rotated(by: Constants.panRotationSensitivity * recognizer.rotation)
        let backProbePositionInPuzzleCoords = view.convert(backHandleView.probePositionInSuperview, to: backPuzzleView)
        let backTailPositionInPuzzleCoords = view.convert(backHandleView.tailPositionInSuperview, to: backPuzzleView)

        let pastFrontHandleViewTransform = frontHandleView.transform
        frontHandleView.transform = frontHandleView.transform.rotated(by: Constants.panRotationSensitivity * recognizer.rotation)
        let frontProbePositionInPuzzleCoords = view.convert(frontHandleView.probePositionInSuperview, to: frontPuzzleView)
        let frontTailPositionInPuzzleCoords = view.convert(frontHandleView.tailPositionInSuperview, to: frontPuzzleView)

        if backPuzzleView.wallPath.contains(backProbePositionInPuzzleCoords) ||
            backPuzzleView.wallPath.contains(backTailPositionInPuzzleCoords) ||
            frontPuzzleView.wallPath.contains(frontProbePositionInPuzzleCoords) ||
            frontPuzzleView.wallPath.contains(frontTailPositionInPuzzleCoords)
        {
            // handle probe inside a wall (reset its transform)
            backHandleView.transform = pastBackHandleViewTransform
            frontHandleView.transform = pastFrontHandleViewTransform
        }
        recognizer.rotation = 0  // reset, to use incremental rotations
    }

    // MARK: - UIGestureRecognizerDelegate
    
    // allow simultaneous pan and rotate gestures
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
