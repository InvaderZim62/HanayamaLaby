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
//

import UIKit

struct Constants {
    static let pegRadius: CGFloat = 2.5
    static let handleWidth: CGFloat = 5 * pegRadius
    static let faceLength: CGFloat = 60
    static let tailLength: CGFloat = 30
    static let handleLength: CGFloat = 200
    static let leftPegOffset: CGFloat = 0.15 * faceLength  // distance from top of handle to left handle peg
    static let rightPegOffset: CGFloat = 0.85 * faceLength  // distance from top of handle to right handle peg
    static let centerToFace: CGFloat = (handleLength - faceLength) / 2  // distance from center of handle to center of face
    static let centerToTail: CGFloat = handleLength / 2 - tailLength  // distance from center of handle to start of tail section
    static let centerToLeftPeg: CGFloat = handleLength / 2 - leftPegOffset  // distance from center of handle to left handle peg
    static let centerToRightPeg: CGFloat = handleLength / 2 - rightPegOffset  // distance from center of handle to right handle peg
    static let rotationSensitivity: CGFloat = 4  // ie. rotate handle views 4 times faster than rotation gesture
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

    let leftPuzzle = Puzzle(isLeftSide: true)
    let rightPuzzle = Puzzle(isLeftSide: false)
    let leftHandleView = HandleView()
    let rightHandleView = HandleView()
    var leftPegContact = false
    var rightPegContact = false
    var leftTailContact = false
    var rightTailContact = false
    
    lazy var leftWallPath = leftPuzzleView.wallPath  // compute once since it doesn't change; lazy since bounds needed to be set
    lazy var rightWallPath = rightPuzzleView.wallPath
    
    var rotationCenterOffset: CGFloat {  // offset from center of handle
        if leftPegContact {
            return Constants.centerToLeftPeg
        } else if rightPegContact {
            return Constants.centerToRightPeg
        } else if leftTailContact || rightTailContact {
            return -Constants.centerToTail
        } else {
            return Constants.centerToFace
        }
    }
    
    var display = Display.drawing {
        didSet {
            switch display {
            case .image:
                leftImage.isHidden = false
                rightImage.isHidden = false
                leftPuzzleView.alpha = 0
                rightPuzzleView.alpha = 0
            case .drawing:
                leftImage.isHidden = true
                rightImage.isHidden = true
                leftPuzzleView.alpha = 1
                rightPuzzleView.alpha = 1
            case .both:
                leftImage.isHidden = false
                rightImage.isHidden = false
                leftPuzzleView.alpha = 0.4
                rightPuzzleView.alpha = 0.4
            }
        }
    }

    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var leftPuzzleView: PuzzleView!
    @IBOutlet weak var rightPuzzleView: PuzzleView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        display = .drawing
        createHandleViews()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        pan.delegate = self  // allows system to call gestureRecognizer (below) for simultaneous gestures
        view.addGestureRecognizer(pan)
        
        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate))
        rotate.delegate = self
        view.addGestureRecognizer(rotate)

        // debug - start with handles outside puzzles (may also want to set "Left Puzzle View" horizontal center to +140 in storyboard)
//        leftHandleView.transform = leftHandleView.transform.translatedBy(x: 30, y: 30)
//        rightHandleView.transform = rightHandleView.transform.translatedBy(x: 60, y: 30)
    }
    
    override func viewDidLayoutSubviews() {  // called when handleView's transform changes (frequently)
        super.viewDidLayoutSubviews()
        updateViewFromModel()
    }
    
    // MARK: - Start of code
    
    private func updateViewFromModel() {
        leftPuzzleView.ringRadiusFactors = leftPuzzle.ringRadiusFactors
        leftPuzzleView.spokes = leftPuzzle.spokes
        leftPuzzleView.arcs = leftPuzzle.arcs
        
        rightPuzzleView.ringRadiusFactors = rightPuzzle.ringRadiusFactors
        rightPuzzleView.spokes = rightPuzzle.spokes
        rightPuzzleView.arcs = rightPuzzle.arcs

        if leftHandleView.transform == .identity {
            let midFacePoint = CGPoint(x: Constants.handleWidth / 2, y: Constants.faceLength / 2)
            let leftTranslate = leftPuzzleView.center - midFacePoint
            let rightTranslate = rightPuzzleView.center - midFacePoint
            leftHandleView.transform = leftHandleView.transform.translatedBy(x: leftTranslate.x, y: leftTranslate.y)
            rightHandleView.transform = rightHandleView.transform.translatedBy(x: rightTranslate.x, y: rightTranslate.y)
        }
    }
    
    private func createHandleViews() {
        leftHandleView.frame = CGRect(x: 0, y: 0, width: Constants.handleWidth, height: Constants.handleLength)
        leftHandleView.pegOffset = Constants.leftPegOffset  // peg near top of face
        view.addSubview(leftHandleView)

        rightHandleView.frame = CGRect(x: 0, y: 0, width: Constants.handleWidth, height: Constants.handleLength)
        rightHandleView.pegOffset = Constants.rightPegOffset  // peg near bottom of face
        view.addSubview(rightHandleView)
    }
    
    // MARK: - Gesture actions
    
    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view).limitedTo(PuzzleConst.wallWidth / 2)  // limit to prevent moving through walls in one step
        
        // don't allow panning off screen (with 10-point buffer)
        let leftHandleViewCenter = leftHandleView.convert(leftHandleView.center, to: view)  // convert, since .center doesn't change with transform.translatedBy
        let leftTargetPosition = leftHandleViewCenter + translation
        let rightHandleViewCenter = rightHandleView.convert(rightHandleView.center, to: view)
        let rightTargetPosition = rightHandleViewCenter + translation
        if !view.frame.insetBy(dx: 10, dy: 10).contains(leftTargetPosition) || !view.frame.insetBy(dx: 10, dy: 10).contains(rightTargetPosition) {
            return
        }

        // try moving first, then determine if it went through wall (reset, if it did)
        let leftHandleTransformPast = leftHandleView.transform
        let leftRotation = atan2(leftHandleView.transform.b, leftHandleView.transform.a)
        leftHandleView.transform = leftHandleView.transform.translatedBy(x: translation.x * cos(leftRotation) + translation.y * sin(leftRotation),
                                                                         y: -translation.x * sin(leftRotation) + translation.y * cos(leftRotation))
        let leftPegPositionInPuzzleCoords = view.convert(leftHandleView.pegPositionInSuperview, to: leftPuzzleView)
        let leftPegContact = leftWallPath.contains(leftPegPositionInPuzzleCoords)
        let leftTailPositionInPuzzleCoords = view.convert(leftHandleView.tailPositionInSuperview, to: leftPuzzleView)
        let leftTailContact = leftPuzzleView.floorPath.contains(leftTailPositionInPuzzleCoords)

        let rightHandleTransformPast = rightHandleView.transform
        let rightRotation = atan2(rightHandleView.transform.b, rightHandleView.transform.a)
        rightHandleView.transform = rightHandleView.transform.translatedBy(x: translation.x * cos(rightRotation) + translation.y * sin(rightRotation),
                                                                           y: -translation.x * sin(rightRotation) + translation.y * cos(rightRotation))
        let rightPegPositionInPuzzleCoords = view.convert(rightHandleView.pegPositionInSuperview, to: rightPuzzleView)
        let rightPegContact = rightWallPath.contains(rightPegPositionInPuzzleCoords)
        let rightTailPositionInPuzzleCoords = view.convert(rightHandleView.tailPositionInSuperview, to: rightPuzzleView)
        let rightTailContact = rightPuzzleView.floorPath.contains(rightTailPositionInPuzzleCoords)
        
        if leftPegContact || leftTailContact || rightPegContact || rightTailContact {
            // peg inside a wall or tail inside floor area (reset handle positions)
            leftHandleView.transform = leftHandleTransformPast
            rightHandleView.transform = rightHandleTransformPast
        }
        recognizer.setTranslation(.zero, in: view)
    }
    
    @objc private func handleRotate(recognizer: UIRotationGestureRecognizer) {
        let limitedRotation = recognizer.rotation.limitedTo(0.02)  // limit to prevent moving through walls in one step
        let rotationOffset = rotationCenterOffset
        // try moving first, then determine if it went through wall (reset, if it did)
        let leftHandleViewTransformPast = leftHandleView.transform
        leftHandleView.transform = leftHandleView.transform  // rotate about center of face
            .translatedBy(x: 0, y: -rotationOffset)
            .rotated(by: Constants.rotationSensitivity * limitedRotation)
            .translatedBy(x: 0, y: rotationOffset)
        let leftPegPositionInPuzzleCoords = view.convert(leftHandleView.pegPositionInSuperview, to: leftPuzzleView)
        leftPegContact = leftWallPath.contains(leftPegPositionInPuzzleCoords)
        let leftTailPositionInPuzzleCoords = view.convert(leftHandleView.tailPositionInSuperview, to: leftPuzzleView)
        leftTailContact = leftPuzzleView.floorPath.contains(leftTailPositionInPuzzleCoords)

        let rightHandleViewTransformPast = rightHandleView.transform
        rightHandleView.transform = rightHandleView.transform  // rotate about center of face
            .translatedBy(x: 0, y: -rotationOffset)
            .rotated(by: Constants.rotationSensitivity * limitedRotation)
            .translatedBy(x: 0, y: rotationOffset)
        let rightPegPositionInPuzzleCoords = view.convert(rightHandleView.pegPositionInSuperview, to: rightPuzzleView)
        rightPegContact = rightWallPath.contains(rightPegPositionInPuzzleCoords)
        let rightTailPositionInPuzzleCoords = view.convert(rightHandleView.tailPositionInSuperview, to: rightPuzzleView)
        rightTailContact = rightPuzzleView.floorPath.contains(rightTailPositionInPuzzleCoords)

        if leftPegContact || leftTailContact || rightPegContact || rightTailContact {
            // handle peg inside a wall or tail inside floor (reset its transform)
            leftHandleView.transform = leftHandleViewTransformPast
            rightHandleView.transform = rightHandleViewTransformPast
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
