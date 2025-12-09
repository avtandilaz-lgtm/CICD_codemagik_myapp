import Foundation
import SwiftUI
import os.log

enum AppError: LocalizedError {
    case databaseInitializationFailed(String)
    case dataSaveFailed(String)
    case dataLoadFailed(String)
    case invalidInput(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .databaseInitializationFailed(let message):
            return "Database initialization error: \(message)"
        case .dataSaveFailed(let message):
            return "Failed to save data: \(message)"
        case .dataLoadFailed(let message):
            return "Failed to load data: \(message)"
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .unknown(let error):
            return "An error occurred: \(error.localizedDescription)"
        }
    }
}

@MainActor
final class ErrorHandler: ObservableObject {
    @Published var currentError: AppError?
    @Published var showError = false
    
    private let logger = Logger(subsystem: "com.carseason.calculator", category: "ErrorHandler")
    
    func handle(_ error: Error) {
        let appError: AppError
        if let appErr = error as? AppError {
            appError = appErr
        } else {
            appError = .unknown(error)
        }
        
        currentError = appError
        showError = true
        
        logger.error("Error occurred: \(appError.localizedDescription, privacy: .public)")
    }
    
    func handle(_ appError: AppError) {
        currentError = appError
        showError = true
        
        logger.error("Error occurred: \(appError.localizedDescription, privacy: .public)")
    }
    
    func clear() {
        currentError = nil
        showError = false
    }
}

struct ErrorAlert: ViewModifier {
    @ObservedObject var errorHandler: ErrorHandler
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: $errorHandler.showError) {
                Button("OK") {
                    errorHandler.clear()
                }
            } message: {
                if let error = errorHandler.currentError {
                    Text(error.localizedDescription)
                }
            }
    }
}

extension View {
    func errorAlert(errorHandler: ErrorHandler) -> some View {
        modifier(ErrorAlert(errorHandler: errorHandler))
    }
}

