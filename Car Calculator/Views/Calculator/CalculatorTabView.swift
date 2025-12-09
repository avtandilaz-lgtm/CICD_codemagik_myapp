import SwiftUI
import SwiftData

struct CalculatorTabView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var errorHandler: ErrorHandler
    @Query private var seasons: [SeasonModel]
    
    let templateServices: [(name: String, price: Int)]?
    
    @State private var selectedSeason: SeasonModel?
    @State private var serviceItems: [ServiceItem] = []
    @State private var totalAmount: Int = 0
    @State private var showSaveSuccess = false
    @State private var templateLoaded = false
    
    init(templateServices: [(name: String, price: Int)]? = nil) {
        self.templateServices = templateServices
    }
    
    struct ServiceItem: Identifiable, Equatable {
        let id = UUID()
        var name: String
        var price: Int
        
        static func == (lhs: ServiceItem, rhs: ServiceItem) -> Bool {
            lhs.id == rhs.id && lhs.name == rhs.name && lhs.price == rhs.price
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Season selection
                    seasonPicker
                    
                    // Services list
                    servicesList
                    
                    // Add button
                    addServiceButton
                    
                    // Total amount
                    totalSection
                    
                    // Action buttons
                    actionButtons
                }
                .padding(20)
            }
            .navigationTitle("Calculator")
            .background(Color(.systemGroupedBackground))
            .onChange(of: serviceItems) { _, _ in
                calculateTotal()
            }
            .onAppear {
                if let templateServices = templateServices, !templateLoaded {
                    // Load template services only once
                    serviceItems = templateServices.map { service in
                        ServiceItem(name: service.name, price: service.price)
                    }
                    calculateTotal()
                    
                    // Auto-select season based on template type
                    if templateServices.contains(where: { $0.name.contains("Winter") }) {
                        selectedSeason = seasons.first { $0.id == "winter" }
                    } else if templateServices.contains(where: { $0.name.contains("Summer") }) {
                        selectedSeason = seasons.first { $0.id == "summer" }
                    }
                    
                    templateLoaded = true
                }
            }
            .overlay(alignment: .top) {
                if showSaveSuccess {
                    SaveSuccessToast()
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
    
    private var seasonPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Season")
                .font(.system(size: 16, weight: .semibold))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(seasons.sorted { $0.order < $1.order }, id: \.id) { season in
                        Button {
                            selectedSeason = season
                        } label: {
                            HStack(spacing: 8) {
                                Text(season.emoji)
                                    .font(.system(size: 20))
                                Text(season.name)
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(selectedSeason?.id == season.id ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                selectedSeason?.id == season.id ?
                                Color.blue : Color(.systemGray5)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var servicesList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Services")
                .font(.system(size: 16, weight: .semibold))
            
            if serviceItems.isEmpty {
                Text("Add services for calculation")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                ForEach(serviceItems) { item in
                    ServiceItemRow(
                        item: Binding(
                            get: { item },
                            set: { newValue in
                                if let index = serviceItems.firstIndex(where: { $0.id == item.id }) {
                                    serviceItems[index] = newValue
                                }
                            }
                        ),
                        onDelete: {
                            serviceItems.removeAll { $0.id == item.id }
                        }
                    )
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var addServiceButton: some View {
        Button {
            serviceItems.append(ServiceItem(name: "", price: 0))
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Service")
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var totalSection: some View {
        VStack(spacing: 8) {
            Text("Total")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("\(formatPrice(totalAmount)) $")
                .font(.system(size: 36, weight: .bold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                saveCalculation()
            } label: {
                Text("Save")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue, in: RoundedRectangle(cornerRadius: 12))
            }
            
            ShareLink(item: generateShareText()) {
                Text("Share")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.green, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private func calculateTotal() {
        totalAmount = serviceItems.reduce(0) { $0 + $1.price }
    }
    
    private func saveCalculation() {
        // Validation: check that season is selected
        guard let season = selectedSeason else {
            errorHandler.handle(.invalidInput("Select a season to save the calculation"))
            return
        }
        
        // Validation: check that there is at least one service
        guard !serviceItems.isEmpty else {
            errorHandler.handle(.invalidInput("Add at least one service to save"))
            return
        }
        
        // Validate all services
        for (index, item) in serviceItems.enumerated() {
            let nameValidation = InputValidator.validateServiceName(item.name)
            if !nameValidation.isValid {
                errorHandler.handle(.invalidInput("Service \(index + 1): \(nameValidation.errorMessage ?? "")"))
                return
            }
            
            let priceValidation = InputValidator.validatePrice(item.price)
            if !priceValidation.isValid {
                errorHandler.handle(.invalidInput("Service \(index + 1): \(priceValidation.errorMessage ?? "")"))
                return
            }
        }
        
        // Validate total amount
        guard totalAmount > 0 else {
            errorHandler.handle(.invalidInput("Total amount must be greater than zero"))
            return
        }
        
        let selectedServices = serviceItems.map { item in
            SelectedServiceModel(
                serviceId: item.id,
                serviceName: item.name.trimmingCharacters(in: .whitespacesAndNewlines),
                price: item.price,
                isCustom: true
            )
        }
        
        let calculation = CalculationModel(
            seasonId: season.id,
            totalAmount: totalAmount,
            currency: "USD",
            region: "moscow",
            selectedServices: selectedServices
        )
        
        modelContext.insert(calculation)
        
        do {
            try modelContext.save()
            
            withAnimation {
                showSaveSuccess = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showSaveSuccess = false
                }
            }
        } catch {
            errorHandler.handle(.dataSaveFailed(error.localizedDescription))
        }
    }
    
    private func formatPrice(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    private func generateShareText() -> String {
        var text = "Maintenance Calculation\n\n"
        if let season = selectedSeason {
            text += "Season: \(season.emoji) \(season.name)\n\n"
        }
        text += "Services:\n"
        for item in serviceItems {
            text += "• \(item.name.isEmpty ? "Service" : item.name): \(formatPrice(item.price)) $\n"
        }
        text += "\nTotal: \(formatPrice(totalAmount)) $"
        return text
    }
}

struct ServiceItemRow: View {
    @Binding var item: CalculatorTabView.ServiceItem
    let onDelete: () -> Void
    
    @State private var priceText: String = ""
    @State private var nameError: String?
    @State private var priceError: String?
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("Service name", text: Binding(
                        get: { item.name },
                        set: { newValue in
                            item.name = newValue
                            validateName(newValue)
                        }
                    ))
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
                    .onChange(of: item.name) { _, newValue in
                        validateName(newValue)
                    }
                    
                    if let error = nameError {
                        Text(error)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            HStack {
                Text("Price:")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    TextField("0", text: $priceText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)
                        .onChange(of: priceText) { _, newValue in
                            let formatted = InputValidator.formatPriceInput(newValue)
                            priceText = formatted
                            
                            let cleaned = formatted.replacingOccurrences(of: " ", with: "")
                            if let price = Int(cleaned) {
                                item.price = price
                                validatePrice(price)
                            } else if cleaned.isEmpty {
                                item.price = 0
                                priceError = nil
                            }
                        }
                        .onAppear {
                            priceText = item.price > 0 ? InputValidator.formatPriceInput("\(item.price)") : ""
                        }
                    
                    if let error = priceError {
                        Text(error)
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }
                }
                
                Text("$")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding(12)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func validateName(_ name: String) {
        let result = InputValidator.validateServiceName(name)
        nameError = result.errorMessage
    }
    
    private func validatePrice(_ price: Int) {
        let result = InputValidator.validatePrice(price)
        priceError = result.errorMessage
    }
}

struct SaveSuccessToast: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text("Calculation saved!")
                .font(.system(size: 16, weight: .semibold))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding(.top, 60)
    }
}

#Preview {
    CalculatorTabView()
        .modelContainer(for: [
            SeasonModel.self,
            ServiceCategoryModel.self,
            ServiceModel.self,
            CalculationModel.self,
            SelectedServiceModel.self,
            UserSettingsModel.self
        ])
}
