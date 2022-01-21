//
//  ViewController.swift
//  HanayamaLaby
//
//  Created by Phil Stern on 1/15/22.
//
//  To do...
//  - move rotation point from center to contact point, if contact made with either handle (might make panning/rotating easier)
//  - backHandleView.center doesn't change during panning; it stays at the value set in updateViewFromModel; maybe because of
//    using transforms?  Because of this, limiting its center to an inset of self.view doesn't work.
//

import UIKit

struct Constants {
    static let pegRadius: CGFloat = 2.5
    static let handleWidth: CGFloat = 5 * pegRadius
    static let faceLength: CGFloat = 60
    static let tailLength: CGFloat = 30
    static let handleLength: CGFloat = 200
    static let tailOffset: CGFloat = 0.15  // percent of handle length from bottom
    static let panRotationSensitivity: CGFloat = 4  // ie. rotate handle views 4 times faster than rotation gesture
    static let pegColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static let handleColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
}

enum Display: CaseIterable {
    case image
    case drawing
    case both
    mutating func next() {
        let allCases = type(of: self).allCases
        self = allCases[(allCases.firstIndex(of: self)! + 1) % allCases.count]
    }
}

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    let backPuzzle = Puzzle(isFront: false)
    let frontPuzzle = Puzzle(isFront: true)
    let backHandleView = HandleView()
    let frontHandleView = HandleView()

    var display = Display.image {
        didSet {
            switch display {
            case .image:
                backImage.isHidden = false
                frontImage.isHidden = false
                backPuzzleView.alpha = 0
                frontPuzzleView.alpha = 0
            case .drawing:
                backImage.isHidden = true
                frontImage.isHidden = true
                backPuzzleView.alpha = 1
                frontPuzzleView.alpha = 1
            case .both:
                backImage.isHidden = false
                frontImage.isHidden = false
                backPuzzleView.alpha = 0.4
                frontPuzzleView.alpha = 0.4
            }
        }
    }

    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var frontImage: UIImageView!
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
        backHandleView.pegOffset = 0.15
        view.addSubview(backHandleView)

        frontHandleView.frame = CGRect(x: 0, y: 0, width: Constants.handleWidth, height: Constants.handleLength)
        frontHandleView.pegOffset = 0.85
        view.addSubview(frontHandleView)
    }
    
    // MARK: - Gesture actions
    
    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view).limitedTo(PuzzleConst.wallWidth / 2)  // limit to prevent moving through walls in one step
        // try moving first, then determine if it went through wall (reset, if it did)
        let pastBackHandleViewCenter = backHandleView.center
        backHandleView.center = (backHandleView.center + translation).limitedToView(view, withInset: 20)  // in view coordinates
        let backPegPositionInPuzzleCoords = view.convert(backHandleView.pegPositionInSuperview, to: backPuzzleView)
        let backTailPositionInPuzzleCoords = view.convert(backHandleView.tailPositionInSuperview, to: backPuzzleView)

        let pastFrontHandleViewCenter = frontHandleView.center
        frontHandleView.center = (frontHandleView.center + translation).limitedToView(view, withInset: 20)  // in view coordinates
        let frontPegPositionInPuzzleCoords = view.convert(frontHandleView.pegPositionInSuperview, to: frontPuzzleView)
        let frontTailPositionInPuzzleCoords = view.convert(frontHandleView.tailPositionInSuperview, to: frontPuzzleView)

        if backPuzzleView.wallPath.contains(backPegPositionInPuzzleCoords) ||
            backPuzzleView.floorPath.contains(backTailPositionInPuzzleCoords) ||
            frontPuzzleView.wallPath.contains(frontPegPositionInPuzzleCoords) ||
            frontPuzzleView.floorPath.contains(frontTailPositionInPuzzleCoords)
        {
            // handle peg inside a wall or tail inside floor (reset its position)
            backHandleView.center = pastBackHandleViewCenter
            frontHandleView.center = pastFrontHandleViewCenter
        } else {
            // handle peg is in alleyway and tail is outside floor (good)
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
        let limitedRotation = recognizer.rotation.limitedTo(0.02)  // limit to prevent moving through walls in one step
        // try moving first, then determine if it went through wall (reset, if it did)
        let pastBackHandleViewTransform = backHandleView.transform
        backHandleView.transform = backHandleView.transform.rotated(by: Constants.panRotationSensitivity * limitedRotation)
        let backPegPositionInPuzzleCoords = view.convert(backHandleView.pegPositionInSuperview, to: backPuzzleView)
        let backTailPositionInPuzzleCoords = view.convert(backHandleView.tailPositionInSuperview, to: backPuzzleView)

        let pastFrontHandleViewTransform = frontHandleView.transform
        frontHandleView.transform = frontHandleView.transform.rotated(by: Constants.panRotationSensitivity * limitedRotation)
        let frontPegPositionInPuzzleCoords = view.convert(frontHandleView.pegPositionInSuperview, to: frontPuzzleView)
        let frontTailPositionInPuzzleCoords = view.convert(frontHandleView.tailPositionInSuperview, to: frontPuzzleView)

        if backPuzzleView.wallPath.contains(backPegPositionInPuzzleCoords) ||
            backPuzzleView.floorPath.contains(backTailPositionInPuzzleCoords) ||
            frontPuzzleView.wallPath.contains(frontPegPositionInPuzzleCoords) ||
            frontPuzzleView.floorPath.contains(frontTailPositionInPuzzleCoords)
        {
            // handle peg inside a wall or tail inside floor (reset its transform)
            backHandleView.transform = pastBackHandleViewTransform
            frontHandleView.transform = pastFrontHandleViewTransform
        }
        recognizer.rotation = 0  // reset, to use incremental rotations
    }

    @IBAction func togglePressed(_ sender: UIButton) {
        display.next()
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    // allow simultaneous pan and rotate gestures
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
