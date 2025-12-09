import SwiftUI
import SwiftData
import UIKit

struct HistoryTabView: View {
    @Query(sort: \CalculationModel.date, order: .reverse) private var calculations: [CalculationModel]
    @Query private var seasons: [SeasonModel]
    @State private var searchText = ""
    @State private var selectedSeasonFilter: String? = nil
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    
    private var filteredCalculations: [CalculationModel] {
        var result = calculations
        
        if !searchText.isEmpty {
            result = result.filter { calculation in
                calculation.note?.localizedCaseInsensitiveContains(searchText) == true ||
                seasons.first(where: { $0.id == calculation.seasonId })?.name.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        if let seasonId = selectedSeasonFilter {
            result = result.filter { $0.seasonId == seasonId }
        }
        
        return result
    }
    
    private var groupedCalculations: [String: [CalculationModel]] {
        Dictionary(grouping: filteredCalculations) { calculation in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            formatter.locale = Locale(identifier: "en_US")
            return formatter.string(from: calculation.date)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and filters
                searchAndFilters
                
                if filteredCalculations.isEmpty {
                    emptyState
                } else {
                    calculationsList
                }
            }
            .navigationTitle("History")
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            exportToCSV()
                        } label: {
                            Label("Export to CSV", systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            exportToPDF()
                        } label: {
                            Label("Export to PDF", systemImage: "doc.fill")
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: shareItems)
            }
        }
    }
    
    private func exportToCSV() {
        let csv = ExportService.shared.exportToCSV(calculations: calculations, seasons: seasons)
        shareItems = [csv]
        showShareSheet = true
    }
    
    private func exportToPDF() {
        guard let pdfData = ExportService.shared.exportToPDF(calculations: calculations, seasons: seasons) else { return }
        shareItems = [pdfData]
        showShareSheet = true
    }
    
    private var searchAndFilters: some View {
    VStack(spacing: 12) {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search", text: $searchText)
                .textFieldStyle(.plain)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    isSelected: selectedSeasonFilter == nil
                ) {
                    selectedSeasonFilter = nil
                }
                
                ForEach(seasons.sorted { $0.order < $1.order }, id: \.id) { season in
                    FilterChip(
                        title: season.emoji + " " + season.name,
                        isSelected: selectedSeasonFilter == season.id
                    ) {
                        selectedSeasonFilter = selectedSeasonFilter == season.id ? nil : season.id
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 16)
    .background(Color(.systemGroupedBackground))
}

private var calculationsList: some View {
    ScrollView {
        LazyVStack(spacing: 16) {
            ForEach(Array(groupedCalculations.keys.sorted(by: >)), id: \.self) { monthKey in
                Section {
                    ForEach(groupedCalculations[monthKey] ?? [], id: \.id) { calculation in
                        NavigationLink {
                            CalculationDetailView(calculation: calculation)
                        } label: {
                            CalculationRowView(calculation: calculation)
                        }
                    }
                } header: {
                    HStack {
                        Text(monthKey)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

private var emptyState: some View {
    VStack(spacing: 20) {
        Image(systemName: "clock.badge.xmark")
            .font(.system(size: 60))
            .foregroundColor(.secondary)
        
        Text("History is empty")
            .font(.system(size: 24, weight: .semibold))
        
        Text("Save your first calculation")
            .font(.system(size: 16))
            .foregroundColor(.secondary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ?
                    AnyShapeStyle(Color.blue) :
                        AnyShapeStyle(.ultraThinMaterial)
                )
                .clipShape(Capsule())
        }
    }
}

struct CalculationRowView: View {
    let calculation: CalculationModel
    @Query private var seasons: [SeasonModel]
    
    private var season: SeasonModel? {
        seasons.first { $0.id == calculation.seasonId }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            if let season = season {
                Text(season.emoji)
                    .font(.system(size: 40))
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.1))
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(season?.name ?? "")
                    .font(.system(size: 18, weight: .semibold))
                
                Text(calculation.date, style: .date)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Text("\(calculation.selectedServices?.count ?? 0) services")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatPrice(calculation.totalAmount, currency: calculation.currency))
                .font(.system(size: 20, weight: .bold))
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
    }
    
    private func formatPrice(_ amount: Int, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        
        let symbol: String
        switch currency {
        case "RUB": symbol = "₽"
        case "USD": symbol = "$"
        case "EUR": symbol = "€"
        case "KZT": symbol = "₸"
        default: symbol = "$"
        }
        
        return "\(formatted) \(symbol)"
    }
}

struct CalculationDetailView: View {
    let calculation: CalculationModel
    @Query private var seasons: [SeasonModel]
    
    private var season: SeasonModel? {
        seasons.first { $0.id == calculation.seasonId }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let season = season {
                    Text(season.emoji)
                        .font(.system(size: 60))
                    
                    Text(season.name)
                        .font(.system(size: 28, weight: .bold))
                }
                
                Text(calculation.date, style: .date)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                
                if let services = calculation.selectedServices {
                    ForEach(services, id: \.serviceId) { service in
                        HStack {
                            Text(service.serviceName)
                            Spacer()
                            Text(formatPrice(service.price, currency: calculation.currency))
                        }
                        .padding(16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                }
                
                VStack(spacing: 12) {
                    Text("Total")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(formatPrice(calculation.totalAmount, currency: calculation.currency))
                        .font(.system(size: 42, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            }
            .padding(20)
        }
        .navigationTitle("Calculation Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatPrice(_ amount: Int, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        
        let symbol: String
        switch currency {
        case "RUB": symbol = "₽"
        case "USD": symbol = "$"
        case "EUR": symbol = "€"
        case "KZT": symbol = "₸"
        default: symbol = "$"
        }
        
        return "\(formatted) \(symbol)"
    }
}

#Preview {
    HistoryTabView()
        .modelContainer(for: [
            SeasonModel.self,
            ServiceCategoryModel.self,
            ServiceModel.self,
            CalculationModel.self,
            SelectedServiceModel.self,
            UserSettingsModel.self
        ])
}

