//
//  StatisticsCalculator.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import Foundation
import SwiftData
import CoreLocation

@MainActor
class StatisticsCalculator {
    static let shared = StatisticsCalculator()
    
    private init() {}
    
    // Get all moments
    func getAllMoments(context: ModelContext) -> [AlmostMoment] {
        let descriptor = FetchDescriptor<AlmostMoment>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    // Get total count of almost moments
    func getTotalAlmostCount(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<AlmostMoment>()
        return (try? context.fetch(descriptor).count) ?? 0
    }
    
    // Get total count of victories
    func getTotalVictoriesCount(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<AlmostMoment>(
            predicate: #Predicate { $0.isVictory == true }
        )
        return (try? context.fetch(descriptor).count) ?? 0
    }
    
    // Calculate average closeness by month/year
    func getAverageClosenessByPeriod(context: ModelContext, groupBy: Calendar.Component) -> [(period: String, average: Double)] {
        let moments = getAllMoments(context: context)
        let calendar = Calendar.current
        
        var grouped: [String: [Int]] = [:]
        
        for moment in moments {
            let components = calendar.dateComponents([groupBy, .year], from: moment.timestamp)
            let key: String
            
            if groupBy == .month {
                key = "\(components.year ?? 0)-\(String(format: "%02d", components.month ?? 0))"
            } else {
                key = "\(components.year ?? 0)"
            }
            
            if grouped[key] == nil {
                grouped[key] = []
            }
            grouped[key]?.append(moment.closenessPercentage)
        }
        
        return grouped.map { key, values in
            let average = Double(values.reduce(0, +)) / Double(values.count)
            return (period: key, average: average)
        }.sorted { $0.period < $1.period }
    }
    
    // Get obstacle distribution
    func getObstacleDistribution(context: ModelContext) -> [(obstacle: Obstacle, count: Int)] {
        let moments = getAllMoments(context: context)
        var distribution: [Obstacle: Int] = [:]
        
        for moment in moments {
            let obstacle = moment.obstacleEnum
            distribution[obstacle, default: 0] += 1
        }
        
        return distribution.map { (obstacle: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    // Get top 3 categories by average closeness
    func getTopCategoriesByAverage(context: ModelContext, limit: Int = 3) -> [(category: Category, average: Double)] {
        let moments = getAllMoments(context: context)
        var categoryData: [Category: [Int]] = [:]
        
        for moment in moments {
            let category = moment.categoryEnum
            if categoryData[category] == nil {
                categoryData[category] = []
            }
            categoryData[category]?.append(moment.closenessPercentage)
        }
        
        return categoryData.map { category, values in
            let average = Double(values.reduce(0, +)) / Double(values.count)
            return (category: category, average: average)
        }
        .sorted { $0.average > $1.average }
        .prefix(limit)
        .map { ($0.category, $0.average) }
    }
    
    // Get top 3 most painful "almost" (highest closeness %)
    func getTopPainfulMoments(context: ModelContext, limit: Int = 3) -> [AlmostMoment] {
        let descriptor = FetchDescriptor<AlmostMoment>(
            predicate: #Predicate { $0.isVictory == false },
            sortBy: [SortDescriptor(\.closenessPercentage, order: .reverse)]
        )
        
        let moments = (try? context.fetch(descriptor)) ?? []
        return Array(moments.prefix(limit))
    }
    
    // Get all locations
    func getAllLocations(context: ModelContext) -> [CLLocationCoordinate2D] {
        let moments = getAllMoments(context: context)
        return moments.compactMap { $0.location }
    }
}
