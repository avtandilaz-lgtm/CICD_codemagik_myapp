//
//  Obstacle.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import Foundation

enum Obstacle: String, CaseIterable, Codable {
    case fear = "fear"
    case laziness = "laziness"
    case shame = "shame"
    case otherPerson = "otherPerson"
    case money = "money"
    case time = "time"
    case chance = "chance"
    case health = "health"
    case lackOfKnowledge = "lackOfKnowledge"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .fear: return "Fear"
        case .laziness: return "Laziness"
        case .shame: return "Shame"
        case .otherPerson: return "Another Person"
        case .money: return "Money"
        case .time: return "Time"
        case .chance: return "Chance"
        case .health: return "Health"
        case .lackOfKnowledge: return "Lack of Knowledge"
        case .other: return "Other"
        }
    }
    
    var iconName: String {
        switch self {
        case .fear: return "eye.trianglebadge.exclamationmark"
        case .laziness: return "bed.double.fill"
        case .shame: return "eye.slash.fill"
        case .otherPerson: return "person.2.fill"
        case .money: return "dollarsign.circle.fill"
        case .time: return "clock.fill"
        case .chance: return "dice.fill"
        case .health: return "cross.case.fill"
        case .lackOfKnowledge: return "book.fill"
        case .other: return "questionmark.circle.fill"
        }
    }
}

