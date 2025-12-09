import Foundation
import SwiftData

protocol CalculationRepositoryProtocol {
    func getAllCalculations() -> [CalculationModel]
    func getCalculations(by seasonId: String) -> [CalculationModel]
    func getCalculations(from startDate: Date, to endDate: Date) -> [CalculationModel]
    func saveCalculation(_ calculation: CalculationModel) throws
    func deleteCalculation(_ calculation: CalculationModel) throws
    func deleteAllCalculations() throws
    func getStatistics() -> CalculationStatistics
}

struct CalculationStatistics {
    let totalCalculations: Int
    let totalSpent: Int
    let averageAmount: Int
    let mostExpensiveSeason: String?
    let calculationsByMonth: [String: Int]
    let calculationsByYear: [Int: Int]
}

final class CalculationRepository: CalculationRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getAllCalculations() -> [CalculationModel] {
        let descriptor = FetchDescriptor<CalculationModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            // Log error but return empty array so app continues to work
            return []
        }
    }
    
    func getCalculations(by seasonId: String) -> [CalculationModel] {
        let descriptor = FetchDescriptor<CalculationModel>(
            predicate: #Predicate { $0.seasonId == seasonId },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }
    
    func getCalculations(from startDate: Date, to endDate: Date) -> [CalculationModel] {
        let descriptor = FetchDescriptor<CalculationModel>(
            predicate: #Predicate { calculation in
                calculation.date >= startDate && calculation.date <= endDate
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }
    
    func saveCalculation(_ calculation: CalculationModel) throws {
        modelContext.insert(calculation)
        do {
            try modelContext.save()
        } catch {
            throw AppError.dataSaveFailed("Failed to save calculation: \(error.localizedDescription)")
        }
    }
    
    func deleteCalculation(_ calculation: CalculationModel) throws {
        modelContext.delete(calculation)
        do {
            try modelContext.save()
        } catch {
            throw AppError.dataSaveFailed("Failed to delete calculation: \(error.localizedDescription)")
        }
    }
    
    func deleteAllCalculations() throws {
        let calculations = getAllCalculations()
        calculations.forEach { modelContext.delete($0) }
        do {
            try modelContext.save()
        } catch {
            throw AppError.dataSaveFailed("Failed to delete all calculations: \(error.localizedDescription)")
        }
    }
    
    func getStatistics() -> CalculationStatistics {
        let all = getAllCalculations()
        let total = all.count
        let totalSpent = all.reduce(0) { $0 + $1.totalAmount }
        let average = total > 0 ? totalSpent / total : 0
        
        let seasonTotals = Dictionary(grouping: all, by: { $0.seasonId })
            .mapValues { $0.reduce(0) { $0 + $1.totalAmount } }
        let mostExpensiveSeason = seasonTotals.max(by: { $0.value < $1.value })?.key
        
        let calendar = Calendar.current
        let byMonth = Dictionary(grouping: all) { calculation in
            let components = calendar.dateComponents([.year, .month], from: calculation.date)
            return "\(components.year ?? 0)-\(components.month ?? 0)"
        }
        let calculationsByMonth = byMonth.mapValues { $0.count }
        
        let byYear = Dictionary(grouping: all) { calculation in
            calendar.component(.year, from: calculation.date)
        }
        let calculationsByYear = byYear.mapValues { $0.count }
        
        return CalculationStatistics(
            totalCalculations: total,
            totalSpent: totalSpent,
            averageAmount: average,
            mostExpensiveSeason: mostExpensiveSeason,
            calculationsByMonth: calculationsByMonth,
            calculationsByYear: calculationsByYear
        )
    }
}

