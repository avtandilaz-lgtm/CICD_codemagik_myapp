import Foundation
import SwiftData
import SwiftUI

@Model
final class SeasonModel {
    @Attribute(.unique) var id: String
    var name: String
    var emoji: String
    var order: Int
    
    init(id: String, name: String, emoji: String, order: Int) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.order = order
    }
    
    static func getDefaultSeasons() -> [(id: String, name: String, emoji: String, order: Int)] {
        return [
            (id: "winter", name: "Winter", emoji: "❄️", order: 0),
            (id: "spring", name: "Spring", emoji: "🌸", order: 1),
            (id: "summer", name: "Summer", emoji: "☀️", order: 2),
            (id: "autumn", name: "Autumn", emoji: "🍂", order: 3)
        ]
    }
    
    static func getCurrentSeasonId() -> String {
        let month = Calendar.current.component(.month, from: Date())
        switch month {
        case 12, 1, 2: return "winter"
        case 3, 4, 5: return "spring"
        case 6, 7, 8: return "summer"
        case 9, 10, 11: return "autumn"
        default: return "winter"
        }
    }
    
    func getTips() -> [String] {
        switch id {
        case "winter":
            return [
                "Check antifreeze level before frost",
                "Replace windshield wiper blades",
                "Check battery and charge if necessary",
                "Make sure window heating works",
                "Check tire pressure (it drops in cold weather)",
                "Treat body with anti-corrosion compound",
                "Check headlights and taillights"
            ]
        case "spring":
            return [
                "Switch to summer tires at temperatures above +7°C",
                "Check air conditioning before heat",
                "Do a full body wash after winter",
                "Check suspension after winter roads",
                "Replace cabin filter",
                "Check brake system operation",
                "Update windshield washer fluid"
            ]
        case "summer":
            return [
                "Regularly check tire pressure",
                "Monitor coolant level",
                "Check air conditioning operation",
                "Protect body from UV rays",
                "Check brake system",
                "Monitor engine temperature",
                "Regularly wash car from dust"
            ]
        case "autumn":
            return [
                "Prepare your car for winter in advance",
                "Switch to winter tires",
                "Check battery",
                "Replace windshield wiper blades",
                "Check heating operation",
                "Check headlights and lighting",
                "Treat body with anti-corrosion compound"
            ]
        default:
            return []
        }
    }
    
}

