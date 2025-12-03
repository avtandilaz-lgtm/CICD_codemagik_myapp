//
//  MainViewModel.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
class MainViewModel: ObservableObject {
    @Published var moments: [AlmostMoment] = []
    @Published var activeSecondChance: AlmostMoment?
    @Published var totalAlmostCount: Int = 0
    @Published var totalVictoriesCount: Int = 0
    
    private var modelContext: ModelContext?
    
    func setup(context: ModelContext) {
        self.modelContext = context
        loadData()
        checkSecondChances()
    }
    
    func loadData() {
        guard let context = modelContext else { return }
        
        // Changed sort order to .forward (Oldest -> Newest)
        let descriptor = FetchDescriptor<AlmostMoment>(
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        
        moments = (try? context.fetch(descriptor)) ?? []
        totalVictoriesCount = moments.filter { $0.isVictory }.count
        totalAlmostCount = moments.count - totalVictoriesCount // Subtract victories from total count
        
        // Get active second chance
        activeSecondChance = SecondChanceManager.shared.getActiveSecondChance(context: context)
    }
    
    func checkSecondChances() {
        guard let context = modelContext else { return }
        SecondChanceManager.shared.checkExpiredSecondChances(context: context)
        
        // Check for automatic second chance
        let descriptor = FetchDescriptor<AppSettings>()
        if let settings = try? context.fetch(descriptor).first {
            SecondChanceManager.shared.selectAutomaticSecondChance(context: context, settings: settings)
        }
        
        loadData()
    }
    
    func refresh() {
        loadData()
    }
}
