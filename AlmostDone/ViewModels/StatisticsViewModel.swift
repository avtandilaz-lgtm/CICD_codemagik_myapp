//
//  StatisticsViewModel.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import Foundation
import SwiftData
import SwiftUI
import CoreLocation
import Combine

@MainActor
class StatisticsViewModel: ObservableObject {
    @Published var averageClosenessByMonth: [(period: String, average: Double)] = []
    @Published var obstacleDistribution: [(obstacle: Obstacle, count: Int)] = []
    @Published var topCategories: [(category: Category, average: Double)] = []
    @Published var topPainfulMoments: [AlmostMoment] = []
    @Published var locations: [CLLocationCoordinate2D] = []
    @Published var achievements: [Achievement] = []
    
    private var modelContext: ModelContext?
    
    func setup(context: ModelContext) {
        self.modelContext = context
        loadStatistics()
    }
    
    func loadStatistics() {
        guard let context = modelContext else { return }
        
        averageClosenessByMonth = StatisticsCalculator.shared.getAverageClosenessByPeriod(
            context: context,
            groupBy: .month
        )
        
        obstacleDistribution = StatisticsCalculator.shared.getObstacleDistribution(context: context)
        
        topCategories = StatisticsCalculator.shared.getTopCategoriesByAverage(context: context, limit: 3)
        
        topPainfulMoments = StatisticsCalculator.shared.getTopPainfulMoments(context: context, limit: 3)
        
        locations = StatisticsCalculator.shared.getAllLocations(context: context)
        
        loadAchievements(context: context)
    }
    
    private func loadAchievements(context: ModelContext) {
        let descriptor = FetchDescriptor<Achievement>(
            sortBy: [SortDescriptor(\.unlockedAt, order: .reverse)]
        )
        achievements = (try? context.fetch(descriptor)) ?? []
    }
    
    func refresh() {
        loadStatistics()
    }
}

