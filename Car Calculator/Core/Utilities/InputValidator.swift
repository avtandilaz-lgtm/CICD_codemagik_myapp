import Foundation

struct InputValidator {
    static func validateServiceName(_ name: String) -> ValidationResult {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return .invalid("Service name cannot be empty")
        }
        
        if trimmed.count > 100 {
            return .invalid("Service name cannot be longer than 100 characters")
        }
        
        return .valid
    }
    
    static func validatePrice(_ priceString: String) -> ValidationResult {
        let cleaned = priceString.replacingOccurrences(of: " ", with: "")
        
        if cleaned.isEmpty {
            return .invalid("Price cannot be empty")
        }
        
        guard let price = Int(cleaned) else {
            return .invalid("Price must be a number")
        }
        
        if price < 0 {
            return .invalid("Price cannot be negative")
        }
        
        if price > 10_000_000 {
            return .invalid("Price is too large (maximum $10,000,000)")
        }
        
        return .valid
    }
    
    static func validatePrice(_ price: Int) -> ValidationResult {
        if price < 0 {
            return .invalid("Price cannot be negative")
        }
        
        if price > 10_000_000 {
            return .invalid("Price is too large (maximum $10,000,000)")
        }
        
        return .valid
    }
    
    static func formatPriceInput(_ input: String) -> String {
        // Remove all non-digit characters except spaces
        let cleaned = input.replacingOccurrences(of: "[^0-9 ]", with: "", options: .regularExpression)
        
        // Remove spaces for parsing
        let digitsOnly = cleaned.replacingOccurrences(of: " ", with: "")
        
        // Format with spaces for thousands
        if let number = Int(digitsOnly) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = " "
            return formatter.string(from: NSNumber(value: number)) ?? digitsOnly
        }
        
        return cleaned
    }
}

enum ValidationResult {
    case valid
    case invalid(String)
    
    var isValid: Bool {
        if case .valid = self {
            return true
        }
        return false
    }
    
    var errorMessage: String? {
        if case .invalid(let message) = self {
            return message
        }
        return nil
    }
}

