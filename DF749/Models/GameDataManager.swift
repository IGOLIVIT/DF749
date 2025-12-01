//
//  GameDataManager.swift
//  DF749
//

import Foundation
import SwiftUI
import Combine

class GameDataManager: ObservableObject {
    static let shared = GameDataManager()
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @AppStorage("totalPlayTimeMinutes") var totalPlayTimeMinutes: Int = 0
    @AppStorage("totalGamesPlayed") var totalGamesPlayed: Int = 0
    @AppStorage("highestDifficulty") var highestDifficultyRaw: String = GameDifficulty.easy.rawValue
    
    @Published var gameLevels: [GameLevel] = []
    @Published var rewards: Reward = Reward()
    
    var highestDifficulty: GameDifficulty {
        get { GameDifficulty(rawValue: highestDifficultyRaw) ?? .easy }
        set { highestDifficultyRaw = newValue.rawValue }
    }
    
    var totalCompletedLevels: Int {
        gameLevels.filter { $0.isCompleted }.count
    }
    
    var totalUnlockedRewards: Int {
        rewards.shardsOfInsight + rewards.flowRibbons + rewards.realmEchoes
    }
    
    init() {
        loadData()
    }
    
    func loadData() {
        if let savedLevels = UserDefaults.standard.data(forKey: "gameLevels"),
           let decoded = try? JSONDecoder().decode([GameLevel].self, from: savedLevels) {
            gameLevels = decoded
        } else {
            initializeLevels()
        }
        
        if let savedRewards = UserDefaults.standard.data(forKey: "rewards"),
           let decoded = try? JSONDecoder().decode(Reward.self, from: savedRewards) {
            rewards = decoded
        }
    }
    
    func saveData() {
        do {
            let encodedLevels = try JSONEncoder().encode(gameLevels)
            UserDefaults.standard.set(encodedLevels, forKey: "gameLevels")
            
            let encodedRewards = try JSONEncoder().encode(rewards)
            UserDefaults.standard.set(encodedRewards, forKey: "rewards")
            
            UserDefaults.standard.synchronize()
        } catch {
            print("Error saving game data: \(error.localizedDescription)")
        }
    }
    
    func initializeLevels() {
        var levels: [GameLevel] = []
        
        // Pulse Grid Path - 12 levels (4 per difficulty)
        for difficulty in GameDifficulty.allCases {
            for level in 1...4 {
                let id = "pulseGridPath_\(difficulty.rawValue)_\(level)"
                let isUnlocked = (difficulty == .easy && level == 1)
                levels.append(GameLevel(id: id, gameType: .pulseGridPath, difficulty: difficulty, levelNumber: level, isUnlocked: isUnlocked))
            }
        }
        
        // Tempo Shift Runner - 15 levels (5 per difficulty)
        for difficulty in GameDifficulty.allCases {
            for level in 1...5 {
                let id = "tempoShiftRunner_\(difficulty.rawValue)_\(level)"
                let isUnlocked = (difficulty == .easy && level == 1)
                levels.append(GameLevel(id: id, gameType: .tempoShiftRunner, difficulty: difficulty, levelNumber: level, isUnlocked: isUnlocked))
            }
        }
        
        // Shape Echo Fusion - 18 levels (6 per difficulty)
        for difficulty in GameDifficulty.allCases {
            for level in 1...6 {
                let id = "shapeEchoFusion_\(difficulty.rawValue)_\(level)"
                let isUnlocked = (difficulty == .easy && level == 1)
                levels.append(GameLevel(id: id, gameType: .shapeEchoFusion, difficulty: difficulty, levelNumber: level, isUnlocked: isUnlocked))
            }
        }
        
        gameLevels = levels
        saveData()
    }
    
    func completeLevel(id: String, rewardType: RewardType) {
        if let index = gameLevels.firstIndex(where: { $0.id == id }) {
            gameLevels[index].isCompleted = true
            let rewardAmount = gameLevels[index].rewardAmount
            rewards.add(rewardType, amount: rewardAmount)
            
            // Unlock next level
            unlockNextLevel(for: gameLevels[index])
            
            // Update stats
            totalGamesPlayed += 1
            if gameLevels[index].difficulty.rawValue > highestDifficultyRaw {
                highestDifficultyRaw = gameLevels[index].difficulty.rawValue
            }
            
            saveData()
        }
    }
    
    func unlockNextLevel(for completedLevel: GameLevel) {
        let sameDifficultyLevels = gameLevels.filter {
            $0.gameType == completedLevel.gameType &&
            $0.difficulty == completedLevel.difficulty
        }.sorted { $0.levelNumber < $1.levelNumber }
        
        if let currentIndex = sameDifficultyLevels.firstIndex(where: { $0.id == completedLevel.id }),
           currentIndex + 1 < sameDifficultyLevels.count {
            let nextLevelId = sameDifficultyLevels[currentIndex + 1].id
            if let index = gameLevels.firstIndex(where: { $0.id == nextLevelId }) {
                gameLevels[index].isUnlocked = true
            }
        }
        
        // If completed all levels of easy, unlock first medium level of same game
        let completedInDifficulty = sameDifficultyLevels.filter { $0.isCompleted }.count
        if completedInDifficulty == sameDifficultyLevels.count {
            if completedLevel.difficulty == .easy {
                unlockDifficulty(.medium, for: completedLevel.gameType)
            } else if completedLevel.difficulty == .medium {
                unlockDifficulty(.hard, for: completedLevel.gameType)
            }
        }
    }
    
    func unlockDifficulty(_ difficulty: GameDifficulty, for gameType: GameType) {
        if let firstLevel = gameLevels.first(where: {
            $0.gameType == gameType &&
            $0.difficulty == difficulty &&
            $0.levelNumber == 1
        }), let index = gameLevels.firstIndex(where: { $0.id == firstLevel.id }) {
            gameLevels[index].isUnlocked = true
        }
    }
    
    func resetAllProgress() {
        initializeLevels()
        rewards = Reward()
        totalPlayTimeMinutes = 0
        totalGamesPlayed = 0
        highestDifficultyRaw = GameDifficulty.easy.rawValue
        saveData()
    }
    
    func getLevels(for gameType: GameType, difficulty: GameDifficulty) -> [GameLevel] {
        return gameLevels.filter {
            $0.gameType == gameType && $0.difficulty == difficulty
        }.sorted { $0.levelNumber < $1.levelNumber }
    }
}

