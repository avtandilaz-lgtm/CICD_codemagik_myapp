import Foundation
import SwiftData

@Model
final class ServiceModel {
    @Attribute(.unique) var id: UUID
    var name: String
    var nameEn: String
    var nameKz: String
    var serviceDescription: String
    var descriptionEn: String
    var descriptionKz: String
    var recommendation: String
    var recommendationEn: String
    var recommendationKz: String
    
    var defaultPriceMoscow: Int
    var defaultPriceSpb: Int
    var defaultPriceRegions: Int
    var defaultPriceKazakhstan: Int
    
    var isRecommended: Bool
    var order: Int
    
    var category: ServiceCategoryModel?
    
    init(
        id: UUID = UUID(),
        name: String,
        nameEn: String = "",
        nameKz: String = "",
        serviceDescription: String,
        descriptionEn: String = "",
        descriptionKz: String = "",
        recommendation: String,
        recommendationEn: String = "",
        recommendationKz: String = "",
        defaultPriceMoscow: Int,
        defaultPriceSpb: Int,
        defaultPriceRegions: Int,
        defaultPriceKazakhstan: Int = 0,
        isRecommended: Bool = true,
        order: Int = 0
    ) {
        self.id = id
        self.name = name
        self.nameEn = nameEn
        self.nameKz = nameKz
        self.serviceDescription = serviceDescription
        self.descriptionEn = descriptionEn
        self.descriptionKz = descriptionKz
        self.recommendation = recommendation
        self.recommendationEn = recommendationEn
        self.recommendationKz = recommendationKz
        self.defaultPriceMoscow = defaultPriceMoscow
        self.defaultPriceSpb = defaultPriceSpb
        self.defaultPriceRegions = defaultPriceRegions
        self.defaultPriceKazakhstan = defaultPriceKazakhstan
        self.isRecommended = isRecommended
        self.order = order
    }
    
    func getPrice(for region: Region) -> Int {
        switch region {
        case .moscow: return defaultPriceMoscow
        case .spb: return defaultPriceSpb
        case .regions: return defaultPriceRegions
        case .kazakhstan: return defaultPriceKazakhstan
        }
    }
}

