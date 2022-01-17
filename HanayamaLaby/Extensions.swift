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
    
    func distance(from point: CGPoint) -> Double {
        return sqrt(pow((self.x - point.x), 2) + pow((self.y - point.y), 2))
    }

    var magnitude: Double {
        return sqrt(x * x + y * y)
    }
    
    // return bearing from 0 to 360, where 0 is up, positive is clockwise
    func bearing(to point: CGPoint) -> Double {
        return (atan2(Double(point.x - self.x), Double(-point.y + self.y)) * 180 / Double.pi).wrap360
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

extension Double {
    var rads: CGFloat {
        return CGFloat(self) * CGFloat.pi / 180.0
    }
    
    // converts angle to 0 - 360
    var wrap360: Double {
        var wrappedAngle = self
        if self >= 360.0 {
            wrappedAngle -= 360.0
        } else if self < 0 {
            wrappedAngle += 360.0
        }
        return wrappedAngle
    }
}
