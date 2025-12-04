//
//  DetailViewModel.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
class DetailViewModel: ObservableObject {
    @Published var moment: AlmostMoment
    @Published var victoryFeeling: String = ""
    @Published var isEditing: Bool = false
    
    // Editing fields
    @Published var editingCategory: Category = .other
    @Published var editingCloseness: Double = 50
    @Published var editingObstacle: Obstacle = .other
    @Published var editingText: String = ""
    @Published var editingDate: Date = Date()
    
    @Published var editingVictoryFeeling: String = ""
    
    private var modelContext: ModelContext?
    
    init(moment: AlmostMoment) {
        self.moment = moment
        self.victoryFeeling = moment.victoryFeeling ?? ""
        self.editingCategory = moment.categoryEnum
        self.editingCloseness = Double(moment.closenessPercentage)
        self.editingObstacle = moment.obstacleEnum
        self.editingText = moment.text ?? ""
        self.editingDate = moment.timestamp
        self.editingVictoryFeeling = moment.victoryFeeling ?? ""
    }
    
    func setup(context: ModelContext) {
        self.modelContext = context
    }
    
    func startEditing() {
        isEditing = true
    }
    
    func cancelEditing() {
        isEditing = false
        // Reset to original values
        editingCategory = moment.categoryEnum
        editingCloseness = Double(moment.closenessPercentage)
        editingObstacle = moment.obstacleEnum
        editingText = moment.text ?? ""
        editingDate = moment.timestamp
        editingVictoryFeeling = moment.victoryFeeling ?? ""
    }
    
    func saveVictoryFeeling() {
        guard let context = modelContext else { return }
        moment.victoryFeeling = victoryFeeling.isEmpty ? nil : victoryFeeling
        save()
    }
    
    func saveEditing() {
        guard let context = modelContext else { return }
        
        moment.categoryEnum = editingCategory
        moment.closenessPercentage = Int(editingCloseness)
        moment.obstacleEnum = editingObstacle
        moment.text = editingText.isEmpty ? nil : editingText
        moment.timestamp = editingDate
        
        // Check if victory status should change
        if moment.closenessPercentage == 100 {
            moment.isVictory = true
            moment.victoryFeeling = editingVictoryFeeling.isEmpty ? nil : editingVictoryFeeling
            if moment.secondChanceActive {
                SecondChanceManager.shared.deactivateSecondChance(moment: moment, context: context)
            }
        } else {
            // If closeness is less than 100, revert victory status
            moment.isVictory = false
        }
        
        save()
        AchievementManager.shared.checkAchievements(context: context)
        isEditing = false
        
        // Update non-editing state
        victoryFeeling = moment.victoryFeeling ?? ""
    }
    
    func convertToVictory() {
        guard let context = modelContext else { return }
        
        moment.isVictory = true
        moment.closenessPercentage = 100
        moment.victoryFeeling = victoryFeeling.isEmpty ? nil : victoryFeeling
        
        // Deactivate second chance if active
        if moment.secondChanceActive {
            SecondChanceManager.shared.deactivateSecondChance(moment: moment, context: context)
        }
        
        save()
        AchievementManager.shared.checkAchievements(context: context)
    }
    
    func activateSecondChance() {
        guard let context = modelContext else { return }
        SecondChanceManager.shared.activateSecondChance(moment: moment, context: context)
        save()
    }
    
    func delete() {
        guard let context = modelContext else { return }
        context.delete(moment)
        save()
    }
    
    func save() {
        guard let context = modelContext else { return }
        do {
            try context.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }
}

