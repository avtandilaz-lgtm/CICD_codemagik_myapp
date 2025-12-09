import Foundation
import SwiftData
import SwiftUI

@Model
final class UserSettingsModel {
    @Attribute(.unique) var id: String = "main"
    var theme: String
    var hasCompletedOnboarding: Bool
    
    init(
        theme: String = "system",
        hasCompletedOnboarding: Bool = false
    ) {
        self.theme = theme
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}

enum Currency: String, CaseIterable {
    case rub = "RUB"
    case usd = "USD"
    case eur = "EUR"
    case kzt = "KZT"
    
    var symbol: String {
        switch self {
        case .rub: return "₽"
        case .usd: return "$"
        case .eur: return "€"
        case .kzt: return "₸"
        }
    }
    
    var code: String { rawValue }
}

enum Region: String, CaseIterable {
    case moscow = "moscow"
    case spb = "spb"
    case regions = "regions"
    case kazakhstan = "kazakhstan"
    
    var displayName: String {
        switch self {
        case .moscow: return "Moscow"
        case .spb: return "St. Petersburg"
        case .regions: return "Regions"
        case .kazakhstan: return "Kazakhstan"
        }
    }
}

enum AppTheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

enum AppLanguage: String, CaseIterable {
    case russian = "ru"
    case english = "en"
    case kazakh = "kz"
    
    var displayName: String {
        switch self {
        case .russian: return "Russian"
        case .english: return "English"
        case .kazakh: return "Kazakh"
        }
    }
    
    var locale: Locale {
        Locale(identifier: rawValue)
    }
}

