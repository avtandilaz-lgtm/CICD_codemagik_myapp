//
//  DataManager.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import Foundation
import SwiftData

@MainActor
class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    // Initialize default settings if none exist
    func initializeDefaultSettings(context: ModelContext) {
        let descriptor = FetchDescriptor<AppSettings>()
        if let existingSettings = try? context.fetch(descriptor).first {
            // Settings already exist
            return
        }
        
        let defaultSettings = AppSettings()
        context.insert(defaultSettings)
        
        do {
            try context.save()
        } catch {
            print("Failed to save default settings: \(error)")
        }
    }
    
    // Delete all data
    func deleteAllData(context: ModelContext) {
        // Delete all moments
        do {
            try context.delete(model: AlmostMoment.self)
            try context.delete(model: Achievement.self)
            
            // Reset settings (or delete and recreate)
            // We'll delete existing and re-initialize
            try context.delete(model: AppSettings.self)
            initializeDefaultSettings(context: context)
            
            try context.save()
        } catch {
            print("Failed to delete all data: \(error)")
        }
    }
}

