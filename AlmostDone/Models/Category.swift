//
//  Category.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI

enum Category: String, CaseIterable, Codable {
    case love = "love"
    case career = "career"
    case sport = "sport"
    case travel = "travel"
    case creativity = "creativity"
    case extreme = "extreme"
    case health = "health"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .love: return "Love"
        case .career: return "Career"
        case .sport: return "Sport"
        case .travel: return "Travel"
        case .creativity: return "Creativity"
        case .extreme: return "Extreme"
        case .health: return "Health"
        case .other: return "Other"
        }
    }
    
    var iconName: String {
        switch self {
        case .love: return "heart.fill"
        case .career: return "briefcase.fill"
        case .sport: return "figure.run"
        case .travel: return "airplane"
        case .creativity: return "paintbrush.fill"
        case .extreme: return "flame.fill"
        case .health: return "cross.case.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .love: return .pink
        case .career: return .blue
        case .sport: return .green
        case .travel: return .cyan
        case .creativity: return .purple
        case .extreme: return .red
        case .health: return .mint
        case .other: return .gray
        }
    }
}
