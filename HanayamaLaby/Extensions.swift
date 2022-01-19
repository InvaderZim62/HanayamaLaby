//
//  Extensions.swift
//  Tantrix
//
//  Created by Phil Stern on 7/31/21.
//

import UIKit

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    func limitedToView(_ view: UIView) -> CGPoint {
        let limitedX = min(view.bounds.maxX, max(view.bounds.minX, x))  // use bounds, since checkerViews are subviews of boardView
        let limitedY = min(view.bounds.maxY, max(view.bounds.minY, y))  // if checkerViews are subviews of ViewController.view, use frame
        return CGPoint(x: limitedX, y: limitedY)
    }
    
    func limitedToView(_ view: UIView, withInset: CGFloat) -> CGPoint {
        let limitedX = min(view.bounds.maxX - withInset, max(view.bounds.minX + withInset, x))
        let limitedY = min(view.bounds.maxY - withInset, max(view.bounds.minY + withInset, y))
        return CGPoint(x: limitedX, y: limitedY)
    }
}
