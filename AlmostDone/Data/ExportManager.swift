//
//  ExportManager.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import Foundation
import SwiftData
import PDFKit
import UIKit

// Encodable struct for JSON export
struct AlmostMomentExport: Codable {
    let id: UUID
    let category: String
    let closenessPercentage: Int
    let obstacle: String
    let text: String?
    let mediaURL: String?
    let latitude: Double?
    let longitude: Double?
    let timestamp: Date
    let isVictory: Bool
    let victoryFeeling: String?
    let secondChanceDeadline: Date?
    let secondChanceActive: Bool
}

@MainActor
class ExportManager {
    static let shared = ExportManager()
    
    private init() {}
    
    // Export to JSON
    func exportToJSON(context: ModelContext) throws -> Data {
        let descriptor = FetchDescriptor<AlmostMoment>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let moments = try context.fetch(descriptor)
        
        // Convert to encodable structs
        let exportData = moments.map { moment in
            AlmostMomentExport(
                id: moment.id,
                category: moment.category,
                closenessPercentage: moment.closenessPercentage,
                obstacle: moment.obstacle,
                text: moment.text,
                mediaURL: moment.mediaURL,
                latitude: moment.latitude,
                longitude: moment.longitude,
                timestamp: moment.timestamp,
                isVictory: moment.isVictory,
                victoryFeeling: moment.victoryFeeling,
                secondChanceDeadline: moment.secondChanceDeadline,
                secondChanceActive: moment.secondChanceActive
            )
        }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let jsonData = try encoder.encode(exportData)
        return jsonData
    }
    
    // Export to PDF "My Book of Almost"
    func exportToPDF(context: ModelContext) throws -> Data {
        let descriptor = FetchDescriptor<AlmostMoment>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let moments = try context.fetch(descriptor)
        
        let pdfMetaData = [
            kCGPDFContextCreator: "Almost Done App",
            kCGPDFContextAuthor: "User",
            kCGPDFContextTitle: "My Book of Almost"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = 50
            let titleFont = UIFont.boldSystemFont(ofSize: 24)
            let headingFont = UIFont.boldSystemFont(ofSize: 18)
            let bodyFont = UIFont.systemFont(ofSize: 12)
            
            // Title
            "My Book of Almost".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                .font: titleFont
            ])
            yPosition += 40
            
            // Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            let dateString = "Generated on \(dateFormatter.string(from: Date()))"
            dateString.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                .font: bodyFont,
                .foregroundColor: UIColor.gray
            ])
            yPosition += 60
            
            // Moments
            for (index, moment) in moments.enumerated() {
                if yPosition > pageHeight - 100 {
                    context.beginPage()
                    yPosition = 50
                }
                
                // Category and date
                let categoryText = "\(moment.categoryEnum.displayName) • \(dateFormatter.string(from: moment.timestamp))"
                categoryText.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                    .font: headingFont
                ])
                yPosition += 25
                
                // Closeness percentage
                let closenessText = "Closeness: \(moment.closenessPercentage)%"
                closenessText.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                    .font: bodyFont
                ])
                yPosition += 20
                
                // Obstacle
                let obstacleText = "Obstacle: \(moment.obstacleEnum.displayName)"
                obstacleText.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                    .font: bodyFont
                ])
                yPosition += 20
                
                // Text if available
                if let text = moment.text, !text.isEmpty {
                    let textRect = CGRect(x: 50, y: yPosition, width: pageWidth - 100, height: 100)
                    text.draw(in: textRect, withAttributes: [
                        .font: bodyFont
                    ])
                    yPosition += 100
                }
                
                // Victory status
                if moment.isVictory {
                    "✓ VICTORY".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: [
                        .font: UIFont.boldSystemFont(ofSize: 14),
                        .foregroundColor: UIColor.systemGreen
                    ])
                    yPosition += 20
                }
                
                yPosition += 30
            }
        }
        
        return data
    }
}
