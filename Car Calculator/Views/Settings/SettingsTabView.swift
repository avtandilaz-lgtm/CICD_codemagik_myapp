import SwiftUI
import SwiftData

struct SettingsTabView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var errorHandler: ErrorHandler
    @Query private var settings: [UserSettingsModel]
    
    @State private var selectedTheme: AppTheme = .system
    
    private var userSettings: UserSettingsModel? {
        settings.first
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $selectedTheme) {
                        Text("Light").tag(AppTheme.light)
                        Text("Dark").tag(AppTheme.dark)
                        Text("System").tag(AppTheme.system)
                    }
                    .onChange(of: selectedTheme) { _, newValue in
                        updateSettings { $0.theme = newValue.rawValue }
                    }
                }
                
                Section("Notifications") {
                    Button {
                        NotificationService.shared.requestAuthorization()
                        NotificationService.shared.scheduleSeasonalReminders()
                    } label: {
                        HStack {
                            Text("Enable Reminders")
                            Spacer()
                            Image(systemName: "bell.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section("Tools") {
                    NavigationLink {
                        MaintenanceTemplatesView()
                    } label: {
                        HStack {
                            Text("Maintenance Templates")
                            Spacer()
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section {
                    VStack(spacing: 8) {
                        Text("CarSeason Costs")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Version 1.0")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                loadSettings()
            }
        }
    }
    
    private func loadSettings() {
        guard let settings = userSettings else { return }
        selectedTheme = AppTheme(rawValue: settings.theme) ?? .system
    }
    
    private func updateSettings(_ update: (UserSettingsModel) -> Void) {
        if let settings = userSettings {
            update(settings)
            do {
                try modelContext.save()
            } catch {
                errorHandler.handle(.dataSaveFailed(error.localizedDescription))
            }
        } else {
            let newSettings = UserSettingsModel()
            update(newSettings)
            modelContext.insert(newSettings)
            do {
                try modelContext.save()
            } catch {
                errorHandler.handle(.dataSaveFailed(error.localizedDescription))
            }
        }
    }
}

#Preview {
    SettingsTabView()
        .modelContainer(for: [
            SeasonModel.self,
            ServiceCategoryModel.self,
            ServiceModel.self,
            CalculationModel.self,
            SelectedServiceModel.self,
            UserSettingsModel.self
        ])
}
