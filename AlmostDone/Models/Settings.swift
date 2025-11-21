//
//  Settings.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import Foundation
import SwiftData

@Model
final class AppSettings {
    var id: UUID
    var theme: String // "light", "dark", "auto"
    var secondChanceFrequency: Int // 3, 6, or 12 months
    var notificationsEnabled: Bool
    var widgetSize: String // "small", "medium", "large"
    var lastAutomaticSecondChanceDate: Date?
    
    init(
        id: UUID = UUID(),
        theme: String = "auto",
        secondChanceFrequency: Int = 6,
        notificationsEnabled: Bool = true,
        widgetSize: String = "medium",
        lastAutomaticSecondChanceDate: Date? = nil
    ) {
        self.id = id
        self.theme = theme
        self.secondChanceFrequency = secondChanceFrequency
        self.notificationsEnabled = notificationsEnabled
        self.widgetSize = widgetSize
        self.lastAutomaticSecondChanceDate = lastAutomaticSecondChanceDate
    }
}

