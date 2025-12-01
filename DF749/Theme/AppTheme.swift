//
//  AppTheme.swift
//  DF749
//

import SwiftUI

struct AppTheme {
    static let backgroundPrimary = Color("BackgroundPrimary")
    static let accentPrimary = Color("AccentPrimary")
    static let accentSecondary = Color("AccentSecondary")
    
    static let cornerRadius: CGFloat = 20
    static let cardPadding: CGFloat = 20
    static let spacing: CGFloat = 16
}

extension Color {
    static let appBackground = AppTheme.backgroundPrimary
    static let appAccent = AppTheme.accentPrimary
    static let appSecondary = AppTheme.accentSecondary
}


