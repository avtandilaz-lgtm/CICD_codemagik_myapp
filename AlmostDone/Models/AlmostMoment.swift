//
//  AlmostMoment.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class AlmostMoment {
    var id: UUID
    var category: String // Category rawValue
    var closenessPercentage: Int
    var obstacle: String // Obstacle rawValue
    var text: String?
    var mediaURL: String? // URL as string for SwiftData
    var latitude: Double?
    var longitude: Double?
    var timestamp: Date
    var isVictory: Bool
    var victoryFeeling: String?
    var secondChanceDeadline: Date?
    var secondChanceActive: Bool
    
    init(
        id: UUID = UUID(),
        category: Category,
        closenessPercentage: Int,
        obstacle: Obstacle,
        text: String? = nil,
        mediaURL: URL? = nil,
        location: CLLocationCoordinate2D? = nil,
        timestamp: Date = Date(),
        isVictory: Bool = false,
        victoryFeeling: String? = nil,
        secondChanceDeadline: Date? = nil,
        secondChanceActive: Bool = false
    ) {
        self.id = id
        self.category = category.rawValue
        self.closenessPercentage = closenessPercentage
        self.obstacle = obstacle.rawValue
        self.text = text
        self.mediaURL = mediaURL?.absoluteString
        self.latitude = location?.latitude
        self.longitude = location?.longitude
        self.timestamp = timestamp
        self.isVictory = isVictory
        self.victoryFeeling = victoryFeeling
        self.secondChanceDeadline = secondChanceDeadline
        self.secondChanceActive = secondChanceActive
    }
    
    // Computed properties for easier access
    var categoryEnum: Category {
        get { Category(rawValue: category) ?? .other }
        set { category = newValue.rawValue }
    }
    
    var obstacleEnum: Obstacle {
        get { Obstacle(rawValue: obstacle) ?? .other }
        set { obstacle = newValue.rawValue }
    }
    
    var mediaURLValue: URL? {
        get {
            guard let mediaURL = mediaURL else { return nil }
            return URL(string: mediaURL)
        }
        set {
            mediaURL = newValue?.absoluteString
        }
    }
    
    var location: CLLocationCoordinate2D? {
        get {
            guard let latitude = latitude, let longitude = longitude else { return nil }
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            latitude = newValue?.latitude
            longitude = newValue?.longitude
        }
    }
}

