import Foundation
import SwiftUI
import SwiftData
import UIKit
import UniformTypeIdentifiers

class ExportService {
    static let shared = ExportService()
    
    private init() {}
    
    func exportToCSV(calculations: [CalculationModel], seasons: [SeasonModel]) -> String {
        var csv = "Date,Season,Total Amount,Currency,Services Count,Note\n"
        
        for calculation in calculations {
            let season = seasons.first(where: { $0.id == calculation.seasonId })?.name ?? calculation.seasonId
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: calculation.date)
            let servicesCount = calculation.selectedServices?.count ?? 0
            let note = calculation.note?.replacingOccurrences(of: ",", with: ";") ?? ""
            
            csv += "\(dateString),\(season),\(calculation.totalAmount),\(calculation.currency),\(servicesCount),\(note)\n"
        }
        
        return csv
    }
    
    func exportToPDF(calculations: [CalculationModel], seasons: [SeasonModel]) -> Data? {
        let html = generateHTMLReport(calculations: calculations, seasons: seasons)
        
        let printFormatter = UIMarkupTextPrintFormatter(markupText: html)
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        printFormatter.perPageContentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
        
        let pdfData = NSMutableData()
        let pdfContext = UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        
        guard pdfContext != nil else { return nil }
        
        UIGraphicsBeginPDFPage()
        
        let printableRect = CGRect(
            x: printFormatter.perPageContentInsets.left,
            y: printFormatter.perPageContentInsets.top,
            width: pageRect.width - printFormatter.perPageContentInsets.left - printFormatter.perPageContentInsets.right,
            height: pageRect.height - printFormatter.perPageContentInsets.top - printFormatter.perPageContentInsets.bottom
        )
        
        printFormatter.draw(in: printableRect, forPageAt: 0)
        
        UIGraphicsEndPDFContext()
        
        return pdfData as Data
    }
    
    private func generateHTMLReport(calculations: [CalculationModel], seasons: [SeasonModel]) -> String {
        var html = """
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body { font-family: Arial, sans-serif; padding: 20px; }
                h1 { color: #333; }
                table { width: 100%; border-collapse: collapse; margin-top: 20px; }
                th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                th { background-color: #4CAF50; color: white; }
                tr:nth-child(even) { background-color: #f2f2f2; }
            </style>
        </head>
        <body>
            <h1>Car Maintenance Report</h1>
            <p>Generated on: \(Date().formatted(date: .long, time: .shortened))</p>
            <table>
                <tr>
                    <th>Date</th>
                    <th>Season</th>
                    <th>Total Amount</th>
                    <th>Services</th>
                </tr>
        """
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        for calculation in calculations {
            let season = seasons.first(where: { $0.id == calculation.seasonId })?.name ?? calculation.seasonId
            let dateString = dateFormatter.string(from: calculation.date)
            let servicesCount = calculation.selectedServices?.count ?? 0
            
            html += """
                <tr>
                    <td>\(dateString)</td>
                    <td>\(season)</td>
                    <td>$\(calculation.totalAmount)</td>
                    <td>\(servicesCount)</td>
                </tr>
            """
        }
        
        let total = calculations.reduce(0) { $0 + $1.totalAmount }
        html += """
            </table>
            <h2>Total Spent: $\(total)</h2>
        </body>
        </html>
        """
        
        return html
    }
}

