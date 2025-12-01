//
//  GameModels.swift
//  DF749
//

import Foundation

enum GameDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

enum GameType: String, CaseIterable, Codable {
    case pulseGridPath = "Pulse Grid Path"
    case tempoShiftRunner = "Tempo Shift Runner"
    case shapeEchoFusion = "Shape Echo Fusion"
    
    var description: String {
        switch self {
        case .pulseGridPath:
            return "Navigate the neon grid by discovering the correct path pattern"
        case .tempoShiftRunner:
            return "Shift lanes with perfect timing to avoid obstacles"
        case .shapeEchoFusion:
            return "Recall and repeat sequences of glowing shapes"
        }
    }
    
    var totalLevels: Int {
        switch self {
        case .pulseGridPath: return 12
        case .tempoShiftRunner: return 15
        case .shapeEchoFusion: return 18
        }
    }
}

struct GameLevel: Identifiable, Codable {
    let id: String
    let gameType: GameType
    let difficulty: GameDifficulty
    let levelNumber: Int
    var isCompleted: Bool = false
    var isUnlocked: Bool = false
    
    var rewardAmount: Int {
        switch difficulty {
        case .easy: return 1
        case .medium: return 2
        case .hard: return 3
        }
    }
}


