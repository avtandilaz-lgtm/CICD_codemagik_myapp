import Foundation
import SwiftUI

// Renamed to avoid conflict with AppLanguage from UserSettingsModel
enum LocalizationLanguage: String, CaseIterable, Codable {
    case russian = "ru"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .russian: return "Russian"
        case .english: return "English"
        }
    }
    
    var locale: Locale {
        Locale(identifier: rawValue)
    }
}

@Observable
class LocalizationManager {
    var currentLanguage: LocalizationLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
        }
    }
    
    init() {
        if let saved = UserDefaults.standard.string(forKey: "appLanguage"),
           let language = LocalizationLanguage(rawValue: saved) {
            self.currentLanguage = language
        } else {
            self.currentLanguage = .russian
        }
    }
    
    func localized(_ key: String) -> String {
        switch currentLanguage {
        case .russian:
            return russianStrings[key] ?? key
        case .english:
            return englishStrings[key] ?? key
        }
    }
    
    private let russianStrings: [String: String] = [
        "welcome": "Hello",
        "ready_to_calculate": "Ready to calculate costs?",
        "current_season": "Current season",
        "select_season": "Select season",
        "history": "History",
        "tips": "Tips",
        "settings": "Settings",
        "calculator": "Calculator",
        "close": "Close",
        "save": "Save",
        "share": "Share",
        "total": "Total",
        "winter": "Winter",
        "spring": "Spring",
        "summer": "Summer",
        "autumn": "Autumn",
        "winter_service": "Winter service",
        "spring_service": "Spring service",
        "summer_service": "Summer service",
        "autumn_service": "Autumn service",
        "saved": "Calculation saved!",
        "theme": "Theme",
        "language": "Language",
        "light": "Light",
        "dark": "Dark",
        "system": "System",
        "empty_history": "History is empty",
        "save_first": "Save your first calculation",
        "delete": "Delete",
        "delete_all": "Delete all",
        "calculation_details": "Calculation details",
        "done": "Done",
        "services_count": "services",
        "tips_for": "Tips for",
        "season": "season"
    ]
    
    private let englishStrings: [String: String] = [
        "welcome": "Hello",
        "ready_to_calculate": "Ready to calculate costs?",
        "current_season": "Current season",
        "select_season": "Select season",
        "history": "History",
        "tips": "Tips",
        "settings": "Settings",
        "calculator": "Calculator",
        "close": "Close",
        "save": "Save",
        "share": "Share",
        "total": "Total",
        "winter": "Winter",
        "spring": "Spring",
        "summer": "Summer",
        "autumn": "Autumn",
        "winter_service": "Winter service",
        "spring_service": "Spring service",
        "summer_service": "Summer service",
        "autumn_service": "Autumn service",
        "saved": "Calculation saved!",
        "theme": "Theme",
        "language": "Language",
        "light": "Light",
        "dark": "Dark",
        "system": "System",
        "empty_history": "History is empty",
        "save_first": "Save your first calculation",
        "delete": "Delete",
        "delete_all": "Delete all",
        "calculation_details": "Calculation details",
        "done": "Done",
        "services_count": "services",
        "tips_for": "Tips for",
        "season": "season"
    ]
}

extension String {
    func localized(_ manager: LocalizationManager) -> String {
        manager.localized(self)
    }
}

