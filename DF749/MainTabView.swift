//
//  MainTabView.swift
//  DF749
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @ObservedObject var dataManager = GameDataManager.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            RealmsView()
                .tabItem {
                    Image(systemName: "gamecontroller.fill")
                    Text("Realms")
                }
                .tag(1)
            
            RewardsView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Rewards")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(3)
        }
        .accentColor(.appAccent)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.appBackground.opacity(0.95))
            
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.white.opacity(0.5))
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.white.opacity(0.5))]
            
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.appAccent)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.appAccent)]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

