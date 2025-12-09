import Foundation
import SwiftData

protocol DataInitializationServiceProtocol {
    func initializeDefaultData() async throws
}

@MainActor
final class DataInitializationService: DataInitializationServiceProtocol, ObservableObject {
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    func initializeDefaultData() async throws {
        guard let modelContext = modelContext else {
            throw AppError.databaseInitializationFailed("ModelContext is not set")
        }
        
        // Check if initialization has already been done
        let settingsDescriptor = FetchDescriptor<UserSettingsModel>()
        let existingSettings: [UserSettingsModel]
        
        do {
            existingSettings = try modelContext.fetch(settingsDescriptor)
        } catch {
            throw AppError.dataLoadFailed("Failed to check settings: \(error.localizedDescription)")
        }
        
        if existingSettings.isEmpty == false {
            return // Data already initialized
        }
        
        // Create default settings
        let defaultSettings = UserSettingsModel()
        modelContext.insert(defaultSettings)
        
        // Create seasons (check that they don't exist yet)
        let seasonDescriptor = FetchDescriptor<SeasonModel>()
        let existingSeasons = (try? modelContext.fetch(seasonDescriptor)) ?? []
        
        if existingSeasons.isEmpty {
            for seasonData in SeasonModel.getDefaultSeasons() {
                // Check that season with this id doesn't exist yet
                if existingSeasons.first(where: { $0.id == seasonData.id }) == nil {
                    let season = SeasonModel(
                        id: seasonData.id,
                        name: seasonData.name,
                        emoji: seasonData.emoji,
                        order: seasonData.order
                    )
                    modelContext.insert(season)
                }
            }
        }
        
        // Create service categories
        let categories = createDefaultCategories()
        for category in categories {
            modelContext.insert(category)
        }
        
        // Create services
        let services = createDefaultServices()
        for service in services {
            modelContext.insert(service)
        }
        
        do {
            try modelContext.save()
        } catch {
            throw AppError.dataSaveFailed("Failed to save initial data: \(error.localizedDescription)")
        }
    }
    
    private func createDefaultCategories() -> [ServiceCategoryModel] {
        return [
            ServiceCategoryModel(
                id: "tires",
                name: "Tires and Wheels",
                nameEn: "Tires and Wheels",
                nameKz: "Tires and Wheels",
                icon: "circle.grid.cross.fill",
                order: 0
            ),
            ServiceCategoryModel(
                id: "fluids",
                name: "Fluids",
                nameEn: "Fluids",
                nameKz: "Fluids",
                icon: "drop.fill",
                order: 1
            ),
            ServiceCategoryModel(
                id: "electrical",
                name: "Electrical",
                nameEn: "Electrical",
                nameKz: "Electrical",
                icon: "bolt.fill",
                order: 2
            ),
            ServiceCategoryModel(
                id: "body",
                name: "Body",
                nameEn: "Body",
                nameKz: "Body",
                icon: "car.fill",
                order: 3
            ),
            ServiceCategoryModel(
                id: "brakes",
                name: "Brakes",
                nameEn: "Brakes",
                nameKz: "Brakes",
                icon: "stop.circle.fill",
                order: 4
            ),
            ServiceCategoryModel(
                id: "other",
                name: "Other",
                nameEn: "Other",
                nameKz: "Other",
                icon: "ellipsis.circle.fill",
                order: 5
            )
        ]
    }
    
    private func createDefaultServices() -> [ServiceModel] {
        // This is a simplified version, full list will be in JSON file
        return [
            // Winter services
            ServiceModel(
                name: "Tire mounting + winter tires",
                serviceDescription: "Installation of winter tires and wheel balancing",
                recommendation: "Change every 6-8 thousand km or once a year before winter",
                defaultPriceMoscow: 45000,
                defaultPriceSpb: 42000,
                defaultPriceRegions: 38000,
                defaultPriceKazakhstan: 40000,
                isRecommended: true,
                order: 0
            ),
            ServiceModel(
                name: "Oil and filter replacement",
                serviceDescription: "Replacement of engine oil, oil filter and air filter",
                recommendation: "Recommended every 10-15 thousand km or once a year",
                defaultPriceMoscow: 3500,
                defaultPriceSpb: 3300,
                defaultPriceRegions: 3000,
                defaultPriceKazakhstan: 3200,
                isRecommended: true,
                order: 1
            )
        ]
    }
}

