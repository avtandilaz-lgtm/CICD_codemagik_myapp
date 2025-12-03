//
//  Achievement.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import Foundation
import SwiftData

@Model
final class Achievement {
    var id: UUID
    var type: String // Achievement type identifier
    var unlockedAt: Date
    var title: String
    var achievementDescription: String
    var iconName: String
    
    init(
        id: UUID = UUID(),
        type: String,
        unlockedAt: Date = Date(),
        title: String,
        achievementDescription: String,
        iconName: String
    ) {
        self.id = id
        self.type = type
        self.unlockedAt = unlockedAt
        self.title = title
        self.achievementDescription = achievementDescription
        self.iconName = iconName
    }
}

// Achievement types enum
enum AchievementType: String, CaseIterable {
    case firstAlmost = "first_almost"
    case hundredAlmost = "hundred_almost"
    case tenVictories = "ten_victories"
    case yearWithoutLoveSetbacks = "year_without_love_setbacks"
    case perfectCloseness = "perfect_closeness"
    case comebackKing = "comeback_king"
    
    // New Achievements
    case traveler = "traveler"
    case earlyBird = "early_bird"
    case nightOwl = "night_owl"
    case storyteller = "storyteller"
    case photographer = "photographer"
    case persistent = "persistent"
    case balancedLife = "balanced_life"
    case quickWin = "quick_win"
    case socialButterfly = "social_butterfly"
    
    var title: String {
        switch self {
        case .firstAlmost: return "First Step"
        case .hundredAlmost: return "Century"
        case .tenVictories: return "Champion"
        case .yearWithoutLoveSetbacks: return "Love Warrior"
        case .perfectCloseness: return "So Close"
        case .comebackKing: return "Comeback King"
        case .traveler: return "World Traveler"
        case .earlyBird: return "Early Bird"
        case .nightOwl: return "Night Owl"
        case .storyteller: return "Storyteller"
        case .photographer: return "Visual Diarist"
        case .persistent: return "Never Give Up"
        case .balancedLife: return "Balanced Life"
        case .quickWin: return "Quick Win"
        case .socialButterfly: return "Social Butterfly"
        }
    }
    
    var description: String {
        switch self {
        case .firstAlmost: return "Recorded your first almost moment"
        case .hundredAlmost: return "Reached 100 almost moments"
        case .tenVictories: return "Achieved 10 victories"
        case .yearWithoutLoveSetbacks: return "One year without love setbacks"
        case .perfectCloseness: return "Had an almost moment at 100% closeness"
        case .comebackKing: return "Converted 5 second chances into victories"
        case .traveler: return "Recorded moments in 3 different locations"
        case .earlyBird: return "Added a moment before 8 AM"
        case .nightOwl: return "Added a moment after 11 PM"
        case .storyteller: return "Wrote 5 detailed stories (>100 chars)"
        case .photographer: return "Added photos to 10 moments"
        case .persistent: return "5 active second chances at once"
        case .balancedLife: return "Recorded moments in 5 different categories"
        case .quickWin: return "Turned a moment into victory within 24 hours"
        case .socialButterfly: return "3 moments stopped by 'Another Person'"
        }
    }
    
    var iconName: String {
        switch self {
        case .firstAlmost: return "star.fill"
        case .hundredAlmost: return "100.circle.fill"
        case .tenVictories: return "trophy.fill"
        case .yearWithoutLoveSetbacks: return "heart.circle.fill"
        case .perfectCloseness: return "target"
        case .comebackKing: return "arrow.triangle.2.circlepath.circle.fill"
        case .traveler: return "airplane.circle.fill"
        case .earlyBird: return "sun.max.fill"
        case .nightOwl: return "moon.stars.fill"
        case .storyteller: return "book.closed.fill"
        case .photographer: return "camera.fill"
        case .persistent: return "hourglass"
        case .balancedLife: return "chart.pie.fill"
        case .quickWin: return "bolt.fill"
        case .socialButterfly: return "person.2.fill"
        }
    }
}
