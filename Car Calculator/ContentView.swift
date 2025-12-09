import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var errorHandler: ErrorHandler
    @Query private var settings: [UserSettingsModel]
    
    @State private var isInitialized = false
    @State private var showOnboarding = false
    
    private var hasCompletedOnboarding: Bool {
        settings.first?.hasCompletedOnboarding ?? false
    }
    
    var body: some View {
        Group {
            if isInitialized {
                if hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView(isPresented: $showOnboarding)
                        .onAppear {
                            showOnboarding = true
                        }
                        .onChange(of: showOnboarding) { _, newValue in
                            if !newValue {
                                markOnboardingCompleted()
                            }
                        }
                }
            } else {
                ProgressView("Loading...")
                    .task {
                        await initializeData()
                    }
            }
        }
        .errorAlert(errorHandler: errorHandler)
    }
    
    private func initializeData() async {
        let service = DataInitializationService()
        service.setModelContext(modelContext)
        
        do {
            try await service.initializeDefaultData()
            isInitialized = true
        } catch {
            errorHandler.handle(.dataLoadFailed(error.localizedDescription))
            // Continue working even if initialization fails
            isInitialized = true
        }
    }
    
    private func markOnboardingCompleted() {
        if let settings = settings.first {
            settings.hasCompletedOnboarding = true
            do {
                try modelContext.save()
            } catch {
                errorHandler.handle(.dataSaveFailed(error.localizedDescription))
            }
        } else {
            let newSettings = UserSettingsModel(hasCompletedOnboarding: true)
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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SeasonModel.self, ServiceCategoryModel.self, ServiceModel.self, CalculationModel.self, SelectedServiceModel.self, UserSettingsModel.self, configurations: config)
    
    return ContentView()
        .modelContainer(container)
}
