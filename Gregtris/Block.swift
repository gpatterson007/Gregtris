//
//  Block.swift
//  Gregtris
//
//  Created by Greg Patterson on 2/26/16.
//  Copyright © 2016 Greg Patterson. All rights reserved.
//

import Foundation
import SpriteKit

// #1
let NumberOfColors: UInt32 = 6

// #2
enum BlockColor: Int, CustomStringConvertible {
    
    // #3
    case blue = 0, orange, purple, red, teal, yellow
    
    // #4
    var spriteName: String {
        switch self {
        case .blue:
            return "blue"
        case .orange:
            return "orange"
        case .purple:
            return "purple"
        case .red:
            return "red"
        case .teal:
            return "teal"
        case .yellow:
            return "yellow"
        }
    }
    
    // #5
    var description: String {
        return self.spriteName
    }
    
    // #6
    static func random() -> BlockColor {
        return BlockColor(rawValue:Int(arc4random_uniform(NumberOfColors)))!
    }
}


// #7
class Block: Hashable, CustomStringConvertible {
    // #8
    // Constants
    let color: BlockColor
    
    // #9
    // Properties
    var column: Int
    var row: Int
    var sprite: SKSpriteNode?
    
    // #10
    var spriteName: String {
        return color.spriteName
    }
    
    // #11
    var hashValue: Int {
        return self.column ^ self.row
    }
    
    // #12
    var description: String {
        return "\(color): [\(column), \(row)]"
    }
    
    init(column:Int, row:Int, color:BlockColor) {
        self.column = column
        self.row = row
        self.color = color
    }
}

// #13
func ==(lhs: Block, rhs: Block) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
}
