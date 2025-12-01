//
//  GameDetailView.swift
//  DF749
//

import SwiftUI

struct GameDetailView: View {
    let gameType: GameType
    @ObservedObject var dataManager = GameDataManager.shared
    @State private var selectedDifficulty: GameDifficulty = .easy
    @Environment(\.presentationMode) var presentationMode
    
    var levelsForSelectedDifficulty: [GameLevel] {
        dataManager.getLevels(for: gameType, difficulty: selectedDifficulty)
    }
    
    var body: some View {
        ZStack {
            RealmBackground()
            
            // Back button
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    .padding(.leading, 24)
                    .padding(.top, 50)
                    
                    Spacer()
                }
                
                Spacer()
            }
            .zIndex(1)
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 70)
                    
                    // Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [colorForGame(gameType).opacity(0.3), colorForGame(gameType).opacity(0.05)],
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: iconForGame(gameType))
                                .font(.system(size: 48))
                                .foregroundColor(colorForGame(gameType))
                        }
                        
                        Text(gameType.rawValue)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(gameType.description)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    // Difficulty selector
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select Difficulty")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                        
                        HStack(spacing: 12) {
                            ForEach(GameDifficulty.allCases, id: \.self) { difficulty in
                                Button(action: {
                                    withAnimation {
                                        selectedDifficulty = difficulty
                                    }
                                }) {
                                    VStack(spacing: 8) {
                                        Text(difficulty.rawValue)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(selectedDifficulty == difficulty ? .white : .white.opacity(0.6))
                                        
                                        if selectedDifficulty == difficulty {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(colorForGame(gameType))
                                                .frame(height: 3)
                                        } else {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.clear)
                                                .frame(height: 3)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Levels grid
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Select Level")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(levelsForSelectedDifficulty) { level in
                                if level.isUnlocked {
                                    NavigationLink(destination: gameViewForLevel(level)) {
                                        LevelButtonView(level: level, gameType: gameType)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    LevelButtonView(level: level, gameType: gameType)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer()
                        .frame(height: 100)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    func gameViewForLevel(_ level: GameLevel) -> some View {
        switch gameType {
        case .pulseGridPath:
            PulseGridPathGame(level: level)
        case .tempoShiftRunner:
            TempoShiftRunnerGame(level: level)
        case .shapeEchoFusion:
            ShapeEchoFusionGame(level: level)
        }
    }
    
    func iconForGame(_ gameType: GameType) -> String {
        switch gameType {
        case .pulseGridPath: return "square.grid.3x3.fill"
        case .tempoShiftRunner: return "waveform.path"
        case .shapeEchoFusion: return "diamond.fill"
        }
    }
    
    func colorForGame(_ gameType: GameType) -> Color {
        switch gameType {
        case .pulseGridPath: return .appAccent
        case .tempoShiftRunner: return .appSecondary
        case .shapeEchoFusion: return .purple
        }
    }
}

struct LevelButtonView: View {
    let level: GameLevel
    let gameType: GameType
    
    var body: some View {
        ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: level.isCompleted ? [Color.green.opacity(0.3), Color.green.opacity(0.1)] :
                                    level.isUnlocked ? [Color.white.opacity(0.1), Color.white.opacity(0.05)] :
                                    [Color.white.opacity(0.03), Color.white.opacity(0.01)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                level.isCompleted ? Color.green :
                                level.isUnlocked ? colorForGame(gameType).opacity(0.5) :
                                Color.white.opacity(0.2),
                                lineWidth: 2
                            )
                    )
                    .frame(height: 80)
                
                VStack(spacing: 8) {
                    if level.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.green)
                    } else if level.isUnlocked {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(colorForGame(gameType))
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    
                    Text("\(level.levelNumber)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(level.isUnlocked ? .white : .white.opacity(0.3))
                }
            }
    }
    
    func colorForGame(_ gameType: GameType) -> Color {
        switch gameType {
        case .pulseGridPath: return .appAccent
        case .tempoShiftRunner: return .appSecondary
        case .shapeEchoFusion: return .purple
        }
    }
}

