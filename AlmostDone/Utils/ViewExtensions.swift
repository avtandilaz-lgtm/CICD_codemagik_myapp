//
//  View+Extensions.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI

extension View {
    func applyAppBackground() -> some View {
        self.background {
            Color.appBackgroundLogic
                .ignoresSafeArea()
        }
    }
}

extension Color {
    static var appBackgroundLogic: Color {
        Color("AppBackgroundLogic") // Fallback or usage in code
    }
}

struct AppBackgroundModifier: ViewModifier {
    @AppStorage("appTheme") private var appTheme: String = "auto"
    @Environment(\.colorScheme) private var systemColorScheme
    
    func body(content: Content) -> some View {
        content
            .background {
                if isDark {
                    Color.cursorDark.ignoresSafeArea()
                } else {
                    Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                }
            }
    }
    
    private var isDark: Bool {
        if appTheme == "dark" { return true }
        if appTheme == "light" { return false }
        return systemColorScheme == .dark
    }
}

extension View {
    func withAppBackground() -> some View {
        modifier(AppBackgroundModifier())
    }
}

