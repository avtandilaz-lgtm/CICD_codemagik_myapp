//
//  SettingsViewModel.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings?
    @Published var theme: String = "auto"
    @Published var secondChanceFrequency: Int = 6
    @Published var notificationsEnabled: Bool = true
    @Published var widgetSize: String = "medium"
    
    private var modelContext: ModelContext?
    
    func setup(context: ModelContext) {
        self.modelContext = context
        loadSettings()
    }
    
    func loadSettings() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<AppSettings>()
        if let existingSettings = try? context.fetch(descriptor).first {
            settings = existingSettings
            theme = existingSettings.theme
            secondChanceFrequency = existingSettings.secondChanceFrequency
            notificationsEnabled = existingSettings.notificationsEnabled
            widgetSize = existingSettings.widgetSize
        } else {
            // Create default settings
            let defaultSettings = AppSettings()
            context.insert(defaultSettings)
            settings = defaultSettings
            save()
        }
    }
    
    func updateTheme(_ newTheme: String) {
        theme = newTheme
        settings?.theme = newTheme
        // Update AppStorage for immediate UI update
        UserDefaults.standard.set(newTheme, forKey: "appTheme")
        save()
    }
    
    func updateSecondChanceFrequency(_ frequency: Int) {
        secondChanceFrequency = frequency
        settings?.secondChanceFrequency = frequency
        save()
    }
    
    func updateNotificationsEnabled(_ enabled: Bool) {
        notificationsEnabled = enabled
        settings?.notificationsEnabled = enabled
        save()
    }
    
    func updateWidgetSize(_ size: String) {
        widgetSize = size
        settings?.widgetSize = size
        save()
    }
    
    func save() {
        guard let context = modelContext else { return }
        do {
            try context.save()
        } catch {
            print("Failed to save settings: \(error)")
        }
    }
    
    func exportJSON() throws -> URL {
        guard let context = modelContext else {
            throw NSError(domain: "SettingsViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "No context available"])
        }
        let data = try ExportManager.shared.exportToJSON(context: context)
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("almost_done_export.json")
        try data.write(to: fileURL)
        return fileURL
    }
    
    func exportPDF() throws -> URL {
        guard let context = modelContext else {
            throw NSError(domain: "SettingsViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "No context available"])
        }
        let data = try ExportManager.shared.exportToPDF(context: context)
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("my_book_of_almost.pdf")
        try data.write(to: fileURL)
        return fileURL
    }
    
    func deleteAllData() {
        guard let context = modelContext else { return }
        DataManager.shared.deleteAllData(context: context)
        loadSettings() // Reload settings after reset
    }
}

