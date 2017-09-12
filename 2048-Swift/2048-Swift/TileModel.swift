//
//  TileModel.swift
//  2048-Swift
//
//  Created by Pan on 02/09/2017.
//  Copyright © 2017 Yo. All rights reserved.
//

import Foundation

enum MoveDirection: Int {
    case up, down, left, right
}

struct Position {
    var row = 0
    var col = 0
}

extension Position {
    static func == (pos1: Position, pos2: Position) -> Bool {
        return (pos1.row == pos2.row) && (pos1.col == pos2.col)
    }
    static func != (pos1: Position, pos2: Position) -> Bool {
        return !(pos1 == pos2)
    }
    func toString() -> String {
        return String(describing: (self.row, self.col))
    }
}

enum TileState {
    case empty
    case single(Position)
    case combined2(Position, Position)
    case combined3(Position, Position, Position)
}

enum TileAction {
    case move(from: Position, to: Position, dismissed: Bool)
    case merge(at: Position, value: Int)
    case insert(at: Position, value: Int)
}

class TileObject: NSObject {
    var value: Int = 0
    var state: TileState = .empty
}

