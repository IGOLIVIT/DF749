//
//  RootView.swift
//  DF749
//

import SwiftUI

struct RootView: View {
    @ObservedObject var dataManager = GameDataManager.shared
    
    var body: some View {
        Group {
            if dataManager.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
    }
}

