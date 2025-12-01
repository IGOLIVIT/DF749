//
//  PulseGridPathGame.swift
//  DF749
//

import SwiftUI

struct PulseGridPathGame: View {
    let level: GameLevel
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataManager = GameDataManager.shared
    
    @State private var gridSize: Int = 3
    @State private var correctPath: [Int] = []
    @State private var selectedTiles: [Int] = []
    @State private var attemptsLeft: Int = 3
    @State private var showingResult = false
    @State private var gameWon = false
    @State private var pulsingTiles: Set<Int> = []
    @State private var showHintPhase = true
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 60)
                    
                    // Header
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("Level \(level.levelNumber)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(level.difficulty.rawValue)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.appAccent)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("\(attemptsLeft)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Instructions
                    if showHintPhase {
                        Text("Watch the glowing path...")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.appAccent)
                            .transition(.opacity)
                    } else {
                        Text("Tap the tiles in sequence")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.appSecondary)
                            .transition(.opacity)
                    }
                    
                    // Grid
                    GeometryReader { geometry in
                        let maxSize: CGFloat = 400
                        let size = min(geometry.size.width - 48, maxSize)
                        let tileSize = (size - CGFloat(gridSize - 1) * 8) / CGFloat(gridSize)
                        
                        VStack(spacing: 8) {
                            ForEach(0..<gridSize, id: \.self) { row in
                                HStack(spacing: 8) {
                                    ForEach(0..<gridSize, id: \.self) { col in
                                        let index = row * gridSize + col
                                        GridTile(
                                            index: index,
                                            isCorrect: correctPath.contains(index),
                                            isSelected: selectedTiles.contains(index),
                                            isPulsing: pulsingTiles.contains(index),
                                            size: tileSize
                                        ) {
                                            if !showHintPhase {
                                                handleTileTap(index)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .frame(width: size, height: size)
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: min(UIScreen.main.bounds.width - 48, 400))
                    .padding(.horizontal, 24)
                    
                    // Reset button
                    SecondaryButton(title: "Reset") {
                        resetGame()
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                        .frame(height: 100)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            setupLevel()
        }
        .alert(isPresented: $showingResult) {
            Alert(
                title: Text(gameWon ? "Level Complete!" : "Try Again"),
                message: Text(gameWon ? "You discovered the correct path!" : "Not quite right. \(attemptsLeft) attempts remaining."),
                dismissButton: .default(Text(gameWon ? "Continue" : "Retry")) {
                    if gameWon {
                        dataManager.completeLevel(id: level.id, rewardType: .shardsOfInsight)
                        dismiss()
                    } else {
                        resetGame()
                        setupLevel()
                    }
                }
            )
        }
    }
    
    func setupLevel() {
        // Grid size based on difficulty and level
        switch level.difficulty {
        case .easy:
            gridSize = 3
        case .medium:
            gridSize = 4
        case .hard:
            gridSize = 5
        }
        
        // Generate correct path
        let pathLength = min(gridSize + level.levelNumber + 2, gridSize * gridSize)
        var path: [Int] = []
        var available = Set(0..<(gridSize * gridSize))
        
        for _ in 0..<pathLength {
            if let next = available.randomElement() {
                path.append(next)
                available.remove(next)
            }
        }
        
        correctPath = path
        attemptsLeft = 3
        showHintPhase = true
        selectedTiles = []
        
        // Show hint animation
        showHintSequence()
    }
    
    func showHintSequence() {
        pulsingTiles = []
        
        for (index, tile) in correctPath.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    pulsingTiles.insert(tile)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        let _ = pulsingTiles.remove(tile)
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(correctPath.count) * 0.5 + 0.5) {
            withAnimation {
                showHintPhase = false
            }
        }
    }
    
    func handleTileTap(_ index: Int) {
        if selectedTiles.contains(index) {
            return
        }
        
        selectedTiles.append(index)
        
        // Check if current sequence matches
        if selectedTiles.count <= correctPath.count {
            let currentIndex = selectedTiles.count - 1
            if selectedTiles[currentIndex] != correctPath[currentIndex] {
                // Wrong tile
                attemptsLeft -= 1
                if attemptsLeft <= 0 {
                    gameWon = false
                    showingResult = true
                } else {
                    // Visual feedback and reset
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        selectedTiles = []
                    }
                }
            } else if selectedTiles.count == correctPath.count {
                // All correct!
                let success = UINotificationFeedbackGenerator()
                success.notificationOccurred(.success)
                gameWon = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingResult = true
                }
            }
        }
    }
    
    func resetGame() {
        selectedTiles = []
        showHintPhase = true
        showHintSequence()
    }
}

struct GridTile: View {
    let index: Int
    let isCorrect: Bool
    let isSelected: Bool
    let isPulsing: Bool
    let size: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: isPulsing ? [Color.appAccent, Color.appAccent.opacity(0.6)] :
                                isSelected ? [Color.appSecondary, Color.appSecondary.opacity(0.6)] :
                                [Color.white.opacity(0.1), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isPulsing ? Color.appAccent :
                            isSelected ? Color.appSecondary :
                            Color.white.opacity(0.2),
                            lineWidth: isPulsing ? 3 : 2
                        )
                )
                .shadow(
                    color: isPulsing ? Color.appAccent.opacity(0.6) :
                           isSelected ? Color.appSecondary.opacity(0.4) :
                           Color.clear,
                    radius: isPulsing ? 12 : 8
                )
                .scaleEffect(isPulsing ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPulsing)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .frame(width: size, height: size)
        .buttonStyle(PlainButtonStyle())
    }
}

