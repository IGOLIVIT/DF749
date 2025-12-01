//
//  GlowingCard.swift
//  DF749
//

import SwiftUI

struct GlowingCard<Content: View>: View {
    let content: Content
    var glowColor: Color = .appAccent
    
    init(glowColor: Color = .appAccent, @ViewBuilder content: () -> Content) {
        self.glowColor = glowColor
        self.content = content()
    }
    
    @State private var isAnimating = false
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.05), Color.white.opacity(0.02)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [glowColor.opacity(0.3), glowColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: glowColor.opacity(isAnimating ? 0.4 : 0.2), radius: 16, y: 8)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

struct RealmBackground: View {
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            // Abstract waves
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    path.move(to: CGPoint(x: 0, y: height * 0.6))
                    path.addCurve(
                        to: CGPoint(x: width, y: height * 0.5),
                        control1: CGPoint(x: width * 0.3, y: height * 0.3),
                        control2: CGPoint(x: width * 0.7, y: height * 0.7)
                    )
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [Color.appAccent.opacity(0.05), Color.appAccent.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    path.move(to: CGPoint(x: 0, y: height * 0.3))
                    path.addCurve(
                        to: CGPoint(x: width, y: height * 0.4),
                        control1: CGPoint(x: width * 0.4, y: height * 0.1),
                        control2: CGPoint(x: width * 0.6, y: height * 0.5)
                    )
                    path.addLine(to: CGPoint(x: width, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [Color.appSecondary.opacity(0.04), Color.appSecondary.opacity(0.01)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
}


