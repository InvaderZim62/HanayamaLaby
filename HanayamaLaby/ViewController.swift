//
//  ViewController.swift
//  HanayamaLaby
//
//  Created by Phil Stern on 1/15/22.
//
//  This app makes extensive use of transforms
//  - transforms change a view's frame, but not its "center" property
//  - changing transforms cause viewDidLayoutSubviews to be called
//
//  Lessons learned...
//  - using transforms to rotate the handle views (which this app does), rather then redrawing at different angles,
//    results in needing to use transforms for the translations (setting initial positions, and panning) as well
//  - trying to move the handle view's center while panning (rather than transforming) results in the handle view
//    jumping back to it's initial position when changing the rotational part of the transform (in handleRotate)
//  - setting the handle view's initial position by setting its center (ex. in updateViewFromModel) results in
//    incorrect conversion of the center (used in handlePan to prevent panning off-screen)
//
//  To do...
//  - move rotation point from center to contact point, if contact made with either handle (might make panning/rotating easier)
//

import UIKit

struct Constants {
    static let pegRadius: CGFloat = 2.5
    static let handleWidth: CGFloat = 5 * pegRadius
    static let faceLength: CGFloat = 60
    static let tailLength: CGFloat = 30
    static let handleLength: CGFloat = 200
    static let centerToFace: CGFloat = (handleLength - faceLength) / 2
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

        // debug - start with handles outside puzzles (may also want to set "Back Puzzle View" horizontal center to +140 in storyboard)
//        backHandleView.transform = backHandleView.transform.translatedBy(x: 30, y: 30)
//        frontHandleView.transform = frontHandleView.transform.translatedBy(x: 60, y: 30)
    }
    
    override func viewDidLayoutSubviews() {  // called when handleView's transform changes (frequently)
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

        if backHandleView.transform == .identity {
            let midFacePoint = CGPoint(x: Constants.handleWidth / 2, y: Constants.faceLength / 2)
            let backTranslate = backPuzzleView.center - midFacePoint
            let frontTranslate = frontPuzzleView.center - midFacePoint
            backHandleView.transform = backHandleView.transform.translatedBy(x: backTranslate.x, y: backTranslate.y)
            frontHandleView.transform = frontHandleView.transform.translatedBy(x: frontTranslate.x, y: frontTranslate.y)
        }
    }
    
    private func createHandleViews() {
        backHandleView.frame = CGRect(x: 0, y: 0, width: Constants.handleWidth, height: Constants.handleLength)
        backHandleView.pegOffset = 0.15  // peg near top of face
        view.addSubview(backHandleView)

        frontHandleView.frame = CGRect(x: 0, y: 0, width: Constants.handleWidth, height: Constants.handleLength)
        frontHandleView.pegOffset = 0.85  // peg near bottom of face
        view.addSubview(frontHandleView)
    }
    
    // MARK: - Gesture actions
    
    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view).limitedTo(PuzzleConst.wallWidth / 2)  // limit to prevent moving through walls in one step
        
        // don't allow panning off screen (with 10-point buffer)
        let backHandleViewCenter = backHandleView.convert(backHandleView.center, to: view)  // convert, since .center doesn't change with transform.translatedBy
        let backTargetPosition = backHandleViewCenter + translation
        let frontHandleViewCenter = frontHandleView.convert(frontHandleView.center, to: view)
        let frontTargetPosition = frontHandleViewCenter + translation
        if !view.frame.insetBy(dx: 10, dy: 10).contains(backTargetPosition) || !view.frame.insetBy(dx: 10, dy: 10).contains(frontTargetPosition) {
            return
        }

        // try moving first, then determine if it went through wall (reset, if it did)
        let backHandleTransformPast = backHandleView.transform
        let backRotation = atan2(backHandleView.transform.b, backHandleView.transform.a)
        backHandleView.transform = backHandleView.transform.translatedBy(x: translation.x * cos(backRotation) + translation.y * sin(backRotation),
                                                                         y: -translation.x * sin(backRotation) + translation.y * cos(backRotation))
        let backPegPositionInPuzzleCoords = view.convert(backHandleView.pegPositionInSuperview, to: backPuzzleView)
        let backTailPositionInPuzzleCoords = view.convert(backHandleView.tailPositionInSuperview, to: backPuzzleView)

        let frontHandleTransformPast = frontHandleView.transform
        let frontRotation = atan2(frontHandleView.transform.b, frontHandleView.transform.a)
        frontHandleView.transform = frontHandleView.transform.translatedBy(x: translation.x * cos(frontRotation) + translation.y * sin(frontRotation),
                                                                           y: -translation.x * sin(frontRotation) + translation.y * cos(frontRotation))
        let frontPegPositionInPuzzleCoords = view.convert(frontHandleView.pegPositionInSuperview, to: frontPuzzleView)
        let frontTailPositionInPuzzleCoords = view.convert(frontHandleView.tailPositionInSuperview, to: frontPuzzleView)
        
        if backPuzzleView.wallPath.contains(backPegPositionInPuzzleCoords) ||
            backPuzzleView.floorPath.contains(backTailPositionInPuzzleCoords) ||
            frontPuzzleView.wallPath.contains(frontPegPositionInPuzzleCoords) ||
            frontPuzzleView.floorPath.contains(frontTailPositionInPuzzleCoords)
        {
            // peg inside a wall or tail inside floor area (reset handle positions)
            backHandleView.transform = backHandleTransformPast
            frontHandleView.transform = frontHandleTransformPast
        }
        recognizer.setTranslation(.zero, in: view)
    }
    
    @objc private func handleRotate(recognizer: UIRotationGestureRecognizer) {
        let limitedRotation = recognizer.rotation.limitedTo(0.02)  // limit to prevent moving through walls in one step
        // try moving first, then determine if it went through wall (reset, if it did)
        let pastBackHandleViewTransform = backHandleView.transform
        backHandleView.transform = backHandleView.transform  // rotate about center of face
            .translatedBy(x: 0, y: -Constants.centerToFace)
            .rotated(by: Constants.panRotationSensitivity * limitedRotation)
            .translatedBy(x: 0, y: Constants.centerToFace)
        let backPegPositionInPuzzleCoords = view.convert(backHandleView.pegPositionInSuperview, to: backPuzzleView)
        let backTailPositionInPuzzleCoords = view.convert(backHandleView.tailPositionInSuperview, to: backPuzzleView)

        let pastFrontHandleViewTransform = frontHandleView.transform
        frontHandleView.transform = frontHandleView.transform  // rotate about center of face
            .translatedBy(x: 0, y: -Constants.centerToFace)
            .rotated(by: Constants.panRotationSensitivity * limitedRotation)
            .translatedBy(x: 0, y: Constants.centerToFace)
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
