import SwiftUI
import SwiftData

struct MaintenanceCalendarView: View {
    @Query(sort: \CalculationModel.date, order: .forward) private var calculations: [CalculationModel]
    @Query private var seasons: [SeasonModel]
    @State private var selectedDate: Date = Date()
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var upcomingMaintenance: [CalculationModel] {
        calculations.filter { $0.date >= Date() }
            .sorted { $0.date < $1.date }
            .prefix(10)
            .map { $0 }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Calendar header
                    calendarHeader
                    
                    // Upcoming maintenance
                    upcomingSection
                    
                    // Monthly view
                    monthlyView
                }
                .padding(20)
            }
            .navigationTitle("Maintenance Calendar")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private var calendarHeader: some View {
        VStack(spacing: 16) {
            Text(selectedDate, format: .dateTime.month(.wide).year())
                .font(.system(size: 24, weight: .bold))
            
            HStack {
                Button {
                    selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button {
                    selectedDate = Date()
                } label: {
                    Text("Today")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button {
                    selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Upcoming Maintenance")
                .font(.system(size: 20, weight: .semibold))
            
            if upcomingMaintenance.isEmpty {
                Text("No upcoming maintenance scheduled")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
            } else {
                VStack(spacing: 12) {
                    ForEach(upcomingMaintenance, id: \.id) { calculation in
                        NavigationLink {
                            CalculationDetailView(calculation: calculation)
                        } label: {
                            MaintenanceCalendarRow(calculation: calculation, seasons: seasons)
                        }
                    }
                }
                .padding(16)
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    private var monthlyView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Overview")
                .font(.system(size: 20, weight: .semibold))
            
            let monthCalculations = getCalculationsForMonth()
            
            if monthCalculations.isEmpty {
                Text("No maintenance scheduled for this month")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
            } else {
                VStack(spacing: 12) {
                    ForEach(monthCalculations, id: \.id) { calculation in
                        NavigationLink {
                            CalculationDetailView(calculation: calculation)
                        } label: {
                            MaintenanceCalendarRow(calculation: calculation, seasons: seasons)
                        }
                    }
                }
                .padding(16)
                .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    private func getCalculationsForMonth() -> [CalculationModel] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)) ?? selectedDate
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) ?? selectedDate
        
        return calculations.filter { calculation in
            calculation.date >= startOfMonth && calculation.date <= endOfMonth
        }
    }
}

struct MaintenanceCalendarRow: View {
    let calculation: CalculationModel
    let seasons: [SeasonModel]
    
    private var season: SeasonModel? {
        seasons.first { $0.id == calculation.seasonId }
    }
    
    private var daysUntil: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: calculation.date).day ?? 0
        return days
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(calculation.date, format: .dateTime.day())
                    .font(.system(size: 24, weight: .bold))
                
                Text(calculation.date, format: .dateTime.month(.abbreviated))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .frame(width: 50)
            
            if let season = season {
                Text(season.emoji)
                    .font(.system(size: 32))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(season?.name ?? "Maintenance")
                    .font(.system(size: 16, weight: .semibold))
                
                Text("$\(formatPrice(calculation.totalAmount))")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if daysUntil >= 0 {
                    Text("\(daysUntil) days")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(daysUntil <= 7 ? .red : .blue)
                } else {
                    Text("Past")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func formatPrice(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}

#Preview {
    MaintenanceCalendarView()
        .modelContainer(for: [
            SeasonModel.self,
            ServiceCategoryModel.self,
            ServiceModel.self,
            CalculationModel.self,
            SelectedServiceModel.self,
            UserSettingsModel.self
        ])
}

