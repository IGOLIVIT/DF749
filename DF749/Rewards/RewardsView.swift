//
//  RewardsView.swift
//  DF749
//

import SwiftUI

struct RewardsView: View {
    @ObservedObject var dataManager = GameDataManager.shared
    
    var body: some View {
        ZStack {
            RealmBackground()
            
            ScrollView {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 20)
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Rewards")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Ethereal treasures collected on your journey")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    
                    // Total rewards highlight
                    GlowingCard(glowColor: .appAccent) {
                        VStack(spacing: 16) {
                            Text("Total Rewards")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("\(dataManager.totalUnlockedRewards)")
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .foregroundColor(.appAccent)
                            
                            Text("Ethereal items collected")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(24)
                    }
                    .padding(.horizontal, 24)
                    
                    // Individual reward cards
                    VStack(spacing: 16) {
                        ForEach(RewardType.allCases, id: \.self) { rewardType in
                            RewardCard(
                                rewardType: rewardType,
                                count: dataManager.rewards.count(for: rewardType)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                        .frame(height: 100)
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct RewardCard: View {
    let rewardType: RewardType
    let count: Int
    
    @State private var glowIntensity: Double = 0.2
    @State private var scale: CGFloat = 1.0
    @State private var previousCount: Int = 0
    
    var accentColor: Color {
        switch rewardType {
        case .shardsOfInsight: return .appAccent
        case .flowRibbons: return .appSecondary
        case .realmEchoes: return .purple
        }
    }
    
    var icon: String {
        switch rewardType {
        case .shardsOfInsight: return "sparkles"
        case .flowRibbons: return "wind"
        case .realmEchoes: return "waveform.circle.fill"
        }
    }
    
    var body: some View {
        GlowingCard(glowColor: accentColor) {
            HStack(spacing: 20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [accentColor.opacity(0.4), accentColor.opacity(0.1)],
                                center: .center,
                                startRadius: 10,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: icon)
                        .font(.system(size: 36))
                        .foregroundColor(accentColor)
                }
                .shadow(color: accentColor.opacity(glowIntensity), radius: 20)
                
                // Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(rewardType.rawValue)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(rewardType.description)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Count
                VStack(spacing: 4) {
                    Text("\(count)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(accentColor)
                    
                    Text("collected")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(20)
        }
        .scaleEffect(scale)
        .onAppear {
            previousCount = count
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowIntensity = 0.6
            }
        }
        .onChange(of: count) { newValue in
            // Only animate if count actually increased
            if newValue > previousCount && previousCount > 0 {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    scale = 1.1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        scale = 1.0
                    }
                }
            }
            previousCount = newValue
        }
    }
}

