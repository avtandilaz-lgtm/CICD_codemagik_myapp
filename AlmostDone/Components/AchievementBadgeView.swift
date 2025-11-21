//
//  AchievementBadgeView.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI

struct AchievementBadgeView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.iconName)
                .font(.system(size: 40))
                .foregroundColor(.yellow)
                .frame(width: 80, height: 80)
                .background(
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
                )
            
            Text(achievement.title)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text(achievement.achievementDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding()
        .frame(width: 150)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

