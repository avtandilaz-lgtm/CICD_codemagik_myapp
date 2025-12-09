import Foundation
import SwiftData

@Model
final class ServiceCategoryModel {
    @Attribute(.unique) var id: String
    var name: String
    var nameEn: String
    var nameKz: String
    var icon: String
    var order: Int
    
    @Relationship(deleteRule: .cascade) var services: [ServiceModel]?
    
    init(id: String, name: String, nameEn: String, nameKz: String, icon: String, order: Int) {
        self.id = id
        self.name = name
        self.nameEn = nameEn
        self.nameKz = nameKz
        self.icon = icon
        self.order = order
        self.services = []
    }
}

