//
//  SettingsView.swift
//  DF749
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var dataManager = GameDataManager.shared
    @State private var showingResetAlert = false
    
    var body: some View {
        ZStack {
            RealmBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 20)
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Settings")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Your journey statistics")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    
                    // Statistics
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Statistics")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 12) {
                            StatCard(
                                icon: "checkmark.circle.fill",
                                title: "Levels Completed",
                                value: "\(dataManager.totalCompletedLevels)",
                                color: .green
                            )
                            
                            StatCard(
                                icon: "gamecontroller.fill",
                                title: "Games Played",
                                value: "\(dataManager.totalGamesPlayed)",
                                color: .appAccent
                            )
                            
                            StatCard(
                                icon: "clock.fill",
                                title: "Play Time",
                                value: "\(dataManager.totalPlayTimeMinutes) min",
                                color: .appSecondary
                            )
                            
                            StatCard(
                                icon: "chart.bar.fill",
                                title: "Highest Difficulty",
                                value: dataManager.highestDifficulty.rawValue,
                                color: .purple
                            )
                            
                            StatCard(
                                icon: "star.fill",
                                title: "Total Rewards",
                                value: "\(dataManager.totalUnlockedRewards)",
                                color: .yellow
                            )
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Game breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Progress by Realm")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 12) {
                            ForEach(GameType.allCases, id: \.self) { gameType in
                                GameStatCard(gameType: gameType)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Reset button
                    VStack(spacing: 16) {
                        Button(action: {
                            showingResetAlert = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Reset All Progress")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .fill(Color.red.opacity(0.2))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                                    .stroke(Color.red, lineWidth: 2)
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        Text("This will erase all your progress and rewards")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    Spacer()
                        .frame(height: 100)
                }
            }
        }
        .ignoresSafeArea()
        .alert(isPresented: $showingResetAlert) {
            Alert(
                title: Text("⚠️ Reset All Progress?"),
                message: Text("This will permanently delete all your progress, levels, and rewards. This action cannot be undone."),
                primaryButton: .destructive(Text("Reset Everything")) {
                    dataManager.resetAllProgress()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct GameStatCard: View {
    let gameType: GameType
    @ObservedObject var dataManager = GameDataManager.shared
    
    var completedLevels: Int {
        dataManager.gameLevels.filter { $0.gameType == gameType && $0.isCompleted }.count
    }
    
    var progressPercentage: Double {
        Double(completedLevels) / Double(gameType.totalLevels)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconForGame(gameType))
                    .font(.system(size: 20))
                    .foregroundColor(colorForGame(gameType))
                    .frame(width: 30)
                
                Text(gameType.rawValue)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(completedLevels) / \(gameType.totalLevels)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [colorForGame(gameType), colorForGame(gameType).opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progressPercentage, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorForGame(gameType).opacity(0.3), lineWidth: 1)
        )
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

