//
//  Direction.swift
//  TileMaps
//
//  Created by Elliott, Jared Padilla on 12/4/18.
//  Copyright © 2018 Jonathan Parham. All rights reserved.
//
//
import Foundation

enum Direction: Int {
    case N,E,S,W,X
    
    var description:String {
        switch self {
        case .N: return "N"
        case .E: return "E"
        case .S: return "S"
        case .W: return "W"
        case .X: return "X"
        }
    }
    
    var amount:(Int, Int) {
        switch self {
        case .N: return (0,1)
        case .E: return (1,0)
        case .S: return (0,-1)
        case .W: return (-1,0)
        case .X: return (43,110)
        }
    }
    
    static var directions:Array<Direction> {
        return [N,E,S,W]
    }
    
    init?(degrees: Int) {
        let degreesPerDirection = Double(360 / Direction.directions.count)
        var rotatedDegrees = Double(degrees)
        rotatedDegrees = rotatedDegrees > 360 ? (rotatedDegrees - 360) : rotatedDegrees
        rotatedDegrees = rotatedDegrees < 0 ? (rotatedDegrees + 360) : rotatedDegrees
        let raw = Int(floor(rotatedDegrees / degreesPerDirection))
        self.init(rawValue: raw)
    }
}
