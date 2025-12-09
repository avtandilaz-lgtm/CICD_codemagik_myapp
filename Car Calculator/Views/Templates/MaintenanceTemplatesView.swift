import SwiftUI
import SwiftData

struct MaintenanceTemplatesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var seasons: [SeasonModel]
    @State private var selectedTemplate: TemplateType? = nil
    
    enum TemplateType: String, CaseIterable {
        case basic = "Basic Maintenance"
        case comprehensive = "Comprehensive"
        case winter = "Winter Preparation"
        case summer = "Summer Preparation"
        
        var services: [(name: String, price: Int)] {
            switch self {
            case .basic:
                return [
                    ("Oil Change", 50),
                    ("Tire Rotation", 30),
                    ("Air Filter Replacement", 25)
                ]
            case .comprehensive:
                return [
                    ("Full Service", 200),
                    ("Brake Inspection", 80),
                    ("Battery Check", 40),
                    ("Fluid Top-up", 60)
                ]
            case .winter:
                return [
                    ("Winter Tires", 400),
                    ("Battery Check", 40),
                    ("Antifreeze Check", 30),
                    ("Heater Inspection", 50)
                ]
            case .summer:
                return [
                    ("AC Service", 100),
                    ("Coolant Check", 30),
                    ("Tire Pressure Check", 20),
                    ("Summer Tires", 400)
                ]
            }
        }
        
        var description: String {
            switch self {
            case .basic:
                return "Essential maintenance for regular upkeep"
            case .comprehensive:
                return "Complete vehicle inspection and service"
            case .winter:
                return "Prepare your car for cold weather"
            case .summer:
                return "Get ready for hot summer days"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Choose a maintenance template to quickly add common services")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    ForEach(TemplateType.allCases, id: \.self) { template in
                        TemplateCard(
                            template: template,
                            isSelected: selectedTemplate == template
                        ) {
                            selectedTemplate = template
                        }
                    }
                    
                    if let template = selectedTemplate {
                        applyTemplateSection(template)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Templates")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private func applyTemplateSection(_ template: TemplateType) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Template Services")
                .font(.system(size: 20, weight: .semibold))
            
            VStack(spacing: 12) {
                ForEach(Array(template.services.enumerated()), id: \.offset) { index, service in
                    HStack {
                        Text(service.name)
                            .font(.system(size: 16))
                        
                        Spacer()
                        
                        Text("$\(service.price)")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .padding(12)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                }
            }
            
            let total = template.services.reduce(0) { $0 + $1.price }
            
            HStack {
                Text("Total:")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Text("$\(total)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.blue)
            }
            .padding(16)
            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
            
            NavigationLink {
                CalculatorTabView(templateServices: template.services)
            } label: {
                Text("Use This Template")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

struct TemplateCard: View {
    let template: MaintenanceTemplatesView.TemplateType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(template.rawValue)
                        .font(.system(size: 18, weight: .semibold))
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                Text(template.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                let total = template.services.reduce(0) { $0 + $1.price }
                Text("Total: $\(total)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
            }
            .padding(16)
            .background(
                isSelected ?
                Color.blue.opacity(0.1) :
                Color(.systemBackground),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    MaintenanceTemplatesView()
        .modelContainer(for: [
            SeasonModel.self,
            ServiceCategoryModel.self,
            ServiceModel.self,
            CalculationModel.self,
            SelectedServiceModel.self,
            UserSettingsModel.self
        ])
}

