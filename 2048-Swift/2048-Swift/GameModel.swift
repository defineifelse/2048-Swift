//
//  GameModel.swift
//  2048-Swift
//
//  Created by Pan on 02/09/2017.
//  Copyright © 2017 Yo. All rights reserved.
//

import Foundation

protocol GameProtocol : class {
    func scoreDidChange(game: GameModel, score: Int)
    func tilesDidChange(game: GameModel, actions: [TileAction])
    func gameDidGetNumber(game: GameModel, number: Int)
    func gameDidOver(game: GameModel)
}

class GameModel: NSObject {
    private let dimension: Int
    private let gameType: GameType
    private let difficulty: Difficulty
    private var tiles: [[TileObject]]
    
    unowned let delegate : GameProtocol

    private var maxNumber: Int = 0 {
        didSet {
            delegate.gameDidGetNumber(game: self, number: maxNumber)
        }
    }

    private var score : Int = 0 {
        didSet {
            delegate.scoreDidChange(game: self, score: score)
        }
    }
    
    init(gameType gt:GameType, dimension ds: Int, difficulty dif: Difficulty, delegate dg: GameProtocol) {
        gameType = gt
        dimension = ds
        difficulty = dif
        delegate = dg
        score = 0
        tiles = [[TileObject]]()
        for _ in 0..<dimension {
            var rows = [TileObject]()
            for _ in 0..<dimension {
                let initialValue = TileObject()
                rows.append(initialValue)
            }
            tiles.append(rows)
        }
    }
    
    func start() {
        let inserts = [insertTileRandom()!, insertTileRandom()!]
        delegate.tilesDidChange(game: self, actions: inserts)
    }
    
    func reset() {
        self.score = 0
        for i in 0..<dimension {
            for j in 0..<dimension {
                let tile = tiles[i][j]
                tile.value = 0; tile.state = .empty
            }
        }
    }
    
    func isGameover() -> Bool {
        if getEmptyPositions() != nil {
            return false
        }
        
        let directions: [MoveDirection] = [.left, .right, .up, .down]
        for d in directions {
            if isMoveAvailable(direction: d) {
                return false
            }
        }
        return true
    }
    
    private func isMoveAvailable(direction: MoveDirection) -> Bool {
        let newTiles = transposeTilesForLeftMove(direction: direction)
        var range = dimension - 1
        if gameType == .powerOf3 { range = dimension - 2 }
        for row in newTiles {
            for i in 0..<range {
                switch gameType {
                case .powerOf2:
                    if row[i].value == row[i+1].value { return true }
                case .powerOf3:
                    if ((row[i].value == row[i+1].value) && (row[i+1].value == row[i+2].value)) { return true }
                case .fibonacci:
                    if (row[i].value != row[i+1].value) && (min(row[i].value, row[i+1].value)*2 > max(row[i].value, row[i+1].value)) { return true }
                }
            }
        }
        return false
    }
    
    func insertTileRandom() -> TileAction? {
        let randomVal = Int(arc4random_uniform(100))
        switch gameType {
        case .powerOf2:
            return insertTileRandom(value: randomVal < 90 ? 2 : 4)
        case .powerOf3:
            return insertTileRandom(value: randomVal < 90 ? 3 : 9)
        case .fibonacci:
            return insertTileRandom(value: randomVal < 40 ? 2 : 3)
        }
    }
    
    private func insertTileRandom(value v: Int) -> TileAction? {
        if let emptyPositions = getEmptyPositions() {
            let randomIdx = arc4random_uniform(UInt32(emptyPositions.count-1))
            let pos = emptyPositions[Int(randomIdx)]
            let tile = tiles[pos.row][pos.col]
            tile.value = v; tile.state = .single(pos)
            return .insert(at: pos, value: v)
        }
        return nil
    }
    
    private func getEmptyPositions() -> [Position]? {
        var emptyPositions: [Position] = []
        for i in 0..<dimension {
            for j in 0..<dimension {
                if (tiles[i][j].value == 0) {
                    emptyPositions.append(Position(row: i, col: j))
                }
            }
        }
        return emptyPositions.isEmpty ? nil : emptyPositions
    }
    
    func moveTiles(direction: MoveDirection) {
        
        //transpose matrix
        if(direction != .left ) {
            tiles = transposeTilesForLeftMove(direction: direction)
        }
        
        //move left, merge every row
        for i in 0..<dimension {
            tiles[i] = mergeRowsLeft(row: tiles[i])
        }
        
        //restore matrix
        if(direction == .up ) {
            tiles = transposeTilesForLeftMove(direction: .down)
        }else if(direction == .down) {
            tiles = transposeTilesForLeftMove(direction: .up)
        }else if(direction == .right) {
            tiles = transposeTilesForLeftMove(direction: .right)
        }
                
        var maxValue = 0
        var actionScore = 0
        var actions = [TileAction]()
        for i in 0..<dimension {
            for j in 0..<dimension {
                let here = Position(row: i, col: j)
                let tile = tiles[i][j]
                if (tile.value == 0) { continue }
                switch tile.state {
                case let .single(pos):
                    actions.append(.move(from: pos, to: here, dismissed: false))
                    if(pos != here) { actionScore += 1 }
                case let .combined2(pos1, pos2):
                    actions.append(.move(from: pos1, to: here, dismissed: true))
                    actions.append(.move(from: pos2, to: here, dismissed: true))
                    actions.append(.merge(at: here, value: tile.value))
                    actionScore += tile.value
                case let .combined3(pos1, pos2, pos3):
                    actions.append(.move(from: pos1, to: here, dismissed: true))
                    actions.append(.move(from: pos2, to: here, dismissed: true))
                    actions.append(.move(from: pos3, to: here, dismissed: true))
                    actions.append(.merge(at: here, value: tile.value))
                    actionScore += tile.value
                default:
                    break
                }
                tile.state = .single(here) //update tile state
                maxValue = max(maxValue, tile.value)
            }
        }
        
        if actionScore > 0 {
            score += actionScore
            
            if let insert = insertTileRandom() { actions.append(insert) }
            
            if (difficulty == .normal || difficulty == .hard) {
                if let insert = insertTileRandom() { actions.append(insert) }
            }
            if difficulty == .hard {
                if let insert = insertTileRandom() { actions.append(insert) }
            }
            delegate.tilesDidChange(game: self, actions: actions)
        }
        
        if maxValue > maxNumber { maxNumber = maxValue }
        
        if isGameover() {
            delegate.gameDidOver(game: self)
        }
    }
    
    private func mergeRowsLeft(row: [TileObject]) -> [TileObject] {
        //remove empty tile
        var newRow = row.filter{ $0.value > 0 }
        
        //move left and merge
        var index = 0
        var range = newRow.count - 1
        if gameType == .powerOf3 { range = newRow.count - 2 }
        while(index < range) {
            switch gameType {
            case .powerOf2:
                let tile = newRow[index]; let nextTile = newRow[index+1]
                if case let .single(pos1) = tile.state, case let .single(pos2) = nextTile.state, tile.value == nextTile.value {
                    tile.value += nextTile.value; tile.state = .combined2(pos1, pos2)
                    nextTile.value = 0; nextTile.state = .empty
                    index += 2
                }else { index += 1 }
            case .powerOf3:
                let tile1 = newRow[index]; let tile2 = newRow[index+1]; let tile3 = newRow[index+2]
                if case let .single(pos1) = tile1.state, case let .single(pos2) = tile2.state, case let .single(pos3) = tile3.state, (tile1.value == tile2.value) && (tile2.value == tile3.value) {
                    tile1.value += tile2.value + tile3.value; tile1.state = .combined3(pos1, pos2, pos3)
                    tile2.value = 0; tile2.state = .empty; tile3.value = 0; tile3.state = .empty
                    index += 3
                }else { index += 1 }
            case .fibonacci:
                let tile = newRow[index]; let nextTile = newRow[index+1]
                if case let .single(pos1) = tile.state, case let .single(pos2) = nextTile.state, tile.value != nextTile.value, min(tile.value, nextTile.value)*2 > max(tile.value, nextTile.value) {
                    tile.value += nextTile.value; tile.state = .combined2(pos1, pos2)
                    nextTile.value = 0; nextTile.state = .empty
                    index += 2
                }else { index += 1 }
            }
            
        }
        
        newRow = newRow.filter{ $0.value > 0 }
        
        //add empty tile
        let emptyCount = dimension - newRow.count
        for _ in 0..<emptyCount {
            newRow.append(TileObject())
        }
        return newRow
    }
    
    // transpose matrix
    private func transposeTilesForLeftMove(direction: MoveDirection) -> [[TileObject]] {
        var newTiles = [[TileObject]]()
        switch direction {
        case .left:
            return tiles
        case .right:  //turn it by 180 degrees, move right -> move left
            for i in 0..<dimension {
                newTiles.append(tiles[i].reversed())
            }
        case .up:   //turn it by 90 degrees in a counterclockwise direction, move up -> move left
            for i in 0..<dimension {
                var rows = [TileObject]()
                for j in 0..<dimension {
                    rows.append(tiles[j][dimension-1-i])
                }
                newTiles.append(rows)
            }
        case .down:  //turn it by 90 degrees in a clockwise direction, move down -> move left
            for i in 0..<dimension {
                var rows = [TileObject]()
                for j in 0..<dimension {
                    rows.append(tiles[dimension-1-j][i])
                }
                newTiles.append(rows)
            }
        }
        return newTiles
    }
}
