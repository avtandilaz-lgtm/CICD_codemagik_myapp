import SwiftUI
import SwiftData

@main
struct Car_CalculatorApp: App {
    @StateObject private var errorHandler = ErrorHandler()
    
    init() {
        // Request notification permissions
        NotificationService.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(errorHandler)
                .modelContainer(createModelContainer(errorHandler: errorHandler))
                .onAppear {
                    // Schedule seasonal reminders
                    NotificationService.shared.scheduleSeasonalReminders()
                }
        }
    }
    
    private func createModelContainer(errorHandler: ErrorHandler) -> ModelContainer {
        let schema = Schema([
            SeasonModel.self,
            ServiceCategoryModel.self,
            ServiceModel.self,
            CalculationModel.self,
            SelectedServiceModel.self,
            UserSettingsModel.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Log error and create in-memory container as fallback
            errorHandler.handle(.databaseInitializationFailed(error.localizedDescription))
            
            // Create in-memory container to continue working
            let inMemoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                return try ModelContainer(for: schema, configurations: [inMemoryConfig])
            } catch {
                // If this also fails, return empty container
                // In a real app, you can show an error screen
                return try! ModelContainer(for: schema, configurations: [inMemoryConfig])
            }
        }
    }
}
