import Foundation
import SwiftData

@Model
final class CalculationModel {
    @Attribute(.unique) var id: UUID
    var date: Date
    var seasonId: String
    var totalAmount: Int
    var currency: String
    var region: String
    var note: String?
    
    @Relationship(deleteRule: .cascade) var selectedServices: [SelectedServiceModel]?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        seasonId: String,
        totalAmount: Int,
        currency: String,
        region: String,
        note: String? = nil,
        selectedServices: [SelectedServiceModel] = []
    ) {
        self.id = id
        self.date = date
        self.seasonId = seasonId
        self.totalAmount = totalAmount
        self.currency = currency
        self.region = region
        self.note = note
        self.selectedServices = selectedServices
    }
}

@Model
final class SelectedServiceModel {
    var serviceId: UUID
    var serviceName: String
    var price: Int
    var isCustom: Bool
    
    init(serviceId: UUID, serviceName: String, price: Int, isCustom: Bool = false) {
        self.serviceId = serviceId
        self.serviceName = serviceName
        self.price = price
        self.isCustom = isCustom
    }
}

