//
//  TempoShiftRunnerGame.swift
//  DF749
//

import SwiftUI

struct TempoShiftRunnerGame: View {
    let level: GameLevel
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataManager = GameDataManager.shared
    
    @State private var currentLane: Int = 1 // 0, 1, 2 (left, center, right)
    @State private var obstacles: [Obstacle] = []
    @State private var gameRunning = false
    @State private var score: Int = 0
    @State private var targetScore: Int = 20
    @State private var showingResult = false
    @State private var gameWon = false
    @State private var gameLost = false
    @State private var beatInterval: Double = 1.0
    @State private var spawnTimer: Timer?
    @State private var updateTimer: Timer?
    
    struct Obstacle: Identifiable {
        let id = UUID()
        var lane: Int
        var position: CGFloat // 0 to 1, where 1 is at bottom
    }
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
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
                            Image(systemName: "star.fill")
                                .foregroundColor(.appAccent)
                            Text("\(score)/\(targetScore)")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Game area
                    GeometryReader { geometry in
                        let gameAreaHeight: CGFloat = 500
                        
                        ZStack {
                            // Lane dividers
                            HStack(spacing: 0) {
                                ForEach(0..<3) { lane in
                                    Rectangle()
                                        .fill(Color.white.opacity(0.05))
                                        .overlay(
                                            Rectangle()
                                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                }
                            }
                            
                            // Obstacles
                            ForEach(obstacles) { obstacle in
                                ObstacleView()
                                    .position(
                                        x: getLaneXPosition(obstacle.lane, width: geometry.size.width),
                                        y: gameAreaHeight * obstacle.position
                                    )
                            }
                            
                            // Player
                            PlayerShip()
                                .position(
                                    x: getLaneXPosition(currentLane, width: geometry.size.width),
                                    y: gameAreaHeight - 80
                                )
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentLane)
                        }
                        .frame(height: gameAreaHeight)
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(20)
                    }
                    .frame(height: 500)
                    .padding(.horizontal, 24)
                    
                    // Controls
                    if !gameRunning {
                        VStack(spacing: 12) {
                            Text("Tap lanes to shift and avoid obstacles")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            PrimaryButton(title: "Start") {
                                startGame()
                            }
                            .padding(.horizontal, 24)
                        }
                    } else {
                        HStack(spacing: 12) {
                            ForEach(0..<3) { lane in
                                Button(action: {
                                    withAnimation {
                                        currentLane = lane
                                    }
                                }) {
                                    Text(["Left", "Center", "Right"][lane])
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 50)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(currentLane == lane ? Color.appAccent.opacity(0.5) : Color.white.opacity(0.1))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(currentLane == lane ? Color.appAccent : Color.white.opacity(0.3), lineWidth: 2)
                                        )
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
        .ignoresSafeArea()
        .onDisappear {
            gameRunning = false
            spawnTimer?.invalidate()
            updateTimer?.invalidate()
        }
        .alert(isPresented: $showingResult) {
            Alert(
                title: Text(gameWon ? "Level Complete!" : "Game Over"),
                message: Text(gameWon ? "Perfect rhythm! Level cleared!" : "You collided with an obstacle. Try again!"),
                dismissButton: .default(Text(gameWon ? "Continue" : "Retry")) {
                    if gameWon {
                        dataManager.completeLevel(id: level.id, rewardType: .flowRibbons)
                        dismiss()
                    } else {
                        resetGame()
                    }
                }
            )
        }
    }
    
    func getLaneXPosition(_ lane: Int, width: CGFloat) -> CGFloat {
        let laneWidth = width / 3
        return laneWidth * CGFloat(lane) + laneWidth / 2
    }
    
    func startGame() {
        gameRunning = true
        score = 0
        obstacles = []
        
        // Set difficulty parameters
        switch level.difficulty {
        case .easy:
            beatInterval = 1.2
            targetScore = 30 + (level.levelNumber * 5)
        case .medium:
            beatInterval = 0.9
            targetScore = 40 + (level.levelNumber * 6)
        case .hard:
            beatInterval = 0.7
            targetScore = 50 + (level.levelNumber * 8)
        }
        
        startGameLoop()
    }
    
    func startGameLoop() {
        // Clean up existing timers
        spawnTimer?.invalidate()
        updateTimer?.invalidate()
        
        spawnTimer = Timer.scheduledTimer(withTimeInterval: beatInterval, repeats: true) { [self] timer in
            if !gameRunning {
                timer.invalidate()
                return
            }
            
            // Spawn obstacle
            let randomLane = Int.random(in: 0...2)
            obstacles.append(Obstacle(lane: randomLane, position: 0))
            
            // Move obstacles
            moveObstacles()
            
            // Check win condition
            if score >= targetScore {
                let success = UINotificationFeedbackGenerator()
                success.notificationOccurred(.success)
                gameWon = true
                gameRunning = false
                showingResult = true
                timer.invalidate()
                updateTimer?.invalidate()
            }
        }
        
        // Update loop for smooth movement
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [self] timer in
            if !gameRunning {
                timer.invalidate()
                return
            }
            moveObstacles()
        }
    }
    
    func moveObstacles() {
        for index in obstacles.indices {
            obstacles[index].position += 0.01
            
            // Check collision (player is at bottom, obstacles fall from top)
            if obstacles[index].position > 0.80 && obstacles[index].position < 0.90 {
                if obstacles[index].lane == currentLane {
                    // Collision!
                    gameRunning = false
                    gameLost = true
                    showingResult = true
                    return
                }
            }
            
            // Remove off-screen obstacles and add score
            if obstacles[index].position > 1.0 {
                score += 1
            }
        }
        
        obstacles.removeAll { $0.position > 1.1 }
    }
    
    func resetGame() {
        gameRunning = false
        currentLane = 1
        obstacles = []
        score = 0
        gameLost = false
        gameWon = false
    }
}

struct ObstacleView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(
                LinearGradient(
                    colors: [Color.red.opacity(0.8), Color.red.opacity(0.5)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 60, height: 40)
            .shadow(color: Color.red.opacity(0.5), radius: 8)
    }
}

struct PlayerShip: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [Color.appAccent, Color.appAccent.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 50, height: 50)
            
            Image(systemName: "shield.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
        }
        .shadow(color: Color.appAccent.opacity(0.6), radius: 12)
    }
}

