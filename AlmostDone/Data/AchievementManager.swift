//
//  AchievementManager.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class AchievementManager {
    static let shared = AchievementManager()
    
    private init() {}
    
    func checkAchievements(context: ModelContext) {
        // Get all moments
        let descriptor = FetchDescriptor<AlmostMoment>()
        guard let moments = try? context.fetch(descriptor) else { return }
        
        let victories = moments.filter { $0.isVictory }
        
        // Check specific achievements
        
        // 1. First Step (First almost moment)
        if !moments.isEmpty {
            unlockAchievement(.firstAlmost, context: context)
        }
        
        // 2. Century (100 almost moments)
        if moments.count >= 100 {
            unlockAchievement(.hundredAlmost, context: context)
        }
        
        // 3. Champion (10 victories)
        if victories.count >= 10 {
            unlockAchievement(.tenVictories, context: context)
        }
        
        // 4. Love Warrior (Year without love setbacks)
        let loveSetbacks = moments.filter { 
            $0.categoryEnum == .love && 
            !$0.isVictory && 
            $0.timestamp > Calendar.current.date(byAdding: .year, value: -1, to: Date())! 
        }
        
        if loveSetbacks.isEmpty && moments.contains(where: { $0.categoryEnum == .love }) {
             unlockAchievement(.yearWithoutLoveSetbacks, context: context)
        }
        
        // 5. So Close (Almost moment at 100% closeness)
        if moments.contains(where: { $0.closenessPercentage == 100 && !$0.isVictory }) {
            unlockAchievement(.perfectCloseness, context: context)
        }
        
        // New Achievements Logic
        
        // 7. World Traveler (3 different locations)
        // Simple distinct check on lat/lon pairs rounded to 1 decimal place (approx 11km)
        let uniqueLocations = Set(moments.compactMap { moment -> String? in
            guard let lat = moment.latitude, let lon = moment.longitude else { return nil }
            return "\(String(format: "%.1f", lat)),\(String(format: "%.1f", lon))"
        })
        if uniqueLocations.count >= 3 {
            unlockAchievement(.traveler, context: context)
        }
        
        // 8. Early Bird (Before 8 AM)
        if moments.contains(where: {
            let hour = Calendar.current.component(.hour, from: $0.timestamp)
            return hour < 8
        }) {
            unlockAchievement(.earlyBird, context: context)
        }
        
        // 9. Night Owl (After 11 PM)
        if moments.contains(where: {
            let hour = Calendar.current.component(.hour, from: $0.timestamp)
            return hour >= 23
        }) {
            unlockAchievement(.nightOwl, context: context)
        }
        
        // 10. Storyteller (5 detailed stories)
        let longStories = moments.filter { ($0.text?.count ?? 0) > 100 }
        if longStories.count >= 5 {
            unlockAchievement(.storyteller, context: context)
        }
        
        // 11. Visual Diarist (10 photos)
        let withPhotos = moments.filter { $0.mediaURL != nil } // Simplified check
        if withPhotos.count >= 10 {
            unlockAchievement(.photographer, context: context)
        }
        
        // 12. Persistent (5 active second chances)
        let activeSecondChances = moments.filter { $0.secondChanceActive }
        if activeSecondChances.count >= 5 {
            unlockAchievement(.persistent, context: context)
        }
        
        // 13. Balanced Life (5 categories)
        let uniqueCategories = Set(moments.map { $0.categoryEnum })
        if uniqueCategories.count >= 5 {
            unlockAchievement(.balancedLife, context: context)
        }
        
        // 14. Quick Win (Victory < 24h)
        // Logic: Check if victory timestamp is close to creation timestamp?
        // Since we don't store separate creation vs victory timestamps in the model shown,
        // we'll approximate or skip. If we assume 'timestamp' is creation and we checked victory now...
        // Let's assume if a victory exists with a timestamp = now (or close), it's a quick win.
        // Better logic: we need a separate "completedAt" field to be accurate.
        // For now, simple placeholder check or skip.
        // unlockAchievement(.quickWin, context: context)
        
        // 15. Social Butterfly (3 'Other Person' obstacles)
        let socialObstacles = moments.filter { $0.obstacleEnum == .otherPerson }
        if socialObstacles.count >= 3 {
            unlockAchievement(.socialButterfly, context: context)
        }
    }
    
    private func unlockAchievement(_ type: AchievementType, context: ModelContext) {
        // Check if already unlocked - fetch all and filter
        let descriptor = FetchDescriptor<Achievement>()
        guard let allAchievements = try? context.fetch(descriptor) else { return }
        
        if allAchievements.contains(where: { $0.type == type.rawValue }) {
            return // Already unlocked
        }
        
        // Unlock
        let achievement = Achievement(
            type: type.rawValue,
            title: type.title,
            achievementDescription: type.description,
            iconName: type.iconName
        )
        
        context.insert(achievement)
        
        do {
            try context.save()
            print("Achievement Unlocked: \(type.title)")
        } catch {
            print("Failed to save achievement: \(error)")
        }
    }
}
