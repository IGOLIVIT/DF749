//
//  OnboardingView.swift
//  DF749
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            RealmBackground()
            
            TabView(selection: $currentPage) {
                OnboardingPage1()
                    .tag(0)
                
                OnboardingPage2()
                    .tag(1)
                
                OnboardingPage3()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .ignoresSafeArea()
    }
}

struct OnboardingPage1: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 80)
                
                // Animated abstract illustration
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.appAccent.opacity(0.3), Color.appAccent.opacity(0.05)],
                                center: .center,
                                startRadius: 20,
                                endRadius: 120
                            )
                        )
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .stroke(Color.appSecondary, lineWidth: 3)
                        .frame(width: 180, height: 180)
                    
                    Circle()
                        .fill(Color.appAccent)
                        .frame(width: 80, height: 80)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                VStack(spacing: 16) {
                    Text("Welcome, Traveler")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("You are about to embark on a journey through mysterious realms, each holding unique challenges and hidden patterns")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .opacity(opacity)
                
                Spacer()
                    .frame(height: 100)
            }
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                scale = 1.0
            }
            withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
                opacity = 1.0
            }
        }
    }
}

struct OnboardingPage2: View {
    @State private var offset: CGFloat = 50
    @State private var opacity: Double = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 80)
                
                // Animated illustration
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                colors: [Color.appSecondary.opacity(0.2), Color.appSecondary.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(45))
                    
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.appAccent.opacity(0.6))
                            .frame(width: 40, height: 40)
                            .offset(x: CGFloat(index - 1) * 60)
                    }
                }
                .offset(y: offset)
                .opacity(opacity)
                
                VStack(spacing: 16) {
                    Text("Discover the Realms")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Three distinct realms await, each containing unique puzzles. Progress through levels, unlock new difficulties, and master the paths")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .opacity(opacity)
                
                Spacer()
                    .frame(height: 100)
            }
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                offset = 0
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
                opacity = 1.0
            }
        }
    }
}

struct OnboardingPage3: View {
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 80)
                
                // Animated illustration
                ZStack {
                    ForEach(0..<6) { index in
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.appSecondary, lineWidth: 2)
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(Double(index) * 60 + rotation))
                    }
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.appAccent, Color.appAccent.opacity(0.6)],
                                center: .center,
                                startRadius: 10,
                                endRadius: 50
                            )
                        )
                        .frame(width: 80, height: 80)
                }
                .frame(height: 200)
                .opacity(opacity)
                
                VStack(spacing: 16) {
                    Text("Collect Ethereal Rewards")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Text("Each challenge you complete grants you mystical rewards. Track your progress and unlock the full depth of each realm")
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .opacity(opacity)
                
                Spacer()
                    .frame(height: 40)
                
                PrimaryButton(title: "Start Journey") {
                    withAnimation {
                        GameDataManager.shared.hasCompletedOnboarding = true
                    }
                }
                .padding(.horizontal, 32)
                .opacity(opacity)
                
                Spacer()
                    .frame(height: 60)
            }
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.3)) {
                opacity = 1.0
            }
        }
    }
}

