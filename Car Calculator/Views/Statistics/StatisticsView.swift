import SwiftUI
import SwiftData
#if canImport(Charts)
import Charts
#endif

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CalculationModel.date, order: .reverse) private var calculations: [CalculationModel]
    @Query private var seasons: [SeasonModel]
    
    @State private var selectedTimeRange: TimeRange = .year
    @State private var selectedChartType: ChartType = .expenses
    
    enum TimeRange: String, CaseIterable {
        case month = "Month"
        case quarter = "Quarter"
        case year = "Year"
        case all = "All Time"
    }
    
    enum ChartType: String, CaseIterable {
        case expenses = "Expenses"
        case count = "Count"
        case average = "Average"
    }
    
    private var filteredCalculations: [CalculationModel] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeRange {
        case .month:
            let start = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return calculations.filter { $0.date >= start }
        case .quarter:
            let start = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            return calculations.filter { $0.date >= start }
        case .year:
            let start = calendar.date(byAdding: .year, value: -1, to: now) ?? now
            return calculations.filter { $0.date >= start }
        case .all:
            return calculations
        }
    }
    
    private var statistics: CalculationStatistics {
        let repository = CalculationRepository(modelContext: modelContext)
        return repository.getStatistics()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Summary cards
                    summaryCards
                    
                    // Time range picker
                    timeRangePicker
                    
                    // Chart
                    chartSection
                    
                    // Season comparison
                    seasonComparison
                    
                    // Top services
                    topServicesSection
                    
                    // Trends
                    trendsSection
                }
                .padding(20)
            }
            .navigationTitle("Statistics")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private var summaryCards: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Total Spent",
                value: formatPrice(statistics.totalSpent),
                icon: "dollarsign.circle.fill",
                color: .blue
            )
            
            StatCard(
                title: "Calculations",
                value: "\(statistics.totalCalculations)",
                icon: "list.bullet.clipboard.fill",
                color: .green
            )
            
            StatCard(
                title: "Average",
                value: formatPrice(statistics.averageAmount),
                icon: "chart.bar.fill",
                color: .orange
            )
        }
    }
    
    private var timeRangePicker: some View {
        Picker("Time Range", selection: $selectedTimeRange) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Expense Trend")
                .font(.system(size: 20, weight: .semibold))
            
            Picker("Chart Type", selection: $selectedChartType) {
                ForEach(ChartType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            
            #if canImport(Charts)
            if #available(iOS 16.0, *) {
                Chart {
                    ForEach(chartData, id: \.period) { data in
                        BarMark(
                            x: .value("Period", data.period),
                            y: .value("Amount", data.amount)
                        )
                        .foregroundStyle(Color.blue.gradient)
                    }
                }
                .frame(height: 200)
                .padding()
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
            } else {
                chartFallback
            }
            #else
            chartFallback
            #endif
        }
    }
    
    private var chartData: [ChartDataPoint] {
        let calendar = Calendar.current
        let grouped: [String: [CalculationModel]]
        
        switch selectedTimeRange {
        case .month:
            grouped = Dictionary(grouping: filteredCalculations) { calc in
                let day = calendar.component(.day, from: calc.date)
                return "Day \(day)"
            }
        case .quarter, .year:
            grouped = Dictionary(grouping: filteredCalculations) { calc in
                let month = calendar.component(.month, from: calc.date)
                let monthName = calendar.monthSymbols[month - 1]
                return monthName
            }
        case .all:
            grouped = Dictionary(grouping: filteredCalculations) { calc in
                let year = calendar.component(.year, from: calc.date)
                return "\(year)"
            }
        }
        
        return grouped.map { period, calcs in
            let amount: Int
            switch selectedChartType {
            case .expenses:
                amount = calcs.reduce(0) { $0 + $1.totalAmount }
            case .count:
                amount = calcs.count
            case .average:
                amount = calcs.isEmpty ? 0 : calcs.reduce(0) { $0 + $1.totalAmount } / calcs.count
            }
            return ChartDataPoint(period: period, amount: amount)
        }.sorted { $0.period < $1.period }
    }
    
    private var seasonComparison: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Season Comparison")
                .font(.system(size: 20, weight: .semibold))
            
            VStack(spacing: 12) {
                ForEach(seasons.sorted { $0.order < $1.order }, id: \.id) { season in
                    let seasonCalcs = calculations.filter { $0.seasonId == season.id }
                    let total = seasonCalcs.reduce(0) { $0 + $1.totalAmount }
                    let count = seasonCalcs.count
                    let average = count > 0 ? total / count : 0
                    
                    SeasonStatRow(
                        season: season,
                        total: total,
                        count: count,
                        average: average
                    )
                }
            }
            .padding(16)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private var topServicesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Most Used Services")
                .font(.system(size: 20, weight: .semibold))
            
            let serviceCounts = getTopServices()
            
            if serviceCounts.isEmpty {
                Text("No services data available")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(serviceCounts.prefix(5).enumerated()), id: \.offset) { index, item in
                        HStack {
                            Text("\(index + 1)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color.blue, in: Circle())
                            
                            Text(item.name)
                                .font(.system(size: 16))
                            
                            Spacer()
                            
                            Text("\(item.count)x")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(12)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(16)
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Trends & Insights")
                .font(.system(size: 20, weight: .semibold))
            
            VStack(spacing: 12) {
                if let mostExpensive = statistics.mostExpensiveSeason,
                   let season = seasons.first(where: { $0.id == mostExpensive }) {
                    InsightRow(
                        icon: "arrow.up.circle.fill",
                        title: "Most Expensive Season",
                        value: season.name,
                        color: .red
                    )
                }
                
                let monthlyAvg = getMonthlyAverage()
                if monthlyAvg > 0 {
                    InsightRow(
                        icon: "calendar.circle.fill",
                        title: "Monthly Average",
                        value: formatPrice(monthlyAvg),
                        color: .blue
                    )
                }
                
                let growth = getGrowthRate()
                if growth != 0 {
                    InsightRow(
                        icon: growth > 0 ? "arrow.up.right.circle.fill" : "arrow.down.right.circle.fill",
                        title: "Growth Rate",
                        value: String(format: "%.1f%%", abs(growth)),
                        color: growth > 0 ? .red : .green
                    )
                }
            }
            .padding(16)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
        }
    }
    
    private func getTopServices() -> [(name: String, count: Int)] {
        var serviceCounts: [String: Int] = [:]
        
        for calculation in calculations {
            for service in calculation.selectedServices ?? [] {
                serviceCounts[service.serviceName, default: 0] += 1
            }
        }
        
        return serviceCounts.map { (name: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    private func getMonthlyAverage() -> Int {
        let last12Months = calculations.filter { calculation in
            let monthsAgo = Calendar.current.dateComponents([.month], from: calculation.date, to: Date()).month ?? 0
            return monthsAgo < 12
        }
        
        guard !last12Months.isEmpty else { return 0 }
        let total = last12Months.reduce(0) { $0 + $1.totalAmount }
        return total / 12
    }
    
    private func getGrowthRate() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let sixMonthsAgo = calendar.date(byAdding: .month, value: -6, to: now) ?? now
        
        let recent = calculations.filter { $0.date >= sixMonthsAgo }
        let older = calculations.filter { $0.date < sixMonthsAgo && $0.date >= calendar.date(byAdding: .month, value: -12, to: now) ?? now }
        
        let recentAvg = recent.isEmpty ? 0 : Double(recent.reduce(0) { $0 + $1.totalAmount }) / Double(recent.count)
        let olderAvg = older.isEmpty ? 0 : Double(older.reduce(0) { $0 + $1.totalAmount }) / Double(older.count)
        
        guard olderAvg > 0 else { return 0 }
        return ((recentAvg - olderAvg) / olderAvg) * 100
    }
    
    private var chartFallback: some View {
        VStack {
            Text("Chart visualization")
                .foregroundColor(.secondary)
            Text("(Requires iOS 16+)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
    
    private func formatPrice(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return "$\(formatter.string(from: NSNumber(value: amount)) ?? "\(amount)")"
    }
}

struct ChartDataPoint {
    let period: String
    let amount: Int
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct SeasonStatRow: View {
    let season: SeasonModel
    let total: Int
    let count: Int
    let average: Int
    
    var body: some View {
        HStack {
            Text(season.emoji)
                .font(.system(size: 32))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(season.name)
                    .font(.system(size: 16, weight: .semibold))
                
                Text("\(count) calculations")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(formatNumber(total))")
                    .font(.system(size: 16, weight: .bold))
                
                Text("Avg: $\(formatNumber(average))")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

struct InsightRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 20))
            
            Text(title)
                .font(.system(size: 16))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
        }
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [
            SeasonModel.self,
            ServiceCategoryModel.self,
            ServiceModel.self,
            CalculationModel.self,
            SelectedServiceModel.self,
            UserSettingsModel.self
        ])
}

