//
//  NotificationService.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import Foundation
import UserNotifications
import SwiftData

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()
    
    private let motivationalMessages = [
        "Don't let this slip away again.",
        "You're closer than you think.",
        "Make today count.",
        "Remember why you started.",
        "Turn that 'almost' into a 'done'.",
        "Small steps lead to big victories.",
        "You have a second chance. Use it.",
        "Believe in your second chance.",
        "It's not over until you win.",
        "Keep pushing forward.",
        "Your victory is waiting.",
        "Don't give up now.",
        "Every day is a new opportunity.",
        "Focus on the goal.",
        "You can do this.",
        "Stay committed.",
        "Make yourself proud.",
        "One step at a time.",
        "Success is within reach.",
        "Seize the day.",
        "Rewrite your story.",
        "This is your moment.",
        "Keep your eyes on the prize.",
        "Determination is key.",
        "Finish what you started.",
        "Prove it to yourself.",
        "Victory tastes sweet.",
        "Go get it!",
        "Make it happen.",
        "You are capable."
    ]
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }
    
    // Handle foreground notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    @MainActor
    func scheduleSecondChanceReminders(for moment: AlmostMoment, context: ModelContext) {
        // Check if notifications are enabled in settings
        let descriptor = FetchDescriptor<AppSettings>()
        if let settings = try? context.fetch(descriptor).first, !settings.notificationsEnabled {
            return
        }

        guard let deadline = moment.secondChanceDeadline else { return }
        
        // 1. Immediate Notification
        let immediateContent = UNMutableNotificationContent()
        immediateContent.title = "Second Chance Activated!"
        immediateContent.body = "You've started a second chance for '\(moment.categoryEnum.displayName)'. Let's do this!"
        immediateContent.sound = .default
        
        let immediateRequest = UNNotificationRequest(
            identifier: "secondChance-immediate-\(moment.id.uuidString)-\(Date().timeIntervalSince1970)",
            content: immediateContent,
            trigger: nil // Deliver immediately
        )
        UNUserNotificationCenter.current().add(immediateRequest)
        
        // 2. Schedule daily reminders
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        dateComponents.hour = 9
        dateComponents.minute = 0
        
        // Start from tomorrow
        var currentDate = calendar.date(from: dateComponents) ?? Date()
        if currentDate < Date() {
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? Date()
        }
        
        let endDate = deadline
        var dayIndex = 0
        
        while currentDate <= endDate {
            let daysLeft = calendar.dateComponents([.day], from: currentDate, to: endDate).day ?? 0
            
            let content = UNMutableNotificationContent()
            content.title = "Second Chance Reminder"
            content.sound = .default
            
            // Determine message based on days left
            if daysLeft == 0 {
                // Last day (handled separately usually, but good to have here too if logic overlaps)
                content.title = "Last Chance!"
                content.body = "Today is your last chance to turn this into a victory! Make it happen."
            } else if daysLeft == 1 {
                content.title = "1 Day Left"
                content.body = "Tomorrow is the deadline. One final push!"
            } else if daysLeft == 2 {
                content.title = "2 Days Left"
                content.body = "Only two days remaining. Stay focused!"
            } else if daysLeft == 3 {
                content.title = "3 Days Left"
                content.body = "Three days to go. Don't let up now!"
            } else {
                // Random/Cycled message
                let messageIndex = dayIndex % motivationalMessages.count
                content.body = motivationalMessages[messageIndex]
            }
            
            let triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "secondChance-\(moment.id.uuidString)-\(currentDate.timeIntervalSince1970)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request)
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? endDate
            dayIndex += 1
        }
    }
    
    func cancelSecondChanceReminders(for moment: AlmostMoment) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiers = requests.filter { $0.identifier.contains("secondChance-\(moment.id.uuidString)") }.map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
}
