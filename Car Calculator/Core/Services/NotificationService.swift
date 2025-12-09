import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleSeasonalReminders() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let calendar = Calendar.current
        let now = Date()
        
        // Schedule reminders 2 weeks before each season
        let seasons: [(id: String, name: String, month: Int, day: Int)] = [
            ("winter", "Winter", 11, 15), // November 15
            ("spring", "Spring", 2, 15),  // February 15
            ("summer", "Summer", 5, 15),   // May 15
            ("autumn", "Autumn", 8, 15)   // August 15
        ]
        
        for season in seasons {
            var components = DateComponents()
            components.month = season.month
            components.day = season.day
            
            if let seasonDate = calendar.date(from: components) {
                // Schedule 2 weeks before
                if let reminderDate = calendar.date(byAdding: .day, value: -14, to: seasonDate),
                   reminderDate > now {
                    scheduleReminder(
                        id: "season_\(season.id)",
                        title: "\(season.name) Maintenance Coming Soon",
                        body: "Prepare your car for \(season.name.lowercased()). Plan your maintenance budget now!",
                        date: reminderDate
                    )
                }
            }
        }
    }
    
    func scheduleMaintenanceReminder(for calculation: CalculationModel, daysBefore: Int = 7) {
        let calendar = Calendar.current
        if let reminderDate = calendar.date(byAdding: .day, value: -daysBefore, to: calculation.date),
           reminderDate > Date() {
            scheduleReminder(
                id: "maintenance_\(calculation.id.uuidString)",
                title: "Upcoming Maintenance",
                body: "Your scheduled maintenance is in \(daysBefore) days. Total: $\(calculation.totalAmount)",
                date: reminderDate
            )
        }
    }
    
    private func scheduleReminder(id: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelReminder(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

