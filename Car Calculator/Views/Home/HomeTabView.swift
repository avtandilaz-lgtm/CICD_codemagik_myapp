import SwiftUI
import SwiftData

struct HomeTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var seasons: [SeasonModel]
    @Query(sort: \CalculationModel.date, order: .reverse) private var calculations: [CalculationModel]
    
    private var currentSeason: SeasonModel? {
        let currentSeasonId = SeasonModel.getCurrentSeasonId()
        return seasons.first { $0.id == currentSeasonId } ?? seasons.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Current season section
                    seasonSection
                    
                    // Tips section
                    tipsSection
                    
                    // Quick calculator section
                    quickCalculatorSection
                    
                    // Last calculation section
                    if let last = calculations.first {
                        lastCalculationSection(last)
                    }
                    
                    // Statistics section
                    statisticsSection
                    
                    // Calendar section
                    calendarSection
                    
                    // Templates section
                    templatesSection
                }
                .padding(20)
            }
            .navigationTitle("CarSeason Costs")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // Season section
    private var seasonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Current Season")
                .font(.system(size: 20, weight: .semibold))
            
            if let season = currentSeason {
                HStack(spacing: 16) {
                    Text(season.emoji)
                        .font(.system(size: 50))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(season.name)
                            .font(.system(size: 24, weight: .bold))
                        
                        Text("Automatically detected by date")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    // Tips section
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tips")
                    .font(.system(size: 20, weight: .semibold))
                
                Spacer()
                
                if let season = currentSeason {
                    NavigationLink {
                        TipsView(season: season)
                    } label: {
                        Text("All")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                }
            }
            
            if let season = currentSeason {
                VStack(spacing: 12) {
                    ForEach(Array(season.getTips().prefix(3).enumerated()), id: \.offset) { index, tip in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                            .background(Color.blue.opacity(0.1), in: Circle())
                        
                        Text(tip)
                            .font(.system(size: 15))
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }
    
    // Quick calculator section
    private var quickCalculatorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Calculator")
                .font(.system(size: 20, weight: .semibold))
            
            NavigationLink {
                CalculatorTabView()
            } label: {
                HStack {
                    Image(systemName: "calculator.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Calculate Costs")
                            .font(.system(size: 17, weight: .semibold))
                        
                        Text("Add services and get the total amount")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    // Last calculation section
    private func lastCalculationSection(_ calculation: CalculationModel) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Last Calculation")
                .font(.system(size: 20, weight: .semibold))
            
            NavigationLink {
                CalculationDetailView(calculation: calculation)
            } label: {
                HStack {
                    if let season = seasons.first(where: { $0.id == calculation.seasonId }) {
                        Text(season.emoji)
                            .font(.system(size: 32))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(calculation.date, style: .date)
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("\(calculation.selectedServices?.count ?? 0) services")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(formatPrice(calculation.totalAmount)) $")
                        .font(.system(size: 20, weight: .bold))
                }
                .padding(16)
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    // Statistics section
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analytics")
                .font(.system(size: 20, weight: .semibold))
            
            NavigationLink {
                StatisticsView()
            } label: {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("View Statistics")
                            .font(.system(size: 17, weight: .semibold))
                        
                        Text("Track expenses and trends")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    // Calendar section
    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Calendar")
                .font(.system(size: 20, weight: .semibold))
            
            NavigationLink {
                MaintenanceCalendarView()
            } label: {
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Maintenance Calendar")
                            .font(.system(size: 17, weight: .semibold))
                        
                        Text("View upcoming maintenance")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    // Templates section
    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Start")
                .font(.system(size: 20, weight: .semibold))
            
            NavigationLink {
                MaintenanceTemplatesView()
            } label: {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Maintenance Templates")
                            .font(.system(size: 17, weight: .semibold))
                        
                        Text("Use pre-configured service templates")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    private func formatPrice(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}

#Preview {
    HomeTabView()
        .modelContainer(for: [
            SeasonModel.self,
            ServiceCategoryModel.self,
            ServiceModel.self,
            CalculationModel.self,
            SelectedServiceModel.self,
            UserSettingsModel.self
        ])
}
