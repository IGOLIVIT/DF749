//
//  RewardModels.swift
//  DF749
//

import Foundation

enum RewardType: String, CaseIterable, Codable {
    case shardsOfInsight = "Shards of Insight"
    case flowRibbons = "Flow Ribbons"
    case realmEchoes = "Realm Echoes"
    
    var description: String {
        switch self {
        case .shardsOfInsight:
            return "Crystallized fragments of understanding from completed challenges"
        case .flowRibbons:
            return "Ethereal strands representing mastery of rhythm and movement"
        case .realmEchoes:
            return "Resonant patterns captured from puzzle solutions"
        }
    }
}

struct Reward: Codable {
    var shardsOfInsight: Int = 0
    var flowRibbons: Int = 0
    var realmEchoes: Int = 0
    
    mutating func add(_ type: RewardType, amount: Int) {
        switch type {
        case .shardsOfInsight:
            shardsOfInsight += amount
        case .flowRibbons:
            flowRibbons += amount
        case .realmEchoes:
            realmEchoes += amount
        }
    }
    
    func count(for type: RewardType) -> Int {
        switch type {
        case .shardsOfInsight: return shardsOfInsight
        case .flowRibbons: return flowRibbons
        case .realmEchoes: return realmEchoes
        }
    }
}


