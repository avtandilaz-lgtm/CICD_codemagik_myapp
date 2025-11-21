//
//  SecondChanceManager.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import Foundation
import SwiftData

@MainActor
class SecondChanceManager {
    static let shared = SecondChanceManager()
    
    private init() {}
    
    // Get active second chance
    func getActiveSecondChance(context: ModelContext) -> AlmostMoment? {
        let descriptor = FetchDescriptor<AlmostMoment>(
            predicate: #Predicate { $0.secondChanceActive == true },
            sortBy: [SortDescriptor(\.secondChanceDeadline, order: .forward)]
        )
        
        return try? context.fetch(descriptor).first
    }
    
    // Automatically select a second chance based on frequency
    func selectAutomaticSecondChance(context: ModelContext, settings: AppSettings) {
        // Check if there's already an active second chance
        if getActiveSecondChance(context: context) != nil {
            return
        }
        
        // Check frequency
        if let lastDate = settings.lastAutomaticSecondChanceDate {
            let nextDate = Calendar.current.date(byAdding: .month, value: settings.secondChanceFrequency, to: lastDate) ?? Date()
            if Date() < nextDate {
                return // Too early
            }
        }
        
        // Select the closest "almost" that hasn't been converted to victory
        // and hasn't had a second chance recently
        let descriptor = FetchDescriptor<AlmostMoment>(
            predicate: #Predicate { moment in
                moment.isVictory == false &&
                moment.secondChanceActive == false
            },
            sortBy: [SortDescriptor(\.closenessPercentage, order: .reverse)]
        )
        
        guard let closestAlmost = try? context.fetch(descriptor).first else {
            return
        }
        
        // Activate second chance
        activateSecondChance(moment: closestAlmost, context: context)
        
        // Update settings
        settings.lastAutomaticSecondChanceDate = Date()
        try? context.save()
    }
    
    // Manually activate a second chance
    func activateSecondChance(moment: AlmostMoment, context: ModelContext) {
        moment.secondChanceActive = true
        moment.secondChanceDeadline = Calendar.current.date(byAdding: .day, value: Constants.secondChanceDurationDays, to: Date())
        
        do {
            try context.save()
            // Schedule notifications
            NotificationService.shared.scheduleSecondChanceReminders(for: moment, context: context)
            
            // Update Widget
            updateWidgetData(moment: moment)
        } catch {
            print("Failed to activate second chance: \(error)")
        }
    }
    
    // Deactivate second chance (when completed or expired)
    func deactivateSecondChance(moment: AlmostMoment, context: ModelContext) {
        moment.secondChanceActive = false
        moment.secondChanceDeadline = nil
        
        // Cancel notifications
        NotificationService.shared.cancelSecondChanceReminders(for: moment)
        
        // Update Widget
        updateWidgetData(moment: nil)
        
        do {
            try context.save()
        } catch {
            print("Failed to deactivate second chance: \(error)")
        }
    }
    
    private func updateWidgetData(moment: AlmostMoment?) {
        if let moment = moment, let days = daysRemaining(for: moment) {
            SharedDataManager.shared.saveWidgetData(
                title: "Second Chance Active",
                category: moment.categoryEnum.displayName,
                daysRemaining: days,
                notificationText: "You have a second chance to turn this into a victory!"
            )
        } else {
            SharedDataManager.shared.clearWidgetData()
        }
    }
    
    // Check for expired second chances
    func checkExpiredSecondChances(context: ModelContext) {
        let now = Date()
        let descriptor = FetchDescriptor<AlmostMoment>(
            predicate: #Predicate { moment in
                moment.secondChanceActive == true &&
                moment.secondChanceDeadline != nil &&
                moment.secondChanceDeadline! < now
            }
        )
        
        guard let expired = try? context.fetch(descriptor) else { return }
        
        for moment in expired {
            deactivateSecondChance(moment: moment, context: context)
        }
    }
    
    // Get days remaining for a second chance
    func daysRemaining(for moment: AlmostMoment) -> Int? {
        guard let deadline = moment.secondChanceDeadline else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: deadline)
        return components.day
    }
}

