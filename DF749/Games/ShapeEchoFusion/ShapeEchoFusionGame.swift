//
//  ShapeEchoFusionGame.swift
//  DF749
//

import SwiftUI

struct ShapeEchoFusionGame: View {
    let level: GameLevel
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataManager = GameDataManager.shared
    
    @State private var shapes: [ShapeType] = []
    @State private var sequence: [ShapeType] = []
    @State private var playerSequence: [ShapeType] = []
    @State private var showingSequence = false
    @State private var currentShapeIndex = 0
    @State private var attemptsLeft = 3
    @State private var showingResult = false
    @State private var gameWon = false
    @State private var sequenceLength = 3
    
    enum ShapeType: CaseIterable {
        case circle, square, triangle, diamond, hexagon, star
        
        var name: String {
            switch self {
            case .circle: return "Circle"
            case .square: return "Square"
            case .triangle: return "Triangle"
            case .diamond: return "Diamond"
            case .hexagon: return "Hexagon"
            case .star: return "Star"
            }
        }
        
        var icon: String {
            switch self {
            case .circle: return "circle.fill"
            case .square: return "square.fill"
            case .triangle: return "triangle.fill"
            case .diamond: return "diamond.fill"
            case .hexagon: return "hexagon.fill"
            case .star: return "star.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .circle: return .appAccent
            case .square: return .appSecondary
            case .triangle: return .purple
            case .diamond: return .pink
            case .hexagon: return .cyan
            case .star: return .green
            }
        }
    }
    
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
                    VStack(spacing: 8) {
                        if showingSequence {
                            Text("Watch carefully...")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.appAccent)
                        } else {
                            Text("Repeat the sequence")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.appSecondary)
                            
                            Text("\(playerSequence.count) / \(sequence.count)")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .frame(height: 60)
                    
                    // Display area
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.3))
                            .frame(height: 200)
                        
                        if showingSequence && currentShapeIndex < sequence.count {
                            ShapeView(shape: sequence[currentShapeIndex], size: 120)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(height: 200)
                    .padding(.horizontal, 24)
                    
                    // Shape selection grid
                    if !showingSequence {
                        VStack(spacing: 16) {
                            Text("Tap shapes in order:")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(shapes, id: \.name) { shape in
                                    Button(action: {
                                        handleShapeTap(shape)
                                    }) {
                                        ShapeView(shape: shape, size: 80)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    // Start/Reset button
                    if !showingSequence && playerSequence.isEmpty {
                        PrimaryButton(title: "Watch Sequence") {
                            startSequence()
                        }
                        .padding(.horizontal, 24)
                    }
                    
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
                title: Text(gameWon ? "Level Complete!" : "Incorrect"),
                message: Text(gameWon ? "Perfect recall! Sequence mastered!" : "Wrong sequence. \(attemptsLeft) attempts remaining."),
                dismissButton: .default(Text(gameWon ? "Continue" : "Try Again")) {
                    if gameWon {
                        dataManager.completeLevel(id: level.id, rewardType: .realmEchoes)
                        dismiss()
                    } else {
                        resetGame()
                    }
                }
            )
        }
    }
    
    func setupLevel() {
        // Determine sequence length based on difficulty and level
        switch level.difficulty {
        case .easy:
            sequenceLength = 4 + level.levelNumber
            shapes = Array(ShapeType.allCases.prefix(4))
        case .medium:
            sequenceLength = 5 + level.levelNumber + 1
            shapes = Array(ShapeType.allCases.prefix(5))
        case .hard:
            sequenceLength = 6 + level.levelNumber + 2
            shapes = ShapeType.allCases
        }
        
        sequenceLength = min(sequenceLength, 12) // Cap at 12
        
        // Generate random sequence
        sequence = (0..<sequenceLength).map { _ in shapes.randomElement()! }
        playerSequence = []
        attemptsLeft = 3
    }
    
    func startSequence() {
        showingSequence = true
        currentShapeIndex = 0
        playerSequence = []
        
        showSequenceAnimation()
    }
    
    func showSequenceAnimation() {
        if currentShapeIndex < sequence.count {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                // Shape already visible via currentShapeIndex
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeOut(duration: 0.3)) {
                    currentShapeIndex += 1
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    if currentShapeIndex < sequence.count {
                        showSequenceAnimation()
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                showingSequence = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    func handleShapeTap(_ shape: ShapeType) {
        playerSequence.append(shape)
        
        // Check if correct so far
        let currentIndex = playerSequence.count - 1
        if playerSequence[currentIndex] != sequence[currentIndex] {
            // Wrong!
            attemptsLeft -= 1
            if attemptsLeft <= 0 {
                gameWon = false
                showingResult = true
            } else {
                gameWon = false
                showingResult = true
            }
        } else if playerSequence.count == sequence.count {
            // Complete and correct!
            let success = UINotificationFeedbackGenerator()
            success.notificationOccurred(.success)
            gameWon = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showingResult = true
            }
        }
    }
    
    func resetGame() {
        playerSequence = []
        showingSequence = false
        currentShapeIndex = 0
    }
}

struct ShapeView: View {
    let shape: ShapeEchoFusionGame.ShapeType
    let size: CGFloat
    
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [shape.color.opacity(0.3), shape.color.opacity(0.05)],
                        center: .center,
                        startRadius: 10,
                        endRadius: size / 2
                    )
                )
                .frame(width: size, height: size)
            
            Image(systemName: shape.icon)
                .font(.system(size: size * 0.5))
                .foregroundColor(shape.color)
        }
        .scaleEffect(isPulsing ? 1.1 : 1.0)
        .shadow(color: shape.color.opacity(0.6), radius: 16)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

