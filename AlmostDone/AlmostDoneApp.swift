//
//  AlmostDoneApp.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI
import SwiftData

@main
struct AlmostDoneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [AlmostMoment.self, AppSettings.self, Achievement.self]) { result in
                    if case .failure(let error) = result {
                        print("Failed to create model container: \(error)")
                    }
                }
        }
    }
}
