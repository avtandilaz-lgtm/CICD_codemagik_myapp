//
//  SharedDataManager.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import Foundation
import WidgetKit

struct WidgetData: Codable {
    let activeSecondChanceTitle: String?
    let activeSecondChanceCategory: String?
    let daysRemaining: Int?
    let notificationText: String?
    let lastUpdated: Date
}

class SharedDataManager {
    static let shared = SharedDataManager()
    
    // App Group Identifier - must match the one in Signing & Capabilities
    private let appGroupIdentifier = "group.com.almostdone"
    
    private init() {}
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }
    
    func saveWidgetData(title: String?, category: String?, daysRemaining: Int?, notificationText: String?) {
        let data = WidgetData(
            activeSecondChanceTitle: title,
            activeSecondChanceCategory: category,
            daysRemaining: daysRemaining,
            notificationText: notificationText,
            lastUpdated: Date()
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults?.set(encoded, forKey: "widgetData")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func loadWidgetData() -> WidgetData? {
        guard let data = userDefaults?.data(forKey: "widgetData") else { return nil }
        return try? JSONDecoder().decode(WidgetData.self, from: data)
    }
    
    func clearWidgetData() {
        userDefaults?.removeObject(forKey: "widgetData")
        WidgetCenter.shared.reloadAllTimelines()
    }
}

