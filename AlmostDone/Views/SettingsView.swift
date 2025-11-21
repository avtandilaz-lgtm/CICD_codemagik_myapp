//
//  SettingsView.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("appTheme") private var appTheme: String = "auto"
    @State private var showDeleteConfirmation = false
    @State private var showExportSheet = false
    @State private var exportURL: URL?
    @State private var exportType: ExportType = .json
    
    enum ExportType {
        case json, pdf
    }
    
    let context: ModelContext
    
    var body: some View {
        NavigationStack {
            Form {
                // Appearance
                Section("Appearance") {
                    Picker("Theme", selection: Binding(
                        get: { viewModel.theme },
                        set: { viewModel.updateTheme($0) }
                    )) {
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                        Text("Auto").tag("auto")
                    }
                }
                
                // Second Chance Settings
                Section("Second Chance") {
                    Picker("Frequency", selection: Binding(
                        get: { viewModel.secondChanceFrequency },
                        set: { viewModel.updateSecondChanceFrequency($0) }
                    )) {
                        ForEach(Constants.secondChanceFrequencies, id: \.self) { months in
                            Text("\(months) months").tag(months)
                        }
                    }
                    
                    Toggle("Notifications", isOn: Binding(
                        get: { viewModel.notificationsEnabled },
                        set: { viewModel.updateNotificationsEnabled($0) }
                    ))
                }
                
                // Widget Settings
                Section("Widget") {
                    Picker("Size", selection: Binding(
                        get: { viewModel.widgetSize },
                        set: { viewModel.updateWidgetSize($0) }
                    )) {
                        Text("Small").tag("small")
                        Text("Medium").tag("medium")
                        Text("Large").tag("large")
                    }
                }
                
                // Export
                Section("Data") {
                    Button(action: {
                        exportData(type: .json)
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export as JSON")
                        }
                    }
                    
                    Button(action: {
                        exportData(type: .pdf)
                    }) {
                        HStack {
                            Image(systemName: "doc.fill")
                            Text("Export as PDF")
                        }
                    }
                }
                
                // Danger Zone
                Section {
                    Button(role: .destructive, action: {
                        showDeleteConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete All Data")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete All Data", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteAllData()
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete all your data? This action cannot be undone.")
            }
            .sheet(item: Binding(
                get: { exportURL != nil ? ExportItem(url: exportURL!, type: exportType) : nil },
                set: { _ in exportURL = nil }
            )) { item in
                ShareSheet(activityItems: [item.url])
            }
            .onAppear {
                viewModel.setup(context: context)
                NotificationService.shared.requestAuthorization()
            }
        }
        .preferredColorScheme(activeColorScheme)
    }
    
    private var activeColorScheme: ColorScheme? {
        switch appTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil // auto - use system
        }
    }
    
    private func exportData(type: ExportType) {
        do {
            let url: URL
            switch type {
            case .json:
                url = try viewModel.exportJSON()
                exportType = .json
            case .pdf:
                url = try viewModel.exportPDF()
                exportType = .pdf
            }
            exportURL = url
        } catch {
            print("Export failed: \(error)")
        }
    }
}

struct ExportItem: Identifiable {
    let id = UUID()
    let url: URL
    let type: SettingsView.ExportType
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

