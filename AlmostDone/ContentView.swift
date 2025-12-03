//
//  ContentView.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var systemColorScheme
    @Query private var settings: [AppSettings]
    @AppStorage("appTheme") private var appTheme: String = "auto"
    
    var body: some View {
        ZStack {
            // Custom Background Logic
            if activeColorScheme == .dark {
                Color.cursorDark.ignoresSafeArea()
            } else {
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            }
            
            TabView {
                MainTimelineView()
                    .tabItem {
                        Label("Timeline", systemImage: "timeline.selection")
                    }
                
                StatisticsView()
                    .tabItem {
                        Label("Statistics", systemImage: "chart.bar.fill")
                    }
                
                SecondChanceView()
                    .tabItem {
                        Label("Second Chance", systemImage: "arrow.triangle.2.circlepath.circle.fill")
                    }
                
                VictoriesView()
                    .tabItem {
                        Label("Victories", systemImage: "trophy.fill")
                    }
            }
            // Make TabView transparent to show custom background
            .scrollContentBackground(.hidden) 
            .onAppear {
                // Configure Tab Bar appearance for transparency
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithDefaultBackground()
                if activeColorScheme == .dark {
                    tabBarAppearance.backgroundColor = UIColor.cursorDark
                }
                UITabBar.appearance().standardAppearance = tabBarAppearance
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                
                
                DataManager.shared.initializeDefaultSettings(context: modelContext)
                
                // Sync theme from settings to AppStorage
                if let theme = settings.first?.theme {
                    appTheme = theme
                }
                
                // Check for expired second chances
                SecondChanceManager.shared.checkExpiredSecondChances(context: modelContext)
                
                // Check for automatic second chance
                if let appSettings = try? modelContext.fetch(FetchDescriptor<AppSettings>()).first {
                    SecondChanceManager.shared.selectAutomaticSecondChance(context: modelContext, settings: appSettings)
                }
            }
            .onChange(of: settings.first?.theme) { oldValue, newValue in
                if let theme = newValue {
                    appTheme = theme
                }
                updateTabBarAppearance()
            }
            .onChange(of: systemColorScheme) { _, _ in
                 updateTabBarAppearance()
            }
        }
        .preferredColorScheme(activeColorScheme)
    }
    
    private var activeColorScheme: ColorScheme? {
        switch appTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil // auto - use system
        }
    }
    
    private func updateTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        
        let isDark: Bool
        if let scheme = activeColorScheme {
            isDark = scheme == .dark
        } else {
            isDark = systemColorScheme == .dark
        }
        
        if isDark {
            tabBarAppearance.backgroundColor = UIColor.cursorDark
            // Optional: Remove border line for cleaner look
             tabBarAppearance.shadowColor = nil
             tabBarAppearance.shadowImage = nil
        } else {
            tabBarAppearance.backgroundColor = .systemBackground
        }
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [AlmostMoment.self, AppSettings.self, Achievement.self])
}
