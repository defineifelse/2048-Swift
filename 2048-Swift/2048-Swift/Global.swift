//
//  Global.swift
//  2048-Swift
//
//  Created by Pan on 03/09/2017.
//  Copyright © 2017 Yo. All rights reserved.
//

import Foundation

enum GameType: Int{
    case powerOf2 = 0
    case powerOf3
    case fibonacci
}

enum Difficulty: Int{
    case easy = 0
    case normal
    case hard
}

class Global: NSObject {
    
    static let settingTypes = ["Game Type", "Board Size", "Difficulty"]
    
    static let gameTypes: [String] = ["Powers of 2", "Powers of 3", "Fibonacci"]
    static let boardSizes: [String] = ["3 x 3", "4 x 4", "5 x 5", "6 x 6"]
    static let difficultys: [String] = ["Easy", "Normal", "Hard"]
    
    static let defaulGameType = "Powers of 2"
    static let defaultBoardSize = "4 x 4"
    static let defaultDifficulty = "Easy"

    static let gameTypeValues: [GameType]  = [GameType.powerOf2, GameType.powerOf3, GameType.fibonacci]
    static let boardSizeValues:[Int] = [3, 4, 5, 6]
    static let difficultyValues: [Difficulty] = [Difficulty.easy, Difficulty.normal, Difficulty.hard]

    static func dimension() -> Int {
        let index = boardSizes.index(of: boardSizeName())
        return boardSizeValues[index!]
    }
    
    static func threshold(gameType: GameType, dimension: Int) -> Int {
        switch gameType {
        case .powerOf2:
            if dimension < 4 { return 1024 }
            if dimension > 4 { return 8192 }
            return 2048
        case .powerOf3:
            if dimension < 4 { return 81 }
            if dimension > 4 { return 729 }
            return 243
        case .fibonacci:
            if dimension < 4 { return 144 }
            if dimension > 4 { return 610 }
            return 233
        }
    }
    
    static func gameType() -> GameType {
        let index = gameTypes.index(of: gameTypeName())
        return gameTypeValues[index!]
    }
    
    static func difficulty() -> Difficulty {
        let index = difficultys.index(of: difficultyName())
        return difficultyValues[index!]
    }
    
    static func gameTypeName() -> String {
        if let value = UserDefaults.standard.value(forKey: settingTypes[0]) {
            return value as! String
        }
        return defaulGameType
    }
    
    static func boardSizeName() -> String {
        if let value = UserDefaults.standard.value(forKey: settingTypes[1]) {
            return value as! String
        }
        return defaultBoardSize
    }
    
    static func difficultyName() -> String {
        if let value = UserDefaults.standard.value(forKey: settingTypes[2]) {
            return value as! String
        }
        return defaultDifficulty
    }
    
    static func bestScore() -> Int {
        if let score = UserDefaults.standard.value(forKey: "Best Score") {
            return score as! Int
        }
        return 0
    }
    
    static func saveBestScore(score: Int) {
        UserDefaults.standard.set(score, forKey: "Best Score")
    }
}


