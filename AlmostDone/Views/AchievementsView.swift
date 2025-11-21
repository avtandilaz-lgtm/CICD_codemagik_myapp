//
//  AchievementsView.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI
import SwiftData

struct AchievementsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var unlockedAchievements: [Achievement]
    
    @State private var selectedAchievement: AchievementType?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Your Trophies")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    LazyVGrid(columns: columns, spacing: 30) {
                        ForEach(AchievementType.allCases, id: \.self) { type in
                            AchievementGridItem(
                                type: type,
                                isUnlocked: isUnlocked(type)
                            )
                            .onTapGesture {
                                selectedAchievement = type
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedAchievement) { type in
                AchievementDetailSheet(type: type, isUnlocked: isUnlocked(type))
                    .presentationDetents([.height(300)])
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func isUnlocked(_ type: AchievementType) -> Bool {
        unlockedAchievements.contains(where: { $0.type == type.rawValue })
    }
}

extension AchievementType: Identifiable {
    public var id: String { rawValue }
}

struct AchievementGridItem: View {
    let type: AchievementType
    let isUnlocked: Bool
    
    // Increased size by ~20%
    // Previous: 80pt -> New: 96pt
    let circleSize: CGFloat = 96
    let iconSize: CGFloat = 38
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: circleSize, height: circleSize)
                
                Image(systemName: type.iconName)
                    .font(.system(size: iconSize))
                    .foregroundColor(isUnlocked ? .yellow : .gray)
                
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .offset(x: 24, y: 24)
                }
            }
            .shadow(color: isUnlocked ? .yellow.opacity(0.5) : .clear, radius: 10)
            
            Text(type.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(isUnlocked ? .primary : .secondary)
                .frame(height: 40, alignment: .top) // Fixed height for text alignment
        }
        .opacity(isUnlocked ? 1.0 : 0.6)
        .scaleEffect(isUnlocked ? 1.05 : 1.0)
    }
}

struct AchievementDetailSheet: View {
    let type: AchievementType
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: type.iconName)
                    .font(.system(size: 60))
                    .foregroundColor(isUnlocked ? .yellow : .gray)
            }
            .shadow(color: isUnlocked ? .yellow.opacity(0.5) : .clear, radius: 15)
            
            VStack(spacing: 8) {
                Text(type.title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(type.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                if isUnlocked {
                    Text("UNLOCKED")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .cornerRadius(8)
                        .padding(.top, 8)
                } else {
                    Text("LOCKED")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.top, 8)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}
