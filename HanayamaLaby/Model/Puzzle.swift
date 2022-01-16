//
//  Puzzle.swift
//  HanayamaLaby
//
//  Created by Phil Stern on 1/15/22.
//

import Foundation

struct Spoke {
    let innerRing: Int
    let outerRing: Int
    let angle: Double  // radians (0 to right, positive clockwise)
}

struct Arc {
    let ring: Int
    let startAngle: Double  // radians (0 to right, positive clockwise)
    let endAngle: Double
}

struct Puzzle {
    let spokes: [Spoke]
    let arcs: [Arc]
    let ringRadiusFactors = [0.41, 0.56, 0.73, 0.90]  // percent view half-width
}
