//
//  RealmsView.swift
//  DF749
//

import SwiftUI

struct RealmsView: View {
    @ObservedObject var dataManager = GameDataManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                RealmBackground()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer()
                            .frame(height: 20)
                        
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("The Realms")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Choose your challenge")
                                .font(.system(size: 18, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        
                        // Games list
                        VStack(spacing: 20) {
                            ForEach(GameType.allCases, id: \.self) { gameType in
                                NavigationLink(destination: GameDetailView(gameType: gameType)) {
                                    GameRealmCard(gameType: gameType)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                            .frame(height: 100)
                    }
                }
            }
            .ignoresSafeArea()
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct GameRealmCard: View {
    let gameType: GameType
    @ObservedObject var dataManager = GameDataManager.shared
    
    @State private var isAnimating = false
    
    var completedCount: Int {
        dataManager.gameLevels.filter { $0.gameType == gameType && $0.isCompleted }.count
    }
    
    var progressPercentage: Double {
        Double(completedCount) / Double(gameType.totalLevels)
    }
    
    var body: some View {
        GlowingCard(glowColor: colorForGame(gameType)) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [colorForGame(gameType).opacity(0.3), colorForGame(gameType).opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: iconForGame(gameType))
                            .font(.system(size: 32))
                            .foregroundColor(colorForGame(gameType))
                    }
                    
                    // Info
                    VStack(alignment: .leading, spacing: 6) {
                        Text(gameType.rawValue)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(gameType.description)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(colorForGame(gameType))
                }
                
                // Progress bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        Text("\(completedCount) / \(gameType.totalLevels)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
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
                                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: progressPercentage)
                        }
                    }
                    .frame(height: 8)
                }
            }
            .padding(20)
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

