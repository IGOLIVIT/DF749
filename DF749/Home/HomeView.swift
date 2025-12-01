//
//  HomeView.swift
//  DF749
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var dataManager = GameDataManager.shared
    @Binding var selectedTab: Int
    
    @State private var cardScale: CGFloat = 0.95
    @State private var isLoaded = false
    
    var body: some View {
        ZStack {
            RealmBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 20)
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Journey")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Through the shifting realms")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    
                    // Main highlight card
                    GlowingCard {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Continue Your")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text("Realm Journey")
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                ZStack {
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [Color.appAccent.opacity(0.3), Color.appAccent.opacity(0.1)],
                                                center: .center,
                                                startRadius: 10,
                                                endRadius: 40
                                            )
                                        )
                                        .frame(width: 70, height: 70)
                                    
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 32))
                                        .foregroundColor(.appAccent)
                                }
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.2))
                            
                            HStack(spacing: 20) {
                                StatBubble(
                                    icon: "checkmark.circle.fill",
                                    value: "\(dataManager.totalCompletedLevels)",
                                    label: "Levels"
                                )
                                
                                StatBubble(
                                    icon: "star.fill",
                                    value: "\(dataManager.totalUnlockedRewards)",
                                    label: "Rewards"
                                )
                                
                                StatBubble(
                                    icon: "flame.fill",
                                    value: "\(dataManager.totalGamesPlayed)",
                                    label: "Plays"
                                )
                            }
                        }
                        .padding(24)
                    }
                    .padding(.horizontal, 24)
                    .scaleEffect(cardScale)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                            cardScale = 1.0
                        }
                    }
                    
                    // Explore button
                    VStack(spacing: 16) {
                        PrimaryButton(title: "Explore Realms") {
                            withAnimation {
                                selectedTab = 1
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Quick stats
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Progress Overview")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                        
                        VStack(spacing: 12) {
                            ForEach(GameType.allCases, id: \.self) { gameType in
                                GameProgressCard(gameType: gameType)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer()
                        .frame(height: 100)
                }
                .opacity(isLoaded ? 1 : 0)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeIn(duration: 0.3).delay(0.1)) {
                isLoaded = true
            }
        }
    }
}

struct StatBubble: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.appAccent)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

struct GameProgressCard: View {
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
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorForGame(gameType).opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: iconForGame(gameType))
                        .font(.system(size: 28))
                        .foregroundColor(colorForGame(gameType))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(gameType.rawValue)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("\(completedLevels) / \(gameType.totalLevels) levels completed")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [colorForGame(gameType), colorForGame(gameType).opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progressPercentage, height: 6)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: progressPercentage)
                }
            }
            .frame(height: 6)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(colorForGame(gameType).opacity(0.2), lineWidth: 1)
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

