//
//  PrimaryButton.swift
//  DF749
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isSecondary: Bool = false
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: isSecondary ? [Color.appSecondary, Color.appSecondary.opacity(0.8)] : [Color.appAccent, Color.appAccent.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(AppTheme.cornerRadius)
                .shadow(color: (isSecondary ? Color.appSecondary : Color.appAccent).opacity(0.4), radius: 12, y: 6)
                .scaleEffect(isPressed ? 0.96 : 1.0)
        }
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appSecondary, lineWidth: 2)
                        .background(Color.appSecondary.opacity(0.1))
                )
                .cornerRadius(16)
        }
    }
}

